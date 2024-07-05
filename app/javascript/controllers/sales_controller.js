// Example: https://gorails.com/episodes/dynamic-nested-forms-with-stimulus-js
// https://github.com/gorails-screencasts/dynamic-nested-forms-with-stimulusjs/commit/06a69e33f81ee24b1042931adcd56148b44e88d8

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sales"
export default class extends Controller {
  static targets = ["articleTemplate", "articles"]

  initialize() {
    // id=1 is in the HTML from the start (we want to add at least one article)
    this.nextId = 2;
  }

  connect() {}

  addArticle() {
    const newArticle = this.articleTemplateTarget//.content.cloneNode(true)
    // newArticle.getElementById("sale_article_id_new").id = `sale_article_id_${this.nextId}`
    // newArticle.getElementById("sale_quantity_new").id = `sale_quantity_${this.nextId}`
    const content = newArticle.innerHTML.replace(/NEW_ARTICLE/g, this.nextId)
    this.articlesTargets.at(-1).insertAdjacentHTML("afterend", content)
    this.nextId++
  }

  /**
   * @param event {Event}
   */
  removeArticle(event) {
    event.currentTarget.closest("div").remove()
  }
}
