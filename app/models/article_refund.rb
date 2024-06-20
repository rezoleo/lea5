# frozen_string_literal: true

class ArticleRefund < ApplicationRecord
  belongs_to :refund
  belongs_to :article
end
