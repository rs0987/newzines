module ApplicationHelper
  def component(name, *args, **kwargs, &block)
    component_class = "#{name.to_s.camelize}Component".constantize

    render(component_class.new(*args, **kwargs), &block)
  end

  def decorate(record)
    decorator_class = "#{record.class.name}Decorator".constantize

    decorator_class.new(record)
  end
end
