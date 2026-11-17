module NormalizesLineBreaks
  extend ActiveSupport::Concern

  class_methods do
    # ブラウザの maxlength は改行を 1 文字と数えるが、送信される値の改行は \r\n で 2 文字になる。
    # そのままだと、入力欄では上限内だったのに長さのバリデーションで弾かれるので、\n にそろえる
    def normalizes_line_breaks(*attributes)
      normalizes(*attributes, with: ->(text) { text.gsub("\r\n", "\n") })
    end
  end
end
