# frozen_string_literal: true

class SaleArticleDetail < ApplicationRecord
  belongs_to :sale
  belongs_to :article
end
