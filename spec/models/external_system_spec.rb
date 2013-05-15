require 'spec_helper'

describe ExternalSystem do
  it "has a valid factory" do
    FactoryGirl.build(:external_system).should be_valid
  end

  it "fails without code" do
    FactoryGirl.build(:external_system, code: nil).should_not be_valid
  end

  it "returns untranslated name" do
    external_system = FactoryGirl.build(:external_system)
    external_system.name.should eq "translation missing: en.haitatsu.code.external_system."+external_system.code
  end

  it "code is unique" do
    external_system = FactoryGirl.create(:external_system)
    FactoryGirl.build(:external_system, code: external_system.code).should_not be_valid
  end

end
