# frozen_string_literal: true

class ArticleSale < ApplicationRecord
  belongs_to :sale
  belongs_to :article
end
