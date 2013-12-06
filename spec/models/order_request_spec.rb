require 'spec_helper'

describe OrderRequest do
  include WebMock::API

  it "has a valid factory" do
    expect(FactoryGirl.build(:order_request)).to be_valid
  end

  it "fails without order" do
    expect(FactoryGirl.build(:order_request, :order => nil)).not_to be_valid
  end

  it "fails without order_status" do
    expect(FactoryGirl.build(:order_request, :order_status =>
      nil)).not_to be_valid
  end

  it "fails without external_system" do
    expect(FactoryGirl.build(:order_request, :external_system =>
      nil)).not_to be_valid
  end

  it "callback fails" do
    stub_request(:get, "http://localhost/callback?status=cancel").
      to_return(:status => 404, :body => "", :headers => {})
    FactoryGirl.create(:order_status, code: 'cancel')
    order_request = FactoryGirl.build(:order_request)
    assert_raise StandardError do
      order_request.cancel
    end
  end

  it "callback unsuccesfull" do
    stub_request(:get, "http://localhost/callback?status=confirm").
      to_return(:status => 404, :body => "", :headers => {})
    FactoryGirl.create(:order_status, code: 'confirm')
    order_request = FactoryGirl.build(:order_request)
    assert_raise StandardError do
      order_request.confirm
    end
  end
end
