// app/javascript/controllers/auto_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.scrollToBottom()
        this.observer = new MutationObserver(() => this.scrollToBottom())
        this.observer.observe(this.element, { childList: true, subtree: true })
    }

    disconnect() {
        this.observer?.disconnect()
    }

    scrollToBottom() {
        window.requestAnimationFrame(() => {
            const options = {
                top: document.body.scrollHeight,
                behavior: 'smooth'
            }

            // Either full page scroll:
            window.scrollTo(options)

            // Or container scroll (if using overflow):
            // this.element.scrollTop = this.element.scrollHeight
        })
    }
}