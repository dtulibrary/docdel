require 'spec_helper'

describe OrderRequest do
  include WebMock::API

  it "has a valid factory" do
    FactoryGirl.build(:order_request).should be_valid
  end

  it "fails without order" do
    FactoryGirl.build(:order_request, order: nil).should_not be_valid
  end

  it "fails without order_status" do
    FactoryGirl.build(:order_request, order_status: nil).should_not be_valid
  end

  it "fails without external_system" do
    FactoryGirl.build(:order_request, external_system: nil).should_not be_valid
  end

  it "callback fails" do
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
