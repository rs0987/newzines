import { Controller } from "@hotwired/stimulus"

// daisyUI のドロワーを、label ではなく button から開け閉めする
export default class extends Controller {
  static values = { id: String }

  connect() {
    this.sync = this.sync.bind(this)
    this.toggleElement.addEventListener("change", this.sync)
    this.sync()
  }

  disconnect() {
    this.toggleElement.removeEventListener("change", this.sync)
  }

  toggle() {
    this.toggleElement.checked = !this.toggleElement.checked
    this.sync()

    if (this.toggleElement.checked) {
      this.panelElement.querySelector("a, button")?.focus()
    }
  }

  close() {
    this.toggleElement.checked = false
    this.sync()
  }

  sync() {
    if (this.element.matches("button")) {
      this.element.setAttribute("aria-expanded", this.toggleElement.checked)
    }
  }

  get toggleElement() {
    return document.getElementById(this.idValue)
  }

  get panelElement() {
    return document.getElementById(`${this.idValue}-panel`)
  }
}
