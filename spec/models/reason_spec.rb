require 'spec_helper'

describe Reason do

  it "has a valid factory" do
    FactoryGirl.build(:reason).should be_valid
  end

  it "fails without code" do
    FactoryGirl.build(:reason, code: nil).should_not be_valid
  end

  it "returns untranslated name" do
    reason = FactoryGirl.build(:reason)
    reason.name.should eq "translation missing: en.haitatsu.code.reason."+
      reason.code
  end

  it "code is unique" do
    reason = FactoryGirl.create(:reason)
    FactoryGirl.build(:reason, code: reason.code).should_not be_valid
  end

  it "restrict delete with order_request" do
    reason = FactoryGirl.create(:reason)
    order_request = FactoryGirl.create(:order_request, :reason_id => reason.id)
    assert_raise ActiveRecord::DeleteRestrictionError do
      order_request.reason.destroy
    end
  end

end
