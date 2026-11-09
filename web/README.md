# newzines (Rails アプリ)

## 技術スタック

- Ruby 4.0 / Ruby on Rails
- PostgreSQL 18
- Tailwind CSS
- ホスティング: Render

## 開発環境

開発は VS Code の Dev Container で行います。手元に Ruby や PostgreSQL を入れる必要はありません。

### 前提

- Docker Desktop
- VS Code と拡張機能「[Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)」

### セットアップ

1. VS Code で `web/` フォルダを開きます（リポジトリのルートではありません）
2. コマンドパレットから「Dev Containers: Reopen in Container」を実行します

初回は `bin/setup` が自動で実行され、gem のインストールとデータベースの作成まで行われます。

### 起動

コンテナ内のターミナルで次を実行します。

```sh
bin/dev
```

http://localhost:3000 で開けます。

### コードの整形

Ruby ファイルは、保存時に RuboCop（rubocop-rails-omakase）のルールで自動整形されます。Dev Container を開くと、必要な拡張機能（Ruby LSP）と設定が自動で入ります。
