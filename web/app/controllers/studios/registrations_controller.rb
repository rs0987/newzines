class Studios::RegistrationsController < ApplicationController
  layout "studio"

  def new
    unless Invitation.pending.find_by_token(params[:token].to_s)
      return redirect_to invalid_studio_registration_path
    end

    @account = Account.new
  end

  def create
    @invitation = Invitation.pending.where(username: account_params[:username]).find_by_token(params[:token].to_s)
    return redirect_to invalid_studio_registration_path unless @invitation

    @account = @invitation.accept(password: account_params[:password])

    if @account.persisted?
      sign_in(@account)
      redirect_to studio_root_path(@invitation.studio.slug), notice: "「#{@invitation.studio.name}」に参加しました"
    else
      render :new, status: :unprocessable_content
    end
  rescue Invitation::NotPendingError
    redirect_to invalid_studio_registration_path
  end

  def invalid
  end

  private

  def account_params
    params.expect(account: %i[username password])
  end
end
