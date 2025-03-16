# frozen_string_literal: true

module Admin
  # Do NOT implement edit/update methods, we want to keep
  # articles immutable.
  # If you want to edit an article, create a new one and
  # soft-delete the other.
  class ArticlesController < ApplicationController
    def new
      @article = Article.new
      authorize! :new, @article
    end

    # Do NOT implement edit method, we want to keep articles immutable.
    # If you want to edit an article, create a new one and soft-delete the other.
    def edit
      # :nocov:
      raise
      # :nocov:
    end

    def create
      @article = Article.new(article_params)
      authorize! :create, @article
      if @article.save
        flash[:success] = "Article #{article_params[:name]} created!"
        redirect_to admin_path
      else
        render 'new', status: :unprocessable_entity
      end
    end

    # Do NOT implement update method, we want to keep articles immutable.
    # If you want to edit an article, create a new one and soft-delete the other.
    def update
      # :nocov:
      raise
      # :nocov:
    end

    def destroy
      @article = Article.find(params[:id])
      authorize! :destroy, @article
      # Try to destroy (if there is no associated sale/refund),
      # else soft-delete to keep current sales immutable (not
      # change article price on past sales)
      @article.destroy or @article.soft_delete
      redirect_to admin_path
    end

    def article_params
      params.require(:article).permit(:price, :name)
    end
  end
end
