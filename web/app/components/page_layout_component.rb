class PageLayoutComponent < ViewComponent::Base
  renders_many :actions

  def initialize(title:)
    @title = title
  end
end
