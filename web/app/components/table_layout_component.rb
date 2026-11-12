class TableLayoutComponent < ApplicationComponent
  renders_one :pagination, ->(collection) { helpers.paginate(collection) }
end
