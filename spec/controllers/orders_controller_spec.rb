require 'spec_helper'

describe OrdersController do

  describe "GET #show" do
    it "renders view" do
      order = FactoryGirl.create(:order)
      get :show, :id => order
      response.status.should be(200)
      response.header['Content-Type'].should include 'text/html'
      response.should render_template :show
    end
  end

  describe "POST #not_available" do
    before :each do
      @external_system = FactoryGirl.create(:external_system,
        :code => 'local_scan')
      @order_request = FactoryGirl.create(:order_request,
        :external_system => @external_system)
      @reason = FactoryGirl.create(:reason, :code => 'not_avail')
      FactoryGirl.create(:order_status, :code => 'cancel')
    end

    it "with reason_id and reason_text" do
      stub_request(:get, "http://localhost/callback?reason="+
         "Issue%20not%20available:%20Extra%20info&status=cancel").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
        'order_requests' => { 'reason_id' => 
        @reason.id }, 'reason_text' => 'Extra info'
      response.status.should be(200)
      response.header['Content-Type'].should include 'text/html'
      response.should render_template :not_available
      order = Order.first
      order.current_request.reason_id.should eq @reason.id
      order.current_request.reason_text.should eq 'Extra info'
      order.current_request.format_reason.should eq "Issue not available: "+
        "Extra info"
    end

    it "with reason_id" do
       stub_request(:get, "http://localhost/callback?reason="+
         "Issue%20not%20available&status=cancel").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
        'order_requests' => { 'reason_id' => 
        @reason.id }
      response.status.should be(200)
      response.header['Content-Type'].should include 'text/html'
      response.should render_template :not_available
      order = Order.first
      order.current_request.reason_id.should eq @reason.id
      order.current_request.reason_text.should be nil
      order.current_request.format_reason.should eq "Issue not available"
    end

    it "with reason_id and reason_text" do
      stub_request(:get, "http://localhost/callback?reason="+
         "Extra%20info&status=cancel").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
         'order_requests' => { 'reason_id' => ''},
         'reason_text' => 'Extra info'
      response.status.should be(200)
      response.header['Content-Type'].should include 'text/html'
      response.should render_template :not_available
      order = Order.first
      order.current_request.reason_id.should be nil
      order.current_request.reason_text.should eq 'Extra info'
      order.current_request.format_reason.should eq "Extra info"
    end

  end

end
