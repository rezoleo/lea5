# frozen_string_literal: true

module Admin
  class ArticlesController < ApplicationController
    def new
      @article = Article.new
      authorize! :new, @article
    end

    def create
      @article = Article.new(name: article_params[:name], price: article_params[:price])
      authorize! :create, @article
      if @article.save
        flash[:success] = "Article #{article_params[:name]} created!"
        redirect_to admin_path
      else
        render 'new', status: :unprocessable_entity
      end
    end

    def destroy
      @article = Article.find(params[:id])
      authorize! :destroy, @article
      @article.soft_delete unless @article.destroy
      redirect_to admin_path
    end

    def article_params
      params.require(:article).permit(:price, :name)
    end
  end
end
