require 'spec_helper'

describe Reason do

  it "has a valid factory" do
    expect(FactoryGirl.build(:reason)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:reason, :code => nil)).not_to be_valid
  end

  it "returns untranslated name" do
    reason = FactoryGirl.build(:reason)
    expect(reason.name).to eq "translation missing: en.docdel.code.reason."+
      reason.code
  end

  it "code is unique" do
    reason = FactoryGirl.create(:reason)
    expect(FactoryGirl.build(:reason, code: reason.code)).not_to be_valid
  end

  it "restrict delete with order_request" do
    reason = FactoryGirl.create(:reason)
    order_request = FactoryGirl.create(:order_request, :reason_id => reason.id)
    assert_raise ActiveRecord::DeleteRestrictionError do
      order_request.reason.destroy
    end
  end

end
