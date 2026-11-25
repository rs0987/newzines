# コードのルール

## 何をどこに書くか

| 書く場所 | 書くこと |
| --- | --- |
| コード | How |
| テストコード | What |
| コミットログ | Why |
| コードコメント | Why not |

## フロントエンド

- 画面の部品は [ViewComponent](https://viewcomponent.org) で `web/app/components/` に作る
- スタイルは Tailwind CSS と daisyUI のクラスで書く
- ビューからは `render` ではなく、`component` ヘルパーで呼び出す

```erb
<%# NG %>
<%= render TitleBarComponent.new(title: "スタジオ一覧") %>

<%# OK %>
<%= component :title_bar, title: "スタジオ一覧" %>
```

## マイグレーション

### 既存のテーブルを変えるとき

メンテナンス時間を取らずにリリースするので、既存の列やテーブルを壊す変更は Expand and Contract（Parallel Change）で、リリースを分けて進める。

- マイグレーションとアプリの切り替わりにはタイムラグがあり、古いアプリが新しいスキーマで動く時間や、その逆の時間があるため
- 列の改名・削除、NOT NULL の追加、型の変更などは、1 回のリリースで済ませない

| リリース | やること |
| --- | --- |
| 1. Expand | 新しい列やテーブルを、NULL 可・デフォルト無しで足すだけにする。アプリのコードは変えない |
| 2. 両方に書く | アプリを新旧両方に書き込むようにする。既存のデータは一度だけのバッチ処理で新しい列にコピーする（[バッチ処理](#バッチ処理)） |
| 3. 読み先を変える | アプリを新しい列だけを読むようにして、古い列は `ignored_columns` で見なくする |
| 4. Contract | 古い列を消して、NOT NULL・デフォルト・チェック制約などを付ける |

- 1 のリリースでアプリのコードも変えると、アプリが先に動いたときに、まだ無い列を読みにいってしまう
- 3 を挟まずに 4 をすると、起動中のアプリが覚えている古い列を読みにいってしまう
- 一度だけのバッチ処理は、4 のリリースでスペックと一緒に消す（NOT NULL を付けた時点で、埋めるデータが無くなるため）

### インデックス

インデックスは `add_index` ではなく、`create_table` や `change_table` のブロックの中に `t.index` で書く。

- インデックスも、別の操作ではなく同じテーブルの定義の一部だと読み取れるようにするため
- Rails 5.0 以降の `schema.rb` と同じ書き方にそろえ、見比べやすくするため
- 実行済みのマイグレーションは書き換えない（すでにデータベースを作った環境と食い違うため）

```ruby
# NG
create_table :ideas do |t|
  t.references :studio, null: false, foreign_key: true, index: false
  t.datetime :archived_at
end

add_index :ideas, %i[studio_id archived_at]

# OK
create_table :ideas do |t|
  t.references :studio, null: false, foreign_key: true, index: false
  t.datetime :archived_at
  t.index %i[studio_id archived_at]
end

# 既存のテーブルに足すときも change_table の中に書く
change_table :pages do |t|
  t.index %i[zine_id position]
end
```

## バッチ処理

バッチ処理は rake タスクで書く。

### 一度だけ流すもの

データの移行など、一度だけ流すタスクは `lib/tasks/temporary/` に置き、`temporary:` の名前空間を付ける。

- 名前空間で一時的なものだと分かり、消し忘れを探しやすくするため
- 役目が終わったら、スペックと一緒に消す

### 書き方

- 何度流しても結果が変わらないようにする（処理がまだ済んでいないレコードだけを対象にする）
  - 途中で止まっても、そのまま流し直せるようにするため
- 最初に対象の件数を、処理中は何件目かとレコードの id を出力する
  - 進捗と、止まったときにどこまで進んだかを知るため
- レコードは `find_each` で少しずつ読む（一度にすべてをメモリに載せないため）
- タスクの前に、実行するコマンドをコメントで書く（そのままコピーして流せるようにするため）
- 1 件ごとの処理はモデルのメソッドに書き、テストはモデルスペックに書く。タスクは対象を選ぶことと出力だけにする
  - タスクのスペックは、タスクの読み込みが重なるなど書きにくいため
  - 一度だけ流すもののメソッドは、タスクと一緒に消す

```ruby
namespace :temporary do
  # bundle exec rake temporary:backfill_invitation_inviter_administrator
  desc "既存の招待の inviter_id を inviter_administrator_id にコピーする"
  task backfill_invitation_inviter_administrator: :environment do
    invitations = Invitation.where(inviter_administrator_id: nil)
    total = invitations.count
    puts "#{total} 件の招待を処理します"

    invitations.find_each.with_index(1) do |invitation, index|
      puts "[#{index}/#{total}] Invitation id=#{invitation.id}"
      invitation.backfill_inviter_administrator!
    end

    puts "完了しました"
  end
end
```

```ruby
class Invitation < ApplicationRecord
  # 一時的なバッチ処理用。temporary:backfill_invitation_inviter_administrator と一緒に消す
  def backfill_inviter_administrator!
    update!(inviter_administrator: inviter)
  end
end
```

## テスト（RSpec）

### `it` の説明文

`it` の説明文は、頭に「それは」を補って読める文にする。「それ」は、いちばん内側の `describe` の対象を指す。

- 主語は `describe` が表しているので、説明文の中で繰り返さない（`describe "slug"` の中なら「slug が」は書かない）
- 迷ったら、英語の「it ...」で考えてから日本語に訳す
