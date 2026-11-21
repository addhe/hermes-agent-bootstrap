#!/usr/bin/env bash
#
# install.sh — install Hermes Agent dan bootstrap dengan profil prompt.
# Aman untuk repo publik: tanpa credentials, tanpa secret, tanpa path spesifik.
#
# Usage:
#   ./install.sh                 # install Hermes + seed .hermes.md + buka sesi interaktif
#   ./install.sh --no-launch     # install + seed saja (tidak membuka sesi)
#   ./install.sh --dest DIR      # clone repo ke DIR, lalu install + seed + launch
#   ./install.sh --help          # bantuan
#
set -euo pipefail

REPO="https://github.com/addhe/hermes-agent-bootstrap"
LAUNCH=1
DEST=""

# --- parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --no-launch) LAUNCH=0; shift ;;
    --dest) DEST="${2:-}"; [ -n "$DEST" ] || { echo "--dest butuh argumen"; exit 1; }; shift 2 ;;
    --help|-h) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Argumen tak dikenal: $1 (lihat --help)" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- tentukan working dir (checkout repo ini) ---
if [ -n "$DEST" ]; then
  mkdir -p "$DEST"
  if [ ! -d "$DEST/.git" ]; then
    echo ">> Cloning repo -> $DEST"
    git clone "$REPO" "$DEST"
  fi
  WORKDIR="$DEST"
else
  WORKDIR="$SCRIPT_DIR"
fi

# --- 1. install Hermes (installer resmi) ---
if ! command -v hermes >/dev/null 2>&1; then
  echo ">> Meng-install Hermes Agent (installer resmi)..."
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi

# pastikan launcher di PATH (installer menempatkannya di ~/.local/bin)
if ! command -v hermes >/dev/null 2>&1 && [ -x "$HOME/.local/bin/hermes" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
if ! command -v hermes >/dev/null 2>&1; then
  echo "ERROR: 'hermes' tidak ditemukan setelah install. Tambahkan bin dir-nya ke PATH lalu jalankan ulang." >&2
  exit 1
fi
echo ">> hermes version: $(hermes --version)"

# --- 2. seed bootstrap prompt sebagai project context ---
# .hermes.md auto-loads di setiap sesi Hermes yang dijalankan di direktori ini.
if [ -f "$WORKDIR/PROMPT.md" ]; then
  cp "$WORKDIR/PROMPT.md" "$WORKDIR/.hermes.md"
  echo ">> Bootstrap tersedia: $WORKDIR/.hermes.md (auto-load di setiap sesi di sini)"
else
  echo "WARN: PROMPT.md tidak ditemukan di samping install.sh; seed dilewati." >&2
fi

# --- 3. launch ---
echo
echo "Selesai. Hermes siap digunakan."
if [ "$LAUNCH" = 1 ] && [ -t 0 ]; then
  echo ">> Membuka sesi Hermes interaktif di: $WORKDIR"
  echo "   (prompt bootstrap sudah ter-load otomatis dari .hermes.md)"
  cd "$WORKDIR"
  exec hermes "$@"
else
  echo ">> Untuk mulai: cd '$WORKDIR' && hermes"
fi
