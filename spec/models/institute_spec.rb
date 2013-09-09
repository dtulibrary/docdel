require 'spec_helper'

describe Institute do
  it "has a valid factory" do
    FactoryGirl.create(:institute).should be_valid
  end

  it "fails without code" do
    FactoryGirl.build(:institute, code: nil).should_not be_valid
  end

  it "code is unique" do
    institute = FactoryGirl.create(:institute)
    FactoryGirl.build(:institute, code: institute.code).should_not be_valid
  end

  it "name is code" do
    institute = FactoryGirl.build(:institute)
    institute.name.should eq institute.code
  end

end
