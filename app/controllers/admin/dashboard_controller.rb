# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    def index
      @articles = Article.where(deleted_at: nil).order(created_at: :desc)
    end
  end
end
