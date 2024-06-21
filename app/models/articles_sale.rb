# frozen_string_literal: true

class ArticlesSale < ApplicationRecord
  belongs_to :sale
  belongs_to :article
end
