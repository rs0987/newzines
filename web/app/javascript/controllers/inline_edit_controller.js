import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.resize()
    this.inputTarget.focus()
    // クリックしたセルの続きから書けるように、カーソルを末尾に置く
    const end = this.inputTarget.value.length
    this.inputTarget.setSelectionRange(end, end)
  }

  // 書いた量に合わせて入力欄の高さを変え、表示していたときと同じ行数のまま編集できるようにする
  resize() {
    this.inputTarget.style.height = "auto"
    this.inputTarget.style.height = `${this.inputTarget.scrollHeight}px`
  }

  submit() {
    if (this.locked) return

    this.element.requestSubmit()
  }

  // ネタには改行を入れず、Enter で保存する
  submitOnEnter(event) {
    // 日本語入力の変換を確定する Enter では送信しない。Safari は isComposing が false のまま keyCode 229 を送ってくるので、両方を見る
    if (event.isComposing || event.keyCode === 229) return

    event.preventDefault()
    this.submit()
  }

  // 保存したあと、入力欄が消えるときの blur でもう一度送信しないようにする
  lock() {
    this.locked = true
  }
}
