class DescriptionListComponent < ApplicationComponent
  renders_many :items, "ItemComponent"

  class ItemComponent < ApplicationComponent
    def initialize(term)
      @term = term
    end

    def call
      tag.div(class: "flex flex-col px-4 py-3 sm:flex-row") do
        tag.dt(@term, class: "shrink-0 text-base-content/60 sm:w-40") + tag.dd(content)
      end
    end
  end
end
