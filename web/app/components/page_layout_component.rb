class PageLayoutComponent < ApplicationComponent
  renders_many :actions

  def initialize(title:)
    @title = title
  end
end
