require 'rails_helper'

RSpec.describe "items/index", type: :view do
  before(:each) do
    assign(:items, [
      Item.create!(
        :product_id => 1,
        :already => 2,
        :remain => 3,
        :hit_number => 4,
        :number_total => 5,
        :number_rand => 6
      ),
      Item.create!(
        :product_id => 1,
        :already => 2,
        :remain => 3,
        :hit_number => 4,
        :number_total => 5,
        :number_rand => 6
      )
    ])
  end

  it "renders a list of items" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
