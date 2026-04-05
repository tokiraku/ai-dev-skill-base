#!/usr/bin/env bash
#
# setup.sh: クローン後の初期セットアップ
#
# 実行方法:
#   bash scripts/setup.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[setup] Git hooks を設定中..."
git -C "$REPO_ROOT" config core.hooksPath .githooks
chmod +x "$REPO_ROOT/.githooks/pre-commit"

echo "[setup] 完了。以降 git commit 時に .agents/ → .claude/ が自動同期されます。"
