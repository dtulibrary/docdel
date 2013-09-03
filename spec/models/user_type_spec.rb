require 'spec_helper'

describe UserType do
  it "has a valid factory" do
    FactoryGirl.create(:user_type).should be_valid
  end

  it "fails without code" do
    FactoryGirl.build(:user_type, code: nil).should_not be_valid
  end

  it "code is unique" do
    user_type = FactoryGirl.create(:user_type)
    FactoryGirl.build(:user_type, code: user_type.code).should_not be_valid
  end

end
