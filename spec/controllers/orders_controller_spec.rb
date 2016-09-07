require 'spec_helper'

describe OrdersController do

  describe "GET #show" do
    it "renders view" do
      order = FactoryGirl.create(:order)
      get :show, :id => order
      expect(response.status).to be(200)
      expect(response.header['Content-Type']).to include 'text/html'
      expect(response).to render_template :show
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
         "Issue%20not%20available:%20Extra%20info&status=cancel&supplier_order_id=1").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
        'order_requests' => { 'reason_id' => 
        @reason.id }, 'reason_text' => 'Extra info'
      expect(response.status).to be(200)
      expect(response.header['Content-Type']).to include 'text/html'
      expect(response).to render_template :not_available
      order = Order.first
      expect(order.current_request.reason_id).to eq @reason.id
      expect(order.current_request.reason_text).to eq 'Extra info'
      expect(order.current_request.format_reason).to eq "Issue not available: "+
        "Extra info"
    end

    it "with reason_id" do
       stub_request(:get, "http://localhost/callback?reason="+
         "Issue%20not%20available&status=cancel&supplier_order_id=1").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
        'order_requests' => { 'reason_id' => 
        @reason.id }
      expect(response.status).to be(200)
      expect(response.header['Content-Type']).to include 'text/html'
      expect(response).to render_template :not_available
      order = Order.first
      expect(order.current_request.reason_id).to eq @reason.id
      expect(order.current_request.reason_text).to be nil
      expect(order.current_request.format_reason).to eq "Issue not available"
    end

    it "with reason_id and reason_text" do
      stub_request(:get, "http://localhost/callback?reason="+
         "Extra%20info&status=cancel&supplier_order_id=1").
         to_return(:status => 200, :body => "", :headers => {})
      post :not_available, :id => @order_request.order.id,
         'order_requests' => { 'reason_id' => ''},
         'reason_text' => 'Extra info'
      expect(response.status).to be(200)
      expect(response.header['Content-Type']).to include 'text/html'
      expect(response).to render_template :not_available
      order = Order.first
      expect(order.current_request.reason_id).to be nil
      expect(order.current_request.reason_text).to eq 'Extra info'
      expect(order.current_request.format_reason).to eq "Extra info"
    end

  end

end
