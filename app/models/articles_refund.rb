# frozen_string_literal: true

class ArticlesRefund < ApplicationRecord
  belongs_to :refund
  belongs_to :article
end
