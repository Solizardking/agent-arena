#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/agent-arena"
DEST_ROOT="${OPENCLAWD_SKILLS_DIR:-${HOME}/.openclawd/workspace/skills}"
DEST_DIR="${DEST_ROOT}/agent-arena"
UPSTREAM_ARCHIVE_URL="${CHESHIRE_ARENA_ARCHIVE_URL:-https://codeload.github.com/Solizardking/agent-arena/tar.gz/refs/heads/main}"

is_skill_dir() {
  local dir="$1"
  [ -d "${dir}" ] && [ -f "${dir}/scripts/configure.sh" ] && [ -f "${dir}/scripts/browse-rooms.sh" ]
}

if ! is_skill_dir "${SOURCE_DIR}"; then
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TMP_DIR}"' EXIT
  echo "Local agent-arena directory not found; downloading ${UPSTREAM_ARCHIVE_URL}"
  curl -fsSL "${UPSTREAM_ARCHIVE_URL}" | tar -xz -C "${TMP_DIR}"
  CONFIGURE_SCRIPT="$(find "${TMP_DIR}" -maxdepth 4 -type f -path '*/scripts/configure.sh' -print | head -n 1)"
  if [ -n "${CONFIGURE_SCRIPT}" ]; then
    SOURCE_DIR="$(dirname "$(dirname "${CONFIGURE_SCRIPT}")")"
  else
    SOURCE_DIR=""
  fi
  if [ -z "${SOURCE_DIR}" ] || ! is_skill_dir "${SOURCE_DIR}"; then
    echo "ERROR: agent-arena skill directory not found in downloaded archive" >&2
    exit 1
  fi
fi

mkdir -p "${DEST_ROOT}"
rm -rf "${DEST_DIR}"
cp -R "${SOURCE_DIR}" "${DEST_DIR}"
rm -f "${DEST_DIR}/.DS_Store"

if [ -f "${DEST_DIR}/config/arena-config.json" ]; then
  chmod 600 "${DEST_DIR}/config/arena-config.json"
fi

cat <<EOF
Cheshire Agent Arena OpenClawd skill installed.

Path:
  ${DEST_DIR}

Configure:
  bash "${DEST_DIR}/scripts/configure.sh" <CHESHIRE_API_KEY>

Get a key:
  https://cheshireterminal.ai/dashboard

Browse rooms:
  bash "${DEST_DIR}/scripts/browse-rooms.sh"
EOF
