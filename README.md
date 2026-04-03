# ai-dev-skill-base

生成AIを活用した開発全般で使えるベースのキットやスキルを蓄積していくためのリポジトリ。

Claude 系の設定や運用知見も含めつつ、特定ツールに閉じない形で AI 支援開発の資産を整理していく。

---

## ディレクトリ構成

```
ai-dev-skill-base/
├── .agents/
│   └── skills/               # Claude Code 用カスタムスキル
│       ├── code-review/
│       ├── github-commit-push/
│       ├── github-create-pr/
│       ├── github-pr-review/
│       ├── github-pr-review-response/
│       ├── requirements/
│       └── tech-requirements/
└── personal/
    └── .claude/
        └── CLAUDE.md         # 個人用 Claude 動作指針（テンプレート）
```

---

## スキル一覧（`.agents/skills/`）

| スキル名 | 用途 |
|---|---|
| `code-review` | 品質・可読性・セキュリティ・設計の観点でコードを分析し、優先度別にフィードバックを出力 |
| `github-commit-push` | 変更差分を分析してコミットメッセージを自動提案し、承認後にコミット・プッシュを実行 |
| `github-create-pr` | ブランチ差分を分析して PR タイトル・説明を自動生成し、承認後に PR を作成 |
| `github-pr-review` | PR の差分・CI・コメントを統合して、バグ/リスク/回帰を優先度別に指摘 |
| `github-pr-review-response` | PR レビューコメントへの対応判定・実装・コミット・返信までを安全に実行 |
| `requirements` | 要求・アイデア・課題を分析し、機能要件・非機能要件・受け入れ基準を構造化して出力 |
| `tech-requirements` | インタラクティブなヒアリングで技術スタック・スコープ・制約を収集し、技術要件ドキュメントを生成 |

---

## personal/

個人設定・ナレッジのテンプレート置き場。リポジトリにコミットしたい個人的な Claude 設定や運用ルールを管理する。

- `personal/.claude/CLAUDE.md` — Claude の動作指針（プランモード・サブエージェント戦略・自己改善ループなど）
