import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["duration", "price"]
    currencyFormatter = new Intl.NumberFormat('fr-FR', {style: 'currency', currency: 'EUR'});
    yearPrice = 5000;
    monthPrice = 500;

    connect() {
        this.updatePrice()
    }

    updatePrice() {
        this.priceTarget.textContent = this.currencyFormatter.format(this.totalPrice / 100)
    }

    get duration() {
        return this.durationTarget.value;
    }

    get totalPrice() {
        // TODO: Make sure client-side and server-side pricing logic is in sync
        const numberOfYears = Math.trunc(this.duration / 12);
        const remainderOfMonths = this.duration % 12;
        return numberOfYears * this.yearPrice + Math.min(remainderOfMonths, 10) * this.monthPrice;
    }
}
