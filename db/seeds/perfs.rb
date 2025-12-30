# frozen_string_literal: true

puts '🔥 Seeding heavy dataset...'

NOW = Time.current

CLIENT_COUNT    = 10_000
SELLER_COUNT    = 30
PAYMENT_METHODS = 4
ARTICLES_COUNT  = 3
SALES_COUNT     = 60_000

# -------------------------------------------------
# Helpers
# -------------------------------------------------

def random_date(range = 12.months)
  NOW - rand(range)
end

def rand_quantity
  rand(1..3)
end

# -------------------------------------------------
# Users
# -------------------------------------------------

puts '👤 Creating users...'

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

puts '💳 Creating payment methods...'

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

puts '📦 Creating articles...'

articles = Array.new(ARTICLES_COUNT) do |i|
  {
    name: "Article #{i}",
    price_cents: rand(500..10_000),
    created_at: NOW,
    updated_at: NOW
  }
end

Article.insert_all!(articles)
article_ids = Article.pluck(:id)

# -------------------------------------------------
# Subscription offers
# -------------------------------------------------

puts '📆 Creating subscription offers...'

subscription_offers = [1, 3, 6, 12, 18, 24].map do |months|
  {
    duration: months,
    price_cents: months * rand(800..1_500),
    created_at: NOW,
    updated_at: NOW
  }
end

SubscriptionOffer.insert_all!(subscription_offers)
subscription_offer_ids = SubscriptionOffer.pluck(:id)

# -------------------------------------------------
# Invoices
# -------------------------------------------------

def next_invoice_id
  @invoice_seq ||= Invoice.maximum(:id).to_i
  @invoice_seq += 1
end

puts '🧾 Creating invoices...'

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

puts '🛒 Creating sales...'

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
# Articles sales (FIXED)
# -------------------------------------------------

puts '📦 Linking articles to sales...'

articles_sales = []

sale_ids.each do |sale_id|
  article_ids
    .sample(rand(1..ARTICLES_COUNT)) # 🔑 UNIQUES
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

puts '📆 Linking subscriptions to sales...'

subscriptions_sales = sale_ids.sample(SALES_COUNT / 2).map do |sale_id|
  {
    sale_id: sale_id,
    subscription_offer_id: subscription_offer_ids.sample,
    quantity: 1
  }
end

SalesSubscriptionOffer.insert_all!(subscriptions_sales)

puts '✅ Heavy seed done!'
