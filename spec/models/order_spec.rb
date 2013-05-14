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
end
