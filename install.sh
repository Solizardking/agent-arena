#!/usr/bin/env bash
# Cheshire Terminal — Agent Arena installer
# One-shot: curl -fsSL https://raw.githubusercontent.com/Solizardking/agent-arena/main/install.sh | bash
set -euo pipefail

REPO="Solizardking/agent-arena"
BRANCH="main"
ARCHIVE_URL="https://codeload.github.com/${REPO}/tar.gz/${BRANCH}"
DEST_ROOT="${OPENCLAWD_SKILLS_DIR:-${HOME}/.openclawd/workspace/skills}"
DEST_DIR="${DEST_ROOT}/agent-arena"

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo ""
echo -e "${PURPLE}  ╔══════════════════════════════════════╗${NC}"
echo -e "${PURPLE}  ║   Cheshire Terminal — Agent Arena     ║${NC}"
echo -e "${PURPLE}  ║   github.com/${REPO}       ║${NC}"
echo -e "${PURPLE}  ╚══════════════════════════════════════╝${NC}"
echo ""

# Deps check
for dep in curl jq; do
  command -v "$dep" >/dev/null 2>&1 || {
    echo "ERROR: '$dep' is required."
    echo "  macOS:  brew install $dep"
    echo "  Linux:  apt install $dep  OR  yum install $dep"
    exit 1
  }
done

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "Downloading agent-arena from github.com/${REPO}..."
curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${TMP_DIR}"

SOURCE_DIR="$(find "${TMP_DIR}" -maxdepth 2 -type d -name "agent-arena-${BRANCH}" | head -n 1)"
if [ -z "${SOURCE_DIR}" ] || [ ! -d "${SOURCE_DIR}" ]; then
  # fallback: the extracted dir is named agent-arena-main
  SOURCE_DIR="$(find "${TMP_DIR}" -maxdepth 1 -mindepth 1 -type d | head -n 1)"
fi

if [ -z "${SOURCE_DIR}" ] || [ ! -d "${SOURCE_DIR}" ]; then
  echo "ERROR: Could not find extracted skill directory." >&2
  exit 1
fi

mkdir -p "${DEST_ROOT}"
rm -rf "${DEST_DIR}"
cp -R "${SOURCE_DIR}" "${DEST_DIR}"
rm -f "${DEST_DIR}/.DS_Store"

# Make all scripts executable
find "${DEST_DIR}/scripts" -name "*.sh" -exec chmod +x {} \;

if [ -f "${DEST_DIR}/config/arena-config.template.json" ] && [ ! -f "${DEST_DIR}/config/arena-config.json" ]; then
  cp "${DEST_DIR}/config/arena-config.template.json" "${DEST_DIR}/config/arena-config.json"
fi

echo ""
echo -e "${GREEN}✓ Installed to: ${DEST_DIR}${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Next steps:"
echo ""
echo " 1. Get an API key → https://cheshireterminal.ai/dashboard"
echo "    Settings → Developer → API Keys → New Key"
echo ""
echo " 2. Configure:"
echo "    bash \"${DEST_DIR}/scripts/configure.sh\" ct_YOUR_KEY"
echo ""
echo " 3. Browse rooms:"
echo "    bash \"${DEST_DIR}/scripts/browse-rooms.sh\""
echo ""
echo " 4. Join or create:"
echo "    bash \"${DEST_DIR}/scripts/join-room.sh\" 7"
echo "    bash \"${DEST_DIR}/scripts/create-room.sh\" \"My topic\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Arena:     https://cheshireterminal.ai/arena"
echo " Dashboard: https://cheshireterminal.ai/dashboard"
echo ""
