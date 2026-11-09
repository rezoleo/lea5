# frozen_string_literal: true

# Self-service migration from re2o: the logged-in user proves they own a re2o account, then claims it.
class MigrationsController < ApplicationController
  before_action :require_login, except: [:show, :link]

  rate_limit to: 10, within: 1.hour, only: [:claim, :send_link], name: 'per-user',
             by: -> { current_user.id }, with: -> { too_many_attempts }
  rate_limit to: 5, within: 1.hour, only: [:claim, :send_link], name: 'per-account',
             by: -> { params[:identifier].to_s.strip.downcase }, with: -> { too_many_attempts }
  rate_limit to: 30, within: 1.minute, only: :lookup, by: -> { current_user.id }, with: -> { head :too_many_requests }

  def show
    return unless logged_in?

    @account = current_user.re2o_account
    # Play the import animation once, right after the claim
    @animate = session.delete(:migration_just_claimed)
    @email_match = Re2oAccount.unclaimed.find_by(email: current_user.email) if @account.nil?
  end

  # Landing page of the emailed link. It only shows a button: mail scanners prefetch GET links.
  def link
    @token = params[:token]
    @account = Re2oAccount.find_by_token_for(:claim, @token)
  end

  def claim
    account = proven_account
    if account.nil?
      flash[:error] = "We couldn't verify this re2o account."
      return redirect_to migration_path
    end

    account.claim!(current_user)
    session[:migration_just_claimed] = true
    redirect_to migration_path
  rescue Re2oAccount::ClaimError => e
    flash[:error] = e.message
    redirect_to migration_path
  end

  # Masked email of a re2o account, shown under the password field
  def lookup
    render json: { masked_email: Re2oAccount.lookup(params[:identifier])&.masked_email }
  end

  def send_link
    account = Re2oAccount.lookup(params[:identifier])
    if account.nil?
      flash[:error] = 'No re2o account with this username.'
    elsif account.email.blank?
      flash[:error] = 'This re2o account has no email. Use your password, or come see us at the helpdesk.'
    else
      Re2oMigrationMailer.with(account: account, token: account.generate_token_for(:claim)).claim_link.deliver_later
      flash[:success] = "We sent a link to #{account.masked_email}. Open it in this browser, while logged in."
    end
    redirect_to migration_path
  end

  # Helpdesk: an admin links a re2o account to a user by hand
  def admin_claim
    authorize! :manage, :all
    user = User.find_by!(username: params[:username])
    account = Re2oAccount.unclaimed.find_by(pseudo: params[:pseudo].to_s.strip.downcase)
    if account
      account.claim!(user)
      flash[:success] = "re2o account #{account.pseudo} migrated."
    else
      flash[:error] = 'No unclaimed re2o account with this pseudo.'
    end
    redirect_to user
  rescue Re2oAccount::ClaimError => e
    flash[:error] = e.message
    redirect_to user
  end

  private

  def proven_account
    if params[:token].present?
      Re2oAccount.find_by_token_for(:claim, params[:token])
    elsif params[:password].present?
      account = Re2oAccount.lookup(params[:identifier])
      account if account&.password_matches?(params[:password])
    else
      # The SSO verifies emails, so an exact match is proof enough
      Re2oAccount.unclaimed.find_by(email: current_user.email)
    end
  end

  def require_login
    return if logged_in?

    flash[:error] = 'Please log in first.'
    redirect_to migration_path
  end

  def too_many_attempts
    flash[:error] = 'Too many attempts, please try again later.'
    redirect_to migration_path
  end
end
