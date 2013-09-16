require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  it "fails without username" do
    expect(FactoryGirl.build(:user, :username => nil)).not_to be_valid
  end

  it "username is unique" do
    user = FactoryGirl.create(:user)
    expect(FactoryGirl.build(:user, :username => user.username)).not_to be_valid
  end

end
