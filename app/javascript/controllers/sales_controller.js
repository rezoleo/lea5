// Example: https://gorails.com/episodes/dynamic-nested-forms-with-stimulus-js
// https://github.com/gorails-screencasts/dynamic-nested-forms-with-stimulusjs/commit/06a69e33f81ee24b1042931adcd56148b44e88d8

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sales"
export default class extends Controller {
  static targets = ["articleTemplate", "articles", "totalPrice", "subPrice", "subscription"]

  initialize() {
    this.nextId = 1;
  }

  connect() {
    this.articles = {}
    const articles = JSON.parse(this.element.dataset.articles)
    articles.forEach(e => {
      this.articles[e.id] = e.price
    })
    this.subscription_offers = JSON.parse(this.element.dataset.subscriptions)
  }

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
    this.updateTotalPrice()
  }

  updateTotalPrice() {
    let price = 0
    let articles = this.articlesTargets
    articles.forEach(e => {
      let id = Number.parseInt(e.querySelector('select').value)
      let quantity = Number.parseInt(e.querySelector('input').value)
      if (id && quantity) price += this.articles[id] * quantity
    })
    price += Number.parseFloat(this.subPriceTarget.textContent) * 100
    this.totalPriceTarget.textContent = (price / 100).toFixed(2).toLocaleString()
  }

  /**
   * @param event {Event}
   */
  updateSubPrice(event) {
    let sub = Number.parseInt(event.currentTarget.value)
    let price = 0
    this.subscription_offers.forEach(e => {
      let quantity = Math.floor(sub / e.duration)
      sub -= quantity * e.duration
      price += e.price * quantity
    })
    this.subPriceTarget.textContent = (price / 100).toFixed(2).toLocaleString()
    this.updateTotalPrice()
  }

  testUpdate() {
    console.log("test")
  }
}
