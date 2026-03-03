#!/usr/bin/env bash
set -euo pipefail

GUT_VERSION="v9.5.0"
TMP_DIR=$(mktemp -d)
trap "rm -rf '${TMP_DIR}'" EXIT

echo "Installing GUT ${GUT_VERSION}..."
curl -sLo "${TMP_DIR}/gut-src.zip" "https://github.com/bitwes/Gut/archive/refs/tags/${GUT_VERSION}.zip"
unzip -q "${TMP_DIR}/gut-src.zip" -d "${TMP_DIR}/gut-src"
mkdir -p addons
rm -rf addons/gut
cp -r "${TMP_DIR}/gut-src"/*/addons/gut addons/gut

echo "Done — GUT installed to addons/gut"
