require 'spec_helper'

describe OrderRequest do
  it "has a valid factory" do
    FactoryGirl.build(:order_request).should be_valid
  end

  it "fails without order" do
    FactoryGirl.build(:order_request, order: nil).should_not be_valid
  end

  it "fails without order_status" do
    FactoryGirl.build(:order_request, order_status: nil).should_not be_valid
  end

  it "fails without external_system" do
    FactoryGirl.build(:order_request, external_system: nil).should_not be_valid
  end

end
