class PublicPageLayoutComponent < ApplicationComponent
  renders_one :description

  def initialize(title:)
    @title = title
  end
end
