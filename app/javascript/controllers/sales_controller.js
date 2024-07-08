// Example: https://gorails.com/episodes/dynamic-nested-forms-with-stimulus-js
// https://github.com/gorails-screencasts/dynamic-nested-forms-with-stimulusjs/commit/06a69e33f81ee24b1042931adcd56148b44e88d8

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sales"
export default class extends Controller {
  static targets = ["articleTemplate", "articles", "subscription"]

  initialize() {
    this.nextId = 1;
  }

  connect() {}

  addArticle() {
    const newArticle = this.articleTemplateTarget//.content.cloneNode(true)
    // newArticle.getElementById("sale_article_id_new").id = `sale_article_id_${this.nextId}`
    // newArticle.getElementById("sale_quantity_new").id = `sale_quantity_${this.nextId}`
    const content = newArticle.innerHTML.replace(/NEW_ARTICLE/g, this.nextId)
    let insertAfter = this.articlesTargets.length !== 0 ? this.articlesTargets : this.subscriptionTargets
    insertAfter.at(-1).insertAdjacentHTML("afterend", content)
    this.nextId++
  }

  /**
   * @param event {Event}
   */
  removeArticle(event) {
    event.currentTarget.closest("div").remove()
  }
}
