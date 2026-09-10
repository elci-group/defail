#!/usr/bin/env bash
set -euo pipefail
# Install defail on dreamsequence VPS via dreamcred
# Uses dreamcred ssh production wrapper (preferred) with direct-ssh fallback.
# The VPS is expected to have cargo/rustup; if missing, rustup is bootstrapped.
#
# Usage (from workstation, outside sandbox):
#   ./scripts/install-defail-vps.sh
#   # or manually:
#   DREAMCRED_MANIFEST=tools/dreamcred/credentials.toml dreamcred ssh production -- bash -s < scripts/install-defail-vps.sh

VPS_ALIAS="production"               # dreamcred-declared server (dreamcred status)
FALLBACK_ALIAS="dreamsequence-vps"   # ~/.ssh/config host for the no-dreamcred path
REPO_URL="https://github.com/elci-group/defail.git"  # adjust if private
INSTALL_DIR="/opt/defail"
BINARY="/usr/local/bin/defail"

echo "[defail-vps] checking connectivity..."
if command -v dreamcred >/dev/null 2>&1; then
  echo "[defail-vps] using dreamcred ssh"
  SSH_CMD=(dreamcred ssh "$VPS_ALIAS" --)
else
  echo "[defail-vps] dreamcred not found, using direct ssh"
  SSH_CMD=(ssh -o StrictHostKeyChecking=no "$FALLBACK_ALIAS")
fi

# The payload executed on the VPS
# (`|| true`: `read -d ''` returns 1 at heredoc EOF, which `set -e` would
# treat as fatal — this line is the classic silent-killer without the guard.)
read -r -d '' REMOTE_SCRIPT << 'REMOTE_EOS' || true
set -euo pipefail
echo "[remote] host: $(hostname), user: $(whoami), date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
if ! command -v cargo >/dev/null 2>&1; then
  echo "[remote] cargo not found, installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi
echo "[remote] cargo $(cargo --version), rustc $(rustc --version)"
# Clone or update
if [ -d /opt/defail/.git ]; then
  echo "[remote] updating existing /opt/defail"
  sudo -n git -C /opt/defail fetch --all --prune || git -C /opt/defail fetch --all --prune
  sudo -n git -C /opt/defail reset --hard origin/main || git -C /opt/defail reset --hard origin/main
else
  echo "[remote] cloning defail to /opt/defail"
  sudo mkdir -p /opt/defail
  sudo chown "$(whoami)":"$(whoami)" /opt/defail
  git clone https://github.com/elci-group/defail.git /opt/defail
fi
cd /opt/defail
echo "[remote] building defail (release)..."
cargo build --release
echo "[remote] installing to /usr/local/bin/defail..."
sudo install -m 0755 target/release/defail /usr/local/bin/defail
echo "[remote] verifying..."
/usr/local/bin/defail --help | head -n 20
/usr/local/bin/defail demo baker --late 2>&1 | head -n 40
echo "[remote] defail installed: $(/usr/local/bin/defail --help | head -n 1)"
REMOTE_EOS

if [[ "${1:-}" == "--local" ]]; then
  # Run directly (when already on VPS)
  bash -c "$REMOTE_SCRIPT"
else
  # Run via SSH
  printf "%s" "$REMOTE_SCRIPT" | "${SSH_CMD[@]}" bash -s
fi
