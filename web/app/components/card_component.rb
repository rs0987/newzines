class CardComponent < ApplicationComponent
  def initialize(title:, color: nil)
    @title = title
    @color = color
  end

  private

  def card_class
    class_names("card card-border bg-base-100 shadow", "border-error/60": error?)
  end

  def title_class
    class_names("card-title", "text-error": error?)
  end

  def error?
    @color == :error
  end
end
