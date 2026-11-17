class ZinePageComponent < ApplicationComponent
  def initialize(page:, number:)
    @page = page
    @number = number
  end
end
