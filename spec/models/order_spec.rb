require 'spec_helper'

describe Order do
  it "has a valid factory" do
    FactoryGirl.build(:order).should be_valid
  end

  it "fails without email" do
    FactoryGirl.build(:order, email: nil).should_not be_valid
  end

  it "fails without callback url" do
    FactoryGirl.build(:order, callback_url: nil).should_not be_valid
  end

  it "finds current request" do
    order = FactoryGirl.create(:order)
    req1 = FactoryGirl.create(:order_request, order: order)
    sleep 1
    req2 = FactoryGirl.create(:order_request, order: order)
    order.current_request.should eq req2
  end

end
