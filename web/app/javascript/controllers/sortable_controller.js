import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "form"]

  // 行全体を常に draggable にすると、行の中のリンクや文字を選べなくなるので、ハンドルを押したときだけ有効にする
  grab(event) {
    this.grabbedRow = event.currentTarget.closest("tr")
    this.grabbedRow.draggable = true
  }

  release() {
    if (!this.grabbedRow) return

    this.grabbedRow.draggable = false
    this.grabbedRow = null
  }

  start(event) {
    // 行の中のリンクをドラッグしたときも dragstart が行まで伝わってくるので、ハンドルからのドラッグ以外は扱わない
    if (!event.currentTarget.draggable) return

    this.draggingRow = event.currentTarget
    this.originalIds = this.#pageIds()
    event.dataTransfer.effectAllowed = "move"
    // Firefox は、データを何もセットしないとドラッグが始まらないので、空の値をセットする
    event.dataTransfer.setData("text/plain", "")
  }

  over(event) {
    if (!this.draggingRow) return

    event.preventDefault()
    const row = event.currentTarget
    if (row === this.draggingRow) return

    // 行に重なったら必ずその前に入れると、入れた途端に行が入れ替わって行ったり来たりするので、上半分なら前、下半分なら後ろに入れる
    const { top, height } = row.getBoundingClientRect()
    const isUpperHalf = event.clientY < top + height / 2
    row.parentElement.insertBefore(this.draggingRow, isUpperHalf ? row : row.nextElementSibling)
  }

  drop(event) {
    event.preventDefault()
  }

  end() {
    if (!this.draggingRow) return

    this.release()
    this.draggingRow = null

    const ids = this.#pageIds()
    if (ids.join() === this.originalIds.join()) return

    this.#submit(ids)
  }

  #pageIds() {
    return this.rowTargets.map((row) => row.dataset.pageId)
  }

  #submit(ids) {
    for (const id of ids) {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "page_ids[]"
      input.value = id
      this.formTarget.append(input)
    }

    this.formTarget.requestSubmit()
  }
}
