require 'spec_helper'

describe ExternalSystem do
  it "has a valid factory" do
    expect(FactoryGirl.build(:external_system)).to be_valid
  end

  it "fails without code" do
    expect(FactoryGirl.build(:external_system, code: nil)).not_to be_valid
  end

  it "returns untranslated name" do
    external_system = FactoryGirl.build(:external_system)
    expect(external_system.name).to eq "translation missing: en.haitatsu.code"+
      ".external_system."+external_system.code
  end

  it "code is unique" do
    external_system = FactoryGirl.create(:external_system)
    expect(FactoryGirl.build(:external_system, :code =>
      external_system.code)).not_to be_valid
  end

end
