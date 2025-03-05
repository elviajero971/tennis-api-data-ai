// app/javascript/controllers/reset_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset() {
    this.element.reset()
    // Optional: Clear specific fields if needed
    // this.element.querySelector('textarea').value = ''
  }
}