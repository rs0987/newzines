module ApplicationHelper
  def component(name, *args, **kwargs, &block)
    component_class = "#{name.to_s.camelize}Component".constantize

    render(component_class.new(*args, **kwargs), &block)
  end
end
