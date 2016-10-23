require 'rails_helper'

RSpec.describe "items/edit", type: :view do
  before(:each) do
    @item = assign(:item, Item.create!(
      :product_id => 1,
      :already => 1,
      :remain => 1,
      :hit_number => 1,
      :number_total => 1,
      :number_rand => 1
    ))
  end

  it "renders the edit item form" do
    render

    assert_select "form[action=?][method=?]", item_path(@item), "post" do

      assert_select "input#item_product_id[name=?]", "item[product_id]"

      assert_select "input#item_already[name=?]", "item[already]"

      assert_select "input#item_remain[name=?]", "item[remain]"

      assert_select "input#item_hit_number[name=?]", "item[hit_number]"

      assert_select "input#item_number_total[name=?]", "item[number_total]"

      assert_select "input#item_number_rand[name=?]", "item[number_rand]"
    end
  end
end
