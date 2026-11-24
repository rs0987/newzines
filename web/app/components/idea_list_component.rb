class IdeaListComponent < ApplicationComponent
  class TabComponent < ApplicationComponent
    COLORS = {
      info: "[--tab-bg:color-mix(in_oklab,var(--color-info)_25%,var(--color-base-100))] bg-(--tab-bg) text-base-content",
      warning: "[--tab-bg:color-mix(in_oklab,var(--color-warning)_25%,var(--color-base-100))] bg-(--tab-bg) text-base-content"
    }.freeze

    def initialize(name:, path:, color:, current: false)
      @name = name
      @path = path
      @color_class = COLORS.fetch(color)
      @current = current
    end

    def call
      link_to @name, @path,
              class: [ "tab border-base-300 [--tab-border-color:var(--color-base-300)]", @color_class, { "tab-active" => @current } ],
              aria: { current: ("page" if @current) }
    end
  end

  RING_COUNT = 16

  renders_many :tabs, TabComponent
  renders_one :footer
end
