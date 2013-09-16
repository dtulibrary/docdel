require 'spec_helper'

describe OrderStatus do
  it "has a valid factory" do
    expect(FactoryGirl.build(:order_status)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:order_status, code: nil)).not_to be_valid
  end

  it "returns untranslated name" do
    order_status = FactoryGirl.build(:order_status)
    expect(order_status.name).to eq "translation missing: en.haitatsu.code"+
      ".order_status."+order_status.code
  end

  it "code is unique" do
    order_status = FactoryGirl.create(:order_status)
    expect(FactoryGirl.build(:order_status, :code =>
      order_status.code)).not_to be_valid
  end

end
