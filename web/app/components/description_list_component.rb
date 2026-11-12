class DescriptionListComponent < ApplicationComponent
  renders_many :items, "ItemComponent"

  class ItemComponent < ApplicationComponent
    def initialize(term)
      @term = term
    end

    def call
      tag.div(class: "flex px-4 py-3") do
        tag.dt(@term, class: "w-40 shrink-0 text-base-content/60") + tag.dd(content)
      end
    end
  end
end
