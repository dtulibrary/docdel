require 'spec_helper'

describe Institute do
  it "has a valid factory" do
    expect(FactoryGirl.create(:institute)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:institute, code: nil)).not_to be_valid
  end

  it "code is unique" do
    institute = FactoryGirl.create(:institute)
    expect(FactoryGirl.build(:institute, :code =>
      institute.code)).not_to be_valid
  end

  it "name is code" do
    institute = FactoryGirl.build(:institute)
    expect(institute.name).to eq institute.code
  end

end
