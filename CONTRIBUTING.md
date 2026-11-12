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

## テスト（RSpec）

### `it` の説明文

`it` の説明文は、頭に「それは」を補って読める文にする。「それ」は、いちばん内側の `describe` の対象を指す。

- 主語は `describe` が表しているので、説明文の中で繰り返さない（`describe "slug"` の中なら「slug が」は書かない）
- 迷ったら、英語の「it ...」で考えてから日本語に訳す
