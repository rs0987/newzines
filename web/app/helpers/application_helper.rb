module ApplicationHelper
  def component(name, **args, &block)
    component_class = "#{name.to_s.camelize}Component".constantize

    render(component_class.new(**args), &block)
  end
end
