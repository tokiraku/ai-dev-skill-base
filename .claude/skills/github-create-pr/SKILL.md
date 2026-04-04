---
name: github-create-pr
description: 'GitHubプルリクエスト作成スキル。ブランチ差分を分析してPRタイトル・説明を自動生成し、ユーザー承認後にPRを作成する。GitHub MCPが利用可能な場合はMCP経由で実行。Use when: pull request, PR作成, プルリクエスト, create PR, github pr, open PR, プルリク'
argument-hint: 'ベースブランチ名またはPRタイトルのヒント（省略可）'
---

# GitHub プルリクエスト作成スキル

## 概要

現在のブランチとベースブランチの差分を分析し、PRタイトル・説明を自動生成する。
ユーザーの承認を得てから GitHub にプルリクエストを作成する。
GitHub MCP が利用可能な場合は MCP 経由の操作を優先する。

---

## 実行手順

### Step 1: ブランチ・リモート情報の収集

以下のコマンドで現在の状態を把握する。

```bash
git branch --show-current
git remote -v
git log --oneline <base-branch>..HEAD
git diff --stat <base-branch>..HEAD
```

- 現在のブランチ名とリモート（origin）の URL を確認する
- ベースブランチが引数で渡された場合はそれを使用する
- 渡されていない場合は `develop` または `dev` をデフォルトとし、存在しない場合はユーザーに確認する
- `HEAD` が `<base-branch>` と同一（コミット差分ゼロ）の場合は警告してユーザーに確認を求める

---

### Step 2: 差分の分析

コミット履歴と差分から以下を抽出する。

```bash
git log --oneline <base-branch>..HEAD
git diff <base-branch>..HEAD
```

分析ポイント:
- 変更の目的（機能追加 / バグ修正 / リファクタリング / ドキュメント / その他）
- 変更されたファイルと主な変更内容
- Breaking Change の有無
- 関連する Issue 番号（コミットメッセージ中の `#123` や `closes #123` を検出）

---

### Step 3: PR タイトル・説明の生成

#### タイトル生成ルール

- **50〜72 文字以内**、命令形で簡潔に
- Conventional Commits の type をプレフィックスとして付与（任意）

| type | 使用場面 |
|------|----------|
| `feat:` | 新機能の追加 |
| `fix:` | バグ修正 |
| `docs:` | ドキュメントのみの変更 |
| `refactor:` | リファクタリング |
| `chore:` | ビルド・設定変更 |
| `test:` | テストの追加・修正 |

引数でヒントが渡された場合はその内容を優先して反映する。

#### 説明（Body）テンプレート

```markdown
## Background
<!-- なぜこの変更が必要か。ビジネス背景・技術的経緯・解決したい問題を1〜3文で記述 -->
<背景・動機を記述>

## Changes
<!-- 何を変更したか。差分から読み取れる主な変更点を箇条書きで列挙 -->
- <変更点1>
- <変更点2>
- <変更点3>

## Type of change
<!-- 該当するものにチェック -->
- [ ] 🆕 New feature（新機能）
- [ ] 🐛 Bug fix（バグ修正）
- [ ] ♻️ Refactoring（リファクタリング・機能変更なし）
- [ ] 📝 Documentation（ドキュメントのみ）
- [ ] ⚙️ Chore（ビルド・設定・依存関係）
- [ ] ⚠️ Breaking change（後方互換性を破壊する変更）

## Test plan
<!-- レビュアーが動作を確認するための手順 -->
- [ ] <動作確認手順1>
- [ ] <動作確認手順2>

## Notes for reviewer
<!-- レビュアーへの補足。特に見てほしい箇所・設計上の判断・既知の問題などがあれば記述 -->
<補足事項（なければ削除）>

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

生成ルール:
- Issue と紐づく場合は `Changes` セクション末尾に `Closes #<番号>` を追加する
- Breaking Change がある場合は `Type of change` の該当チェックボックスにチェックを入れ、`Changes` 冒頭に `⚠️ BREAKING CHANGE: <内容>` を追記する
- 差分から明確に読み取れない背景は推測せず、`<!-- TODO: 背景を追記してください -->` と記載する
- `Notes for reviewer` に記述すべき内容がない場合はそのセクションを削除する

---

### Step 4: ユーザーへの承認確認

以下の情報をまとめてユーザーに提示し、**明示的な承認を得てから** PR を作成する。

```
## 作成予定のプルリクエスト

**タイトル:** <生成したタイトル>

**ベースブランチ:** <base> ← <current-branch>

**リモート:** <remote-url>

**含まれるコミット:**
<コミット一覧（git log --oneline）>

**変更ファイル:**
<変更ファイル一覧（git diff --stat）>

**PR 説明:**
---
<生成した説明>
---

このまま PR を作成しますか？変更点があれば指示してください。
```

`main` / `master` への直接 PR の場合は以下を追記して注意を促す:

> ⚠️ **注意:** `main`/`master` への直接マージを含む PR です。レビュープロセスを確認してください。

ユーザーが修正を要求した場合は、タイトルや説明を修正して再度提示する。

---

### Step 5: PR の作成

ユーザーが承認したら PR を作成する。

#### GitHub MCP が利用可能な場合（優先）

```
mcp_github_create_pull_request を使用:
- owner: <リポジトリオーナー>
- repo: <リポジトリ名>
- title: <承認済みタイトル>
- body: <承認済み説明>
- head: <現在のブランチ>
- base: <ベースブランチ>
- draft: false（ユーザーが draft を希望した場合は true）
```

> **MCP 利用判定:** 環境に GitHub MCP が設定されている場合（`mcp_github_*` ツールが利用可能）は MCP を優先する。利用不可の場合は `gh` CLI にフォールバックする。

#### gh CLI を使用する場合（フォールバック）

```bash
gh pr create \
  --title "<承認済みタイトル>" \
  --body "$(cat <<'EOF'
<承認済み説明>
EOF
)" \
  --base <ベースブランチ> \
  --head <現在のブランチ>
```

`gh` CLI も利用できない場合はブラウザで開く URL を提示する:

```
https://github.com/<owner>/<repo>/compare/<base>...<head>?quick_pull=1
```

---

### Step 6: 完了報告

PR 作成が完了したら以下を報告する。

```
## PR 作成完了

- **PR URL:** <url>
- **PR 番号:** #<number>
- **タイトル:** <title>
- **ベース:** <base> ← <head>

次のステップ（推奨）:
- レビュアーをアサインする
- ラベルを付与する
- CI の結果を確認する
```

---

## 注意事項

- **PR 作成は必ずユーザー承認後に実行する** — 承認なしに実行しない
- `main` / `master` への直接 PR は強調して警告する
- `.env` / シークレットファイルが差分に含まれる場合は **PR 作成を中止** して警告する
- Draft PR を希望するかどうかをユーザーに確認するか、コンテキストから判断する
- GitHub MCP が利用可能かどうかを最初に確認し、可能な限り MCP を優先する
- ベースブランチへのプッシュが済んでいない場合は、PR 作成前にプッシュを促す
