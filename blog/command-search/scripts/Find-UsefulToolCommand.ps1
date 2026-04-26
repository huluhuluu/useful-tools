[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'Preview', 'BuildIndex')]
    [string]$Mode = 'Interactive',

    [string]$Root,

    [string]$IndexPath,

    [int]$Id,

    [string]$Query,

    [ValidateSet('code', 'default')]
    [string]$OpenWith = 'code',

    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$QueryWords
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

if ((-not $Query) -and $QueryWords) {
    $Query = (($QueryWords | Where-Object { $_ }) -join ' ').Trim()
}

function Resolve-SearchRoot {
    param([string]$RequestedRoot)

    $fallbackRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
    $configPath = Join-Path $PSScriptRoot 'UsefulToolCommandSearch.root.txt'
    $candidate = $RequestedRoot

    if (-not $candidate) {
        $envRoot = [Environment]::GetEnvironmentVariable('USEFUL_TOOL_SEARCH_ROOT')
        if ($envRoot) {
            $candidate = $envRoot.Trim()
        }
    }

    if ((-not $candidate) -and (Test-Path -LiteralPath $configPath)) {
        $candidate = (Get-Content -LiteralPath $configPath -Raw).Trim()
    }

    if (-not $candidate) {
        return $fallbackRoot
    }

    $candidate = [Environment]::ExpandEnvironmentVariables($candidate)
    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path $PSScriptRoot $candidate
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

$ResolvedRoot = Resolve-SearchRoot -RequestedRoot $Root

function Get-ArticleTitle {
    param(
        [string[]]$Lines,
        [string]$Fallback
    )

    if ($Lines.Count -lt 3 -or $Lines[0].Trim() -ne '---') {
        return $Fallback
    }

    for ($i = 1; $i -lt $Lines.Count; $i++) {
        $line = $Lines[$i]
        if ($line.Trim() -eq '---') {
            break
        }

        if ($line -match '^\s*title:\s*"(.*)"\s*$') {
            return $matches[1].Trim()
        }

        if ($line -match "^\s*title:\s*'(.*)'\s*$") {
            return $matches[1].Trim()
        }

        if ($line -match '^\s*title:\s*(.+?)\s*$') {
            return $matches[1].Trim()
        }
    }

    return $Fallback
}

function Normalize-PreviewText {
    param([string[]]$Lines)

    return (($Lines | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ' | ')
}

function Trim-Display {
    param(
        [string]$Text,
        [int]$Max = 120
    )

    $value = ($Text ?? '').Replace("`t", ' ').Replace("`r", ' ').Replace("`n", ' ').Trim()
    if ($value.Length -le $Max) {
        return $value
    }

    return $value.Substring(0, $Max - 3) + '...'
}

function Encode-ItemText {
    param([string]$Text)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text ?? '')
    return [Convert]::ToBase64String($bytes)
}

function Decode-ItemText {
    param([string]$Encoded)

    $bytes = [Convert]::FromBase64String($Encoded)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Get-TargetMarkdownFiles {
    param(
        [string]$SearchRoot,
        [string]$InitialQuery
    )

    if (-not (Test-Path -LiteralPath $SearchRoot)) {
        throw "Root path not found: $SearchRoot"
    }

    $allFiles = Get-ChildItem -LiteralPath $SearchRoot -Recurse -File -Filter '*.md' |
        Sort-Object FullName

    if (-not $InitialQuery) {
        return $allFiles
    }

    $rg = Get-Command rg.exe -ErrorAction SilentlyContinue
    if (-not $rg) {
        return $allFiles
    }

    $matched = & $rg.Source --files-with-matches --glob '*.md' -i -F -- $InitialQuery $SearchRoot 2>$null
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 1) {
        return $allFiles
    }

    if (-not $matched) {
        return $allFiles
    }

    $matchedSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $matched) {
        $resolved = $path
        if (-not [System.IO.Path]::IsPathRooted($resolved)) {
            $resolved = Join-Path $SearchRoot $path
        }

        $matchedSet.Add([System.IO.Path]::GetFullPath($resolved)) | Out-Null
    }

    return $allFiles | Where-Object { $matchedSet.Contains([System.IO.Path]::GetFullPath($_.FullName)) }
}

function Build-IndexItems {
    param(
        [string]$SearchRoot,
        [string]$InitialQuery
    )

    $items = New-Object System.Collections.Generic.List[object]
    $nextId = 1
    $files = Get-TargetMarkdownFiles -SearchRoot $SearchRoot -InitialQuery $InitialQuery

    foreach ($file in $files) {
        $lines = Get-Content -LiteralPath $file.FullName
        $articleTitle = Get-ArticleTitle -Lines $lines -Fallback $file.BaseName
        $currentHeading = $articleTitle
        $relativePath = [System.IO.Path]::GetRelativePath($SearchRoot, $file.FullName)

        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]

            if ($line -match '^(#{1,6})\s+(.+?)\s*$') {
                $heading = $matches[2].Trim()
                $currentHeading = $heading
                $items.Add([pscustomobject]@{
                        Id          = $nextId
                        Kind        = 'heading'
                        FileRel     = $relativePath
                        FileAbs     = $file.FullName
                        Line        = $i + 1
                        Title       = $articleTitle
                        Summary     = Trim-Display -Text $heading -Max 100
                        EncodedText = Encode-ItemText -Text $heading
                    })
                $nextId++
                continue
            }

            if ($line -notmatch '^\s*```([A-Za-z0-9#+._-]*)\s*$') {
                continue
            }

            $codeLang = $matches[1]
            $startLine = $i + 1
            $blockLines = New-Object System.Collections.Generic.List[string]
            $foundEnd = $false

            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match '^\s*```\s*$') {
                    $i = $j
                    $foundEnd = $true
                    break
                }

                $blockLines.Add($lines[$j])
            }

            if (-not $foundEnd -or $blockLines.Count -eq 0) {
                continue
            }

            $blockText = [string]::Join("`n", $blockLines)
            if (-not $blockText.Trim()) {
                continue
            }

            $summarySource = Normalize-PreviewText -Lines $blockLines
            $title = if ($currentHeading -and $currentHeading -ne $articleTitle) {
                "$articleTitle / $currentHeading"
            } else {
                $articleTitle
            }

            if ($codeLang) {
                $title = "$title [$codeLang]"
            }

            $items.Add([pscustomobject]@{
                    Id          = $nextId
                    Kind        = 'code'
                    FileRel     = $relativePath
                    FileAbs     = $file.FullName
                    Line        = $startLine
                    Title       = Trim-Display -Text $title -Max 100
                    Summary     = Trim-Display -Text $summarySource -Max 140
                    EncodedText = Encode-ItemText -Text $blockText
                })
            $nextId++
        }
    }

    return $items
}

function Save-IndexFile {
    param(
        [System.Collections.IEnumerable]$Items,
        [string]$Path
    )

    $rows = foreach ($item in $Items) {
        @(
            $item.Id
            $item.Kind
            $item.FileRel
            $item.Line
            $item.Title
            $item.Summary
            $item.EncodedText
            $item.FileAbs
        ) -join "`t"
    }

    Set-Content -LiteralPath $Path -Value $rows -Encoding UTF8
}

function Read-IndexItem {
    param(
        [string]$Path,
        [int]$ItemId
    )

    foreach ($row in [System.IO.File]::ReadLines($Path)) {
        $parts = $row -split "`t", 8
        if ([int]$parts[0] -ne $ItemId) {
            continue
        }

        return [pscustomobject]@{
            Id          = [int]$parts[0]
            Kind        = $parts[1]
            FileRel     = $parts[2]
            Line        = [int]$parts[3]
            Title       = $parts[4]
            Summary     = $parts[5]
            EncodedText = $parts[6]
            FileAbs     = $parts[7]
        }
    }

    throw "Index item not found: $ItemId"
}

function Get-ContextSnippet {
    param(
        [string]$Path,
        [int]$LineNumber,
        [int]$Radius = 8
    )

    $lines = Get-Content -LiteralPath $Path
    if (-not $lines) {
        return ''
    }

    $start = [Math]::Max(1, $LineNumber - $Radius)
    $end = [Math]::Min($lines.Count, $LineNumber + $Radius)
    $snippet = New-Object System.Collections.Generic.List[string]

    for ($line = $start; $line -le $end; $line++) {
        $prefix = if ($line -eq $LineNumber) { '>' } else { ' ' }
        $snippet.Add(('{0}{1,4} {2}' -f $prefix, $line, $lines[$line - 1]))
    }

    return [string]::Join("`n", $snippet)
}

function Show-Preview {
    param(
        [string]$Path,
        [int]$ItemId
    )

    $item = Read-IndexItem -Path $Path -ItemId $ItemId
    $header = @(
        ('[{0}] {1}:{2}' -f $item.Kind, $item.FileRel, $item.Line)
        ('title: {0}' -f $item.Title)
        ''
    )

    if ($item.Kind -eq 'code') {
        $text = Decode-ItemText -Encoded $item.EncodedText
        $body = @(
            $text
            ''
            'keys: enter/ctrl-o=open  ctrl-y=copy  ctrl-p=copy-path'
        )
        Write-Output (($header + $body) -join "`n")
        return
    }

    $context = Get-ContextSnippet -Path $item.FileAbs -LineNumber $item.Line
    Write-Output (($header + $context) -join "`n")
}

function Open-Item {
    param(
        [pscustomobject]$Item,
        [string]$Editor
    )

    if ($Editor -eq 'code' -and (Get-Command code -ErrorAction SilentlyContinue)) {
        & code --goto "$($Item.FileAbs):$($Item.Line)" | Out-Null
        return
    }

    Invoke-Item -LiteralPath $Item.FileAbs
}

function Copy-ItemText {
    param([pscustomobject]$Item)

    $text = Decode-ItemText -Encoded $Item.EncodedText
    Set-Clipboard -Value $text
}

function Run-InteractivePicker {
    param(
        [string]$SearchRoot,
        [string]$InitialQuery,
        [string]$Editor
    )

    $items = Build-IndexItems -SearchRoot $SearchRoot -InitialQuery $InitialQuery
    if (-not $items -or $items.Count -eq 0) {
        throw 'No markdown snippets found under the target root.'
    }

    $tempIndex = Join-Path ([System.IO.Path]::GetTempPath()) ("useful-tools-index-{0}.tsv" -f [Guid]::NewGuid().ToString('N'))
    Save-IndexFile -Items $items -Path $tempIndex

    try {
        $previewCommand = "pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Mode Preview -IndexPath `"$tempIndex`" -Id {1}"
        $header = 'enter/ctrl-o open  ctrl-y copy snippet  ctrl-p copy path  esc quit'

        $fzfArgs = @(
            '--delimiter', "`t"
            '--with-nth', '2,3,4,5,6'
            '--preview', $previewCommand
            '--preview-window', 'right,65%,wrap'
            '--layout', 'reverse'
            '--border'
            '--height', '95%'
            '--prompt', 'useful-tools> '
            '--header', $header
            '--bind', 'ctrl-/:toggle-preview'
            '--expect', 'enter,ctrl-y,ctrl-o,ctrl-p'
        )

        if ($InitialQuery) {
            $fzfArgs += @('--query', $InitialQuery)
        }

        $selection = Get-Content -LiteralPath $tempIndex | & fzf.exe @fzfArgs
        if (-not $selection) {
            return
        }

        $trigger = $selection[0]
        $row = if ($selection.Count -ge 2) { $selection[1] } else { $selection[0] }
        if (-not $trigger -and $selection.Count -ge 2) {
            $trigger = 'enter'
        }

        $parts = $row -split "`t", 8
        $item = [pscustomobject]@{
            Id          = [int]$parts[0]
            Kind        = $parts[1]
            FileRel     = $parts[2]
            Line        = [int]$parts[3]
            Title       = $parts[4]
            Summary     = $parts[5]
            EncodedText = $parts[6]
            FileAbs     = $parts[7]
        }

        switch ($trigger) {
            'ctrl-y' {
                Copy-ItemText -Item $item
                Write-Host ("Copied snippet from {0}:{1}" -f $item.FileRel, $item.Line)
            }
            'ctrl-p' {
                Set-Clipboard -Value $item.FileAbs
                Write-Host ("Copied path: {0}" -f $item.FileAbs)
            }
            'ctrl-o' {
                Open-Item -Item $item -Editor $Editor
            }
            'enter' {
                Open-Item -Item $item -Editor $Editor
            }
            default {
                Open-Item -Item $item -Editor $Editor
            }
        }
    }
    finally {
        if (Test-Path -LiteralPath $tempIndex) {
            Remove-Item -LiteralPath $tempIndex -Force
        }
    }
}

switch ($Mode) {
    'BuildIndex' {
        if (-not $IndexPath) {
            throw 'BuildIndex mode requires -IndexPath.'
        }

        $items = Build-IndexItems -SearchRoot $ResolvedRoot -InitialQuery $Query
        Save-IndexFile -Items $items -Path $IndexPath
        Write-Output ("Indexed {0} snippets into {1}" -f $items.Count, $IndexPath)
        break
    }
    'Preview' {
        if (-not $IndexPath) {
            throw 'Preview mode requires -IndexPath.'
        }

        Show-Preview -Path $IndexPath -ItemId $Id
        break
    }
    default {
        Run-InteractivePicker -SearchRoot $ResolvedRoot -InitialQuery $Query -Editor $OpenWith
        break
    }
}
