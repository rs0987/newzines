class ZinesController < PublicController
  def show
    @zine = Zine.find(params.expect(:id))
    authorize @zine

    @pages = policy_scope(@zine.pages).includes(writer: :account)
  end
end
