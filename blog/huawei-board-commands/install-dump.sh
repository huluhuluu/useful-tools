#!/usr/bin/env bash
# openEuler environment bootstrap v2.8: multi-user, actionable logging and summary
set -Eeuo pipefail

GH_PROXY="${GH_PROXY:-https://ghfast.top}"
HTOP_VERSION="${HTOP_VERSION:-3.5.0}"
CONDA_PATH="${CONDA_PATH:-$HOME/miniforge3}"
ASCEND_ROOT="${ASCEND_ROOT:-/usr/local/Ascend}"
CANN_FALLBACK_VERSION="${CANN_FALLBACK_VERSION:-9.0.1}"
JEMALLOC_SO="${JEMALLOC_SO:-/usr/lib64/libjemalloc.so.2}"
INSTALL_HTOP_FROM_SOURCE="${INSTALL_HTOP_FROM_SOURCE:-0}"
AUTO_ZSH="${AUTO_ZSH:-1}"

ok_count=0; skip_count=0; warn_count=0
admin_packages=(); warnings=(); temp_paths=(); stage='startup'
info() { printf '[INFO] %s\n' "$*"; }
ok() { printf '[OK]   %s\n' "$*"; ((ok_count+=1)); }
skip() { printf '[SKIP] %s\n' "$*"; ((skip_count+=1)); }
warn() { printf '[WARN] %s\n' "$*" >&2; warnings+=("$*"); ((warn_count+=1)); }
action() { printf '[ACTION] %s\n' "$*"; }
stage_start() { stage="$1"; printf '\n========== [%s/8] %s ==========\n' "$2" "$1"; }
has() { command -v "$1" >/dev/null 2>&1; }
cmd_path() { command -v "$1" 2>/dev/null || true; }
append_once() { local file="$1" line="$2"; touch "$file"; grep -qxF -- "$line" "$file" || printf '%s\n' "$line" >> "$file"; }
# Add a guarded, uniquely marked configuration block, without modifying unrelated user lines.
add_block_once() {
  local file="$1" marker="$2" content="$3"
  touch "$file"
  if grep -qF "# >>> $marker >>>" "$file"; then skip "$marker already configured in $file"; return; fi
  printf '\n# >>> %s >>>\n%s\n# <<< %s <<<\n' "$marker" "$content" "$marker" >> "$file"
  ok "$marker configured in $file"
}

fetch() { curl -fL --retry 3 --connect-timeout 15 "$1" -o "$2"; }
github_url() { if [[ -n "$GH_PROXY" ]]; then printf '%s/%s' "${GH_PROXY%/}" "$1"; else printf '%s' "$1"; fi; }
new_temp_file() { local file; file="$(mktemp "${TMPDIR:-/tmp}/env-init.XXXXXXXX")"; temp_paths+=("$file"); printf '%s' "$file"; }
# Avoid command substitution for tracked temporary paths (subshell loses array changes).
cleanup() { local p; for p in "${temp_paths[@]}"; do [[ ! -e "$p" ]] || rm -rf -- "$p"; done; }
summary() {
  local result="COMPLETE"
  if ((warn_count>0)); then result="PARTIAL (warnings)"; fi
  printf '\n========== Installation summary ==========\n'
  printf 'Result: %s | OK: %d | SKIP: %d | WARN: %d\n' "$result" "$ok_count" "$skip_count" "$warn_count"
  if ((${#admin_packages[@]})); then
    printf '[ACTION] Ask administrator to run:\n  sudo dnf install -y'; printf ' %q' "${admin_packages[@]}"; printf '\n'
  fi
  if ((${#warnings[@]})); then
    printf 'Outstanding warnings:\n'; local w; for w in "${warnings[@]}"; do printf '  - %s\n' "$w"; done
  fi
  printf 'Restart terminal to load updated shell configuration.\n'
}
on_error() { local code="$1" line="$2" command="$3"; printf '\n[ERROR] Stage: %s | line: %s | exit: %s\n[ERROR] Command: %s\n' "$stage" "$line" "$code" "$command" >&2; summary >&2; }
trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
trap cleanup EXIT

if [[ $EUID -eq 0 ]]; then mode='root: can install missing system packages'; else mode='non-root: report missing system packages'; fi
info "User: $(id -un) (UID=$EUID) | HOME=$HOME"
info "Mode: $mode"
if [[ $EUID -eq 0 ]]; then warn 'Personal tools will install under /root. Run as the intended user for personal setup.'; fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
mkdir -p "$HOME/.local/bin"
append_once "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"'

stage_start 'System dependencies' 1
if has rpm && has dnf; then
  packages=(zsh tmux git wget curl ncurses-devel autoconf automake libtool jemalloc gcc make pkgconf-pkg-config)
  missing=()
  for pkg in "${packages[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then ok "$pkg installed"; else missing+=("$pkg"); fi
  done
  if ((${#missing[@]})); then
    if [[ $EUID -eq 0 ]]; then
      info "Installing missing packages: ${missing[*]}"
      dnf install -y "${missing[@]}"
      for pkg in "${missing[@]}"; do if rpm -q "$pkg" >/dev/null 2>&1; then ok "$pkg installed"; else warn "$pkg still missing after dnf"; fi; done
    else
      admin_packages+=("${missing[@]}")
      warn "System packages missing: ${missing[*]}"
      action "Ask administrator to install missing packages (command in final summary)."
    fi
  fi
else
  warn 'rpm or dnf unavailable; system dependency check skipped.'
fi

stage_start 'Zsh and Oh My Zsh' 2
if ! has zsh; then
  warn 'zsh missing; skipping Zsh setup.'
else
  ok "zsh: $(cmd_path zsh)"
  if ! has git; then
    warn 'git missing; cannot install Oh My Zsh and plugins.'
  else
    if [[ -d "$HOME/.oh-my-zsh" ]]; then skip 'Oh My Zsh already present'; else git clone https://gitee.com/mirror-hub/ohmyzsh.git "$HOME/.oh-my-zsh"; ok "Oh My Zsh installed: $HOME/.oh-my-zsh"; fi
    if [[ ! -f "$HOME/.zshrc" ]]; then
      if [[ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"; else touch "$HOME/.zshrc"; fi
      ok 'Created ~/.zshrc'
    else skip 'Preserved existing ~/.zshrc'; fi
    plugin_dir="$HOME/.oh-my-zsh/custom/plugins"; mkdir -p "$plugin_dir"
    for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
      if [[ -d "$plugin_dir/$plugin" ]]; then skip "$plugin already present"; else git clone "https://gitee.com/mirror-hub/$plugin.git" "$plugin_dir/$plugin"; ok "$plugin installed"; fi
    done
    if grep -qE '^plugins=\(' "$HOME/.zshrc"; then
      for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
        if ! grep -E '^plugins=\(' "$HOME/.zshrc" | grep -qw "$plugin"; then
          sed -i -E "0,/^plugins=\(.*\)/s/^plugins=\((.*)\)/plugins=(\1 $plugin)/" "$HOME/.zshrc"
        fi
      done
    else append_once "$HOME/.zshrc" 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions)'; fi
    # Ensure Oh My Zsh is actually loaded, after theme and plugin declarations.
    # Preserve an existing theme and plugin list. Move a pre-existing loader to
    # the end so a legacy .zshrc with plugins after `source` is repaired.
    if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
      if ! grep -qE '^[[:space:]]*(export[[:space:]]+)?ZSH=' "$HOME/.zshrc"; then
        append_once "$HOME/.zshrc" 'export ZSH="$HOME/.oh-my-zsh"'
      fi
      if ! grep -qE '^[[:space:]]*ZSH_THEME=' "$HOME/.zshrc"; then
        append_once "$HOME/.zshrc" 'ZSH_THEME="robbyrussell"'
      fi
      # Remove only canonical Oh My Zsh loader lines; do not touch other sources.
      sed -i -E '/^[[:space:]]*(source|\.)[[:space:]]+("?\$ZSH\/oh-my-zsh\.sh"?|"?\$HOME\/\.oh-my-zsh\/oh-my-zsh\.sh"?)[[:space:]]*$/d' "$HOME/.zshrc"
      append_once "$HOME/.zshrc" 'source "$ZSH/oh-my-zsh.sh"'
      ok 'Oh My Zsh loader configured after theme and plugins'
    else
      warn 'Oh My Zsh loader missing; theme cannot be enabled'
    fi
  fi
  append_once "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
  info 'Zsh available; login auto-switch is configured in final checks when AUTO_ZSH=1'
fi

stage_start 'zoxide and fzf' 3
if has zoxide; then ok "zoxide: $(cmd_path zoxide)";
elif has curl; then
  installer="$(mktemp "${TMPDIR:-/tmp}/zoxide-install.XXXXXXXX")"; temp_paths+=("$installer")
  fetch "$(github_url https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)" "$installer"
  sh "$installer" --bin-dir "$HOME/.local/bin"
  if has zoxide; then ok "zoxide installed: $(cmd_path zoxide)"; else warn 'zoxide installer finished but binary not found'; fi
else warn 'zoxide unavailable; curl is required'; fi
if has zoxide; then
  if has zsh; then append_once "$HOME/.zshrc" 'command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"'; fi
  append_once "$HOME/.bashrc" 'command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"'
fi
if has fzf; then ok "fzf: $(cmd_path fzf)";
elif [[ -x "$HOME/.fzf/bin/fzf" ]]; then
  append_once "$HOME/.zshrc" 'export PATH="$HOME/.fzf/bin:$PATH"'; append_once "$HOME/.bashrc" 'export PATH="$HOME/.fzf/bin:$PATH"'; ok "fzf: $HOME/.fzf/bin/fzf"
elif has git; then
  if [[ ! -d "$HOME/.fzf" ]]; then git clone --depth 1 "$(github_url https://github.com/junegunn/fzf.git)" "$HOME/.fzf"; fi
  if [[ -x "$HOME/.fzf/install" ]]; then
    "$HOME/.fzf/install" --all --no-update-rc
    append_once "$HOME/.zshrc" 'export PATH="$HOME/.fzf/bin:$PATH"'
    append_once "$HOME/.bashrc" 'export PATH="$HOME/.fzf/bin:$PATH"'
    if [[ -x "$HOME/.fzf/bin/fzf" ]]; then ok "fzf installed: $HOME/.fzf/bin/fzf"; else warn 'fzf binary not found after install'; fi
  else warn 'fzf checkout incomplete; installer missing'; fi
else warn 'fzf unavailable; git is required'; fi

stage_start 'Ascend CANN / ATB / jemalloc' 4
cann_env=''
if [[ -f "$ASCEND_ROOT/cann-${CANN_FALLBACK_VERSION}/set_env.sh" ]]; then cann_env="$ASCEND_ROOT/cann-${CANN_FALLBACK_VERSION}/set_env.sh";
else for candidate in "$ASCEND_ROOT"/cann-*/set_env.sh; do if [[ -f "$candidate" ]]; then cann_env="$candidate"; break; fi; done; fi
if [[ -n "$cann_env" ]]; then
  ok "CANN environment: $cann_env"
  if has zsh; then append_once "$HOME/.zshrc" "source \"$cann_env\""; fi
  append_once "$HOME/.bashrc" "source \"$cann_env\""
else warn "CANN set_env.sh not found under $ASCEND_ROOT"; fi
atb_env="$ASCEND_ROOT/nnal/atb/set_env.sh"
if [[ -f "$atb_env" ]]; then
  ok "ATB environment: $atb_env"
  if has zsh; then append_once "$HOME/.zshrc" "source \"$atb_env\""; fi
  append_once "$HOME/.bashrc" "source \"$atb_env\""
else warn "ATB set_env.sh not found: $atb_env"; fi
if [[ -f "$JEMALLOC_SO" ]]; then ok "jemalloc available: $JEMALLOC_SO (not globally preloaded)"; else skip 'jemalloc preload not configured'; fi

stage_start 'Miniforge / Conda' 5
if [[ -x "$CONDA_PATH/bin/conda" ]]; then ok "Conda installed: $CONDA_PATH/bin/conda";
elif [[ -e "$CONDA_PATH" ]]; then warn "Conda path exists but executable missing: $CONDA_PATH; manual inspection needed";
elif has conda; then ok "Existing conda: $(cmd_path conda)";
else
  arch="$(uname -m)"
  case "$arch" in
    aarch64|x86_64) url="https://mirror.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-${arch}.sh" ;;
    *) url=''; warn "Unsupported architecture: $arch" ;;
  esac
  if [[ -n "$url" ]]; then
    if has curl || has wget; then
      installer="$(mktemp "${TMPDIR:-/tmp}/Miniforge3.XXXXXXXX.sh")"; temp_paths+=("$installer")
      if has curl; then fetch "$url" "$installer"; else wget -O "$installer" "$url"; fi
      bash "$installer" -b -p "$CONDA_PATH"
      if [[ -x "$CONDA_PATH/bin/conda" ]]; then ok "Miniforge installed: $CONDA_PATH"; else warn 'Miniforge installer finished but conda missing'; fi
    else warn 'Miniforge requires curl or wget'; fi
  fi
fi
if [[ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]]; then
  if has zsh; then append_once "$HOME/.zshrc" "source \"$CONDA_PATH/etc/profile.d/conda.sh\""; fi
  append_once "$HOME/.bashrc" "source \"$CONDA_PATH/etc/profile.d/conda.sh\""
fi

stage_start 'uv and ascend-nputop' 6
if has uv; then ok "uv: $(cmd_path uv)";
elif has curl; then
  installer="$(mktemp "${TMPDIR:-/tmp}/uv-install.XXXXXXXX")"; temp_paths+=("$installer")
  fetch 'https://astral.sh/uv/install.sh' "$installer"
  sh "$installer" --no-modify-path
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  if has uv; then ok "uv installed: $(cmd_path uv)"; else warn 'uv installer finished but executable not on PATH'; fi
else warn 'uv missing; curl is required'; fi
if has ascend-nputop; then ok "ascend-nputop: $(cmd_path ascend-nputop)";
elif has uv; then
  uv tool install ascend-nputop --index-url https://pypi.mirrors.ustc.edu.cn/simple/
  if has ascend-nputop; then ok "ascend-nputop installed: $(cmd_path ascend-nputop)"; else warn 'ascend-nputop installed but executable not found'; fi
else warn 'ascend-nputop skipped because uv unavailable'; fi

stage_start 'htop' 7
if has htop; then ok "htop: $(cmd_path htop) ($(htop --version | head -n1))";
elif [[ "$INSTALL_HTOP_FROM_SOURCE" == '1' ]]; then
  prerequisites=(curl tar make gcc autoconf automake libtool pkg-config)
  missing_build=()
  for cmd in "${prerequisites[@]}"; do has "$cmd" || missing_build+=("$cmd"); done
  if ((${#missing_build[@]})); then warn "Cannot compile htop; missing tools: ${missing_build[*]}";
  else
    build_dir="$(mktemp -d "${TMPDIR:-/tmp}/htop-build.XXXXXXXX")"; temp_paths+=("$build_dir")
    fetch "$(github_url "https://github.com/htop-dev/htop/archive/refs/tags/${HTOP_VERSION}.tar.gz")" "$build_dir/htop.tar.gz"
    tar -xf "$build_dir/htop.tar.gz" -C "$build_dir"
    (
      cd "$build_dir/htop-$HTOP_VERSION"
      ./autogen.sh
      ./configure --prefix="$HOME/.local"
      make -j"$(nproc)"
      make install
    )
    if has htop; then ok "htop installed: $(cmd_path htop)"; else warn 'htop build finished but binary not found'; fi
  fi
else
  if [[ $EUID -eq 0 ]] && has dnf; then
    info 'Installing missing htop with dnf'
    dnf install -y htop
    if has htop; then ok "htop installed: $(cmd_path htop)"; else warn 'htop still missing after dnf'; fi
  else
    warn 'htop missing; ask administrator to install htop'
    admin_packages+=(htop)
    action 'Optional user-local compilation: INSTALL_HTOP_FROM_SOURCE=1 bash install-dump-v2.8.sh'
  fi
fi

stage_start 'Final checks' 8
# Bash login shells normally read ~/.bash_profile, which may not source ~/.bashrc.
# Avoid rewriting an existing user's profile; add a guarded entry only when requested.
append_once "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"'
if has fzf; then
  # Modern fzf exposes shell integration through `fzf --bash` / `fzf --zsh`.
  if fzf --bash >/dev/null 2>&1; then
    append_once "$HOME/.bashrc" 'command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"'
  fi
  if has zsh && fzf --zsh >/dev/null 2>&1; then
    append_once "$HOME/.zshrc" 'command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)'
  fi
fi
if has zsh && [[ "$AUTO_ZSH" == '1' ]]; then
  # Interactive Bash login only. Non-interactive SSH commands and scripts stay in Bash.
  add_block_once "$HOME/.bash_profile" 'env-init-auto-zsh' 'if [[ $- == *i* ]] && [[ -z "${ZSH_VERSION:-}" ]] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi'
  info 'Next interactive Bash login will enter Zsh; current shell: exec zsh -l'
elif has zsh; then
  skip 'AUTO_ZSH=0; automatic Zsh switching disabled'
else
  warn 'Zsh unavailable: Bash remains the login shell; ask administrator to install zsh'
fi
summary
