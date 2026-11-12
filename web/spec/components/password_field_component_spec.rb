require "rails_helper"

RSpec.describe PasswordFieldComponent, type: :component do
  it "属性のパスワード入力欄を表示する" do
    form = ActionView::Helpers::FormBuilder.new(:administrator, Administrator.new, vc_test_controller.view_context, {})

    html = render_inline(described_class.new(form, :password))

    expect(html.at_css("input[type='password']#administrator_password")).to be_present
  end
end
