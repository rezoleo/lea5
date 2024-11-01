// Example: https://gorails.com/episodes/dynamic-nested-forms-with-stimulus-js
// https://github.com/gorails-screencasts/dynamic-nested-forms-with-stimulusjs/commit/06a69e33f81ee24b1042931adcd56148b44e88d8

import { Controller } from "@hotwired/stimulus"

const currencyFormatter = new Intl.NumberFormat("fr-FR", {
  style: "currency",
  currency: "EUR",
})

// Connects to data-controller="sales"
export default class extends Controller {
  static targets = [
    "articleTemplate",
    "articles",
    "totalPrice",
    "subPrice",
    "subscription",
    "duration",
  ]

  static values = {
    articles: Object,
    subscriptions: Array,
  }

  initialize() {
    this.nextId = 1;
  }

  connect() {
    this.updatePrice()
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
    this.updatePrice()
  }

  updatePrice() {
    let subPrice = 0
    let price = 0

    let duration = Number.parseInt(this.durationTarget.value)

    this.subscriptionsValue.forEach(subscription => {
      const quantity = Math.floor(duration / subscription.duration)
      duration -= quantity * subscription.duration
      subPrice += subscription.price * quantity
    })
    this.subPriceTarget.textContent = currencyFormatter.format(subPrice / 100)

    this.articlesTargets.forEach(article => {
      let id = Number.parseInt(article.querySelector('select').value, 10)
      let quantity = Number.parseInt(article.querySelector('input').value, 10)
      if (id && quantity) price += this.articlesValue[id] * quantity
    })
    price += subPrice
    this.totalPriceTarget.textContent = currencyFormatter.format(price / 100)
  }
}
