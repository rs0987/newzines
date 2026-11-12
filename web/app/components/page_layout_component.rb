class PageLayoutComponent < ApplicationComponent
  renders_many :breadcrumbs, ->(name, path = nil) {
    path ? link_to(name, path) : tag.span(name, aria: { current: "page" })
  }
  renders_many :actions

  def initialize(title:)
    @title = title
  end
end
