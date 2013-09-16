require 'spec_helper'

describe UserType do
  it "has a valid factory" do
    expect(FactoryGirl.create(:user_type)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:user_type, code: nil)).not_to be_valid
  end

  it "code is unique" do
    user_type = FactoryGirl.create(:user_type)
    expect(FactoryGirl.build(:user_type, :code =>
      user_type.code)).not_to be_valid
  end

end
