require 'spec_helper'

describe Order do
  it "has a valid factory" do
    expect(FactoryGirl.build(:order)).to be_valid
  end

  it "fails without email" do
    expect(FactoryGirl.build(:order, email: nil)).not_to be_valid
  end

  it "fails without callback url" do
    expect(FactoryGirl.build(:order, callback_url: nil)).not_to be_valid
  end

  it "finds current request" do
    order = FactoryGirl.create(:order)
    req1 = FactoryGirl.create(:order_request, order: order)
    sleep 1
    req2 = FactoryGirl.create(:order_request, order: order)
    expect(order.current_request).to eq req2
  end

end
