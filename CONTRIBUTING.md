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

## テスト（RSpec）

### `it` の説明文

`it` の説明文は、頭に「それは」を補って読める文にする。「それ」は、いちばん内側の `describe` の対象を指す。

- 主語は `describe` が表しているので、説明文の中で繰り返さない（`describe "slug"` の中なら「slug が」は書かない）
- 迷ったら、英語の「it ...」で考えてから日本語に訳す
