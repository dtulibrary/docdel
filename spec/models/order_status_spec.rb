require 'spec_helper'

describe OrderStatus do
  it "has a valid factory" do
    FactoryGirl.build(:order_status).should be_valid
  end

  it "fails without code" do
    FactoryGirl.build(:order_status, code: nil).should_not be_valid
  end

  it "returns untranslated name" do
    order_status = FactoryGirl.build(:order_status)
    order_status.name.should eq "translation missing: en.haitatsu.code.order_status."+order_status.code
  end

  it "code is unique" do
    order_status = FactoryGirl.create(:order_status)
    FactoryGirl.build(:order_status, code: order_status.code).should_not be_valid
  end

end
