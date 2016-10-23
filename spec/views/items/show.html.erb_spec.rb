require 'rails_helper'

RSpec.describe "items/show", type: :view do
  before(:each) do
    @item = assign(:item, Item.create!(
      :product_id => 1,
      :already => 2,
      :remain => 3,
      :hit_number => 4,
      :number_total => 5,
      :number_rand => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
