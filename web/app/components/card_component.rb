class CardComponent < ApplicationComponent
  renders_many :actions

  def initialize(title:, color: nil)
    @title = title
    @color = color
  end

  private

    def card_class
      class_names("card bg-base-100 shadow", "card-border border-error/30": error?)
    end

    def title_class
      class_names("card-title", "text-error": error?)
    end

    def error?
      @color == :error
    end
end
