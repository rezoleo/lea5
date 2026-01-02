# frozen_string_literal: true

Rails.logger.info 'Seeding heavy dataset...'

NOW = Time.current

CLIENT_COUNT    = 3_000
SELLER_COUNT    = 30
PAYMENT_METHODS = 4
ARTICLES_COUNT  = 3
SALES_COUNT     = 10_000

def random_date(range = 12.months)
  NOW - rand(range)
end

def rand_quantity
  rand(1..3)
end

# -------------------------------------------------
# Users
# -------------------------------------------------

Rails.logger.info 'Creating users...'

clients = Array.new(CLIENT_COUNT) do |i|
  {
    firstname: "Client#{i}",
    lastname: 'Test',
    email: "client#{i}@test.local",
    username: "client#{i}",
    wifi_password: SecureRandom.hex(6),
    created_at: NOW,
    updated_at: NOW
  }
end

User.insert_all!(clients)
client_ids = User.order(:id).limit(CLIENT_COUNT).pluck(:id)

sellers = Array.new(SELLER_COUNT) do |i|
  {
    firstname: "Seller#{i}",
    lastname: 'Test',
    email: "seller#{i}@test.local",
    username: "seller#{i}",
    wifi_password: SecureRandom.hex(6),
    created_at: NOW,
    updated_at: NOW
  }
end

User.insert_all!(sellers)
seller_ids = User.order(:id).offset(CLIENT_COUNT).limit(SELLER_COUNT).pluck(:id)

# -------------------------------------------------
# Payment methods
# -------------------------------------------------

Rails.logger.info 'Creating payment methods...'

payment_methods = Array.new(PAYMENT_METHODS) do |i|
  {
    name: "Payment #{i}",
    auto_verify: i.even?,
    created_at: NOW,
    updated_at: NOW
  }
end

PaymentMethod.insert_all!(payment_methods)
payment_method_ids = PaymentMethod.pluck(:id)

# -------------------------------------------------
# Articles
# -------------------------------------------------

Rails.logger.info 'Creating articles...'

articles = Array.new(ARTICLES_COUNT) do |i|
  {
    name: "Article #{i}",
    price_cents: rand(100..5_000),
    created_at: NOW,
    updated_at: NOW
  }
end

Article.insert_all!(articles)
article_ids = Article.pluck(:id)

# -------------------------------------------------
# Subscription offers
# -------------------------------------------------

Rails.logger.info 'Creating subscription offers...'

subscription_offers = [
  {
    duration: 1,
    price_cents: 500,
    created_at: NOW,
    updated_at: NOW
  },
  {
    duration: 12,
    price_cents: 5_000,
    created_at: NOW,
    updated_at: NOW
  }
]

SubscriptionOffer.insert_all!(subscription_offers)
subscription_offer_ids = SubscriptionOffer.pluck(:id)

# -------------------------------------------------
# Invoices
# -------------------------------------------------

def next_invoice_id
  @invoice_seq ||= Invoice.maximum(:id).to_i
  @invoice_seq += 1
end

Rails.logger.info 'Creating invoices...'

invoices = Array.new(SALES_COUNT) do
  {
    id: next_invoice_id,
    generation_json: { generated: true },
    created_at: NOW,
    updated_at: NOW
  }
end

Invoice.insert_all!(invoices)
invoice_ids = Invoice.pluck(:id)

# -------------------------------------------------
# Sales
# -------------------------------------------------

Rails.logger.info 'Creating sales...'

sales = Array.new(SALES_COUNT) do
  created_at = random_date

  {
    client_id: client_ids.sample,
    seller_id: seller_ids.sample,
    payment_method_id: payment_method_ids.sample,
    invoice_id: invoice_ids.sample,
    verified_at: rand < 0.8 ? created_at + rand(1..48).hours : nil,
    created_at: created_at,
    updated_at: created_at
  }
end

Sale.insert_all!(sales)
sale_ids = Sale.pluck(:id)

# -------------------------------------------------
# Articles sales
# -------------------------------------------------

Rails.logger.info 'Linking articles to sales...'

articles_sales = []

sale_ids.each do |sale_id|
  article_ids
    .sample(rand(1..ARTICLES_COUNT))
    .each do |article_id|
    articles_sales << {
      sale_id: sale_id,
      article_id: article_id,
      quantity: rand_quantity
    }
  end
end

ArticlesSale.insert_all!(articles_sales)

# -------------------------------------------------
# Subscription sales
# -------------------------------------------------

Rails.logger.info 'Linking subscriptions to sales...'

subscriptions_sales = sale_ids.sample(SALES_COUNT / 2).map do |sale_id|
  {
    sale_id: sale_id,
    subscription_offer_id: subscription_offer_ids.sample,
    quantity: rand_quantity
  }
end

SalesSubscriptionOffer.insert_all!(subscriptions_sales)

Rails.logger.info 'Heavy seed done!'
