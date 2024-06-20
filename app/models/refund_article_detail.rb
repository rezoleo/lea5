# frozen_string_literal: true

class RefundArticleDetail < ApplicationRecord
  belongs_to :refund
  belongs_to :article
end
