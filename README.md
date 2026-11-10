# NewZINES

**テーマで集まって1冊を作る**

NewZINES は、テーマのもとに書き手が集まって ZINE を作るサービスです。

書き手はテーマのもとにスタジオを作って集まり、ZINE を発行します。ZINE ごとに書き手が集まり、テーマに沿った記事が一冊にまとまっていきます。

読者は、人ではなくテーマで ZINE を選んで読めます。

## このリポジトリについて

転職活動のポートフォリオとして、一人で開発しています。チームで開発することを想定し、Issue と Pull Request を使って進めています。

Rails アプリは `web/` にあります。技術スタック、開発環境の手順、用語集は [web/README.md](web/README.md) を参照してください。

## 開発での AI 利用について

開発では [Claude Code](https://code.claude.com/docs/ja/overview) を、ホストから隔離した Docker コンテナの中で使っています。

- Claude Code がアクセスできるのは、このリポジトリ（`/workspace` にマウント）だけです。ホストのファイルや認証情報にはアクセスできません
- コマンドの実行（Bash）は禁止しています。Claude Code が行うのはコードの読み書きだけです
- `.env` や `*.key` などの秘密情報は、読み取りも編集も禁止しています（`.claude/settings.json`）
- Claude Code が書いたコードはすべて自分でレビューしています。テストの実行とコミットは自分で行います

## Claude Code 環境の使い方

### 前提

- Docker Desktop

### 起動

```sh
docker compose up -d
```

### Claude Code を使う

```sh
docker compose exec claude claude
```

初回はログイン用の URL が表示されるので、ブラウザで開いて認証してください。
ログイン情報は Docker ボリューム（`claude-config`）に保存されるので、コンテナを作り直しても残ります。
