class PublicPageLayoutComponent < ApplicationComponent
  renders_one :back, ->(name, path) {
    link_to(path, class: "btn btn-ghost btn-sm") do
      safe_join([ tag.span("‹", aria: { hidden: true }), "#{name}に戻る" ], " ")
    end
  }
  renders_many :actions
  renders_one :description

  def initialize(title:)
    @title = title
  end
end
