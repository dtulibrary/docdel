require 'spec_helper'
require 'nokogiri'

# require the savon helper module
require "savon/mock/spec_helper"

describe Rest::OrdersController do
  render_views

  before :all do
    @open_request = 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3A'+
      'ofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&'+
      'rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Lokhande%2C+'+
      'Ram&rft.atitle=Study+of+some+Indian+medicinal+plants+by+application+of'+
      '+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&rft.issn=21504091&'+
      'rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&rft.pages='+
      '26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
  end

  after :all do
    WebMock.reset!
  end

  describe "POST #create" do
    before :each do
      # Expand Order with bogus handler
      class Order
        def request_from_bogus
          config
        end
      end
      FactoryGirl.create(:external_system, code: 'bogus')
      FactoryGirl.create(:order_status, code: 'new')
    end

    it "create order with author" do
      post :create, :email => 'test@dom.ain', :supplier => 'bogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Lokhande%2C+Ram&rft.atitle=Study+of+some+Indian+medicinal+plants+by+application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
      Order.count.should eq 1
    end

    it "create order with corporation" do
      post :create, :email => 'test@dom.ain', :supplier => 'bogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Test+Corporation&rft.atitle=Study+of+some+Indian+medicinal+plants+by+application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
      Order.count.should eq 1
    end

    it "fails create order" do
      post :create, :email => 'test@dom.ain', :supplier => 'notbogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Test+Corporation&rft.atitle=Study+of+some+Indian+medicinal+plants+by+application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
      Order.count.should eq 0
    end

  end

  describe "ReprintsDesk" do
    include Savon::SpecHelper

    before(:all) do
      savon.mock!
      config = Rails.application.config
      config.order_prefix = 'TEST'
      config.reprintsdesk.wsdl = "spec/fixtures/reprintsdesk/reprints.wsdl"
      config.reprintsdesk.firstname = "Test"
      config.reprintsdesk.lastname = "Test"
      config.reprintsdesk.companyname = "Test"
      config.reprintsdesk.address1 = "Test"
      config.reprintsdesk.city = "Test"
      config.reprintsdesk.zipcode = "9999"
      config.reprintsdesk.countrycode = "XX"
      config.reprintsdesk.systemmail = "test@dom.ain"
      config.reprintsdesk.accounts = {
        'type1' => {
          'user' => "Test1",
          'password' => "Pass1",
          'username' => "Test1",
        },
        'default' => {
          'user' => "Test",
          'password' => "Pass",
          'username' => "Test",
        },
      }
      config.user_url = "http://localhost"
    end
    after(:all) { 
      savon.unmock!
    }

    before :each do
      FactoryGirl.create(:external_system, code: 'reprintsdesk')
      FactoryGirl.create(:order_status, code: 'new')
      FactoryGirl.create(:order_status, code: 'request')
    end

    describe "create order" do
      it "for type1" do
        order = reprintsdesk_create_order(
          '{"user_type":"type1","dtu":{"org_units":["45"]}}', '1', 'Test1')
        order.institute.code.should eq '45'
      end

      it "for others" do
        reprintsdesk_create_order('{"user_type": "other"}', '1', 'Test')
      end

      it "for anon" do
        reprintsdesk_create_order(nil, nil, 'Test')
      end

      def reprintsdesk_create_order(user_response, user_id, username)
        price_request = {:issn=>"21504091", :year=>"2010", :totalpages=>1}
        price_response = File.read("spec/fixtures/reprintsdesk/price_response.xml")
        order_request = ERB.new(
          File.read("spec/fixtures/reprintsdesk/order_request.xml")).result binding()

        order_response = File.read("spec/fixtures/reprintsdesk/order_response.xml")

        stub_request(:get, "http://localhost/users/1.json").
          to_return(:status => 200, :body => user_response,
            :headers => {}) if user_response

        savon.expects(:order_get_price_estimate).with(message: price_request).returns(price_response)
        savon.expects(:order_place_order2).with(message: order_request).returns(order_response)
        post :create,
          :email => 'test@dom.ain', :supplier => 'reprintsdesk',
          :callback_url => 'http://testhost/',
          :user_id => user_id,
          :open_url => @open_request
        user = JSON.parse(user_response) if user_response
        Order.count.should eq 1
        # Check that order/request matches what we want.
        order = Order.first
        order.current_request.external_service_charge.should eq 10.0
        order.current_request.external_copyright_charge.should eq -1.0
        order.current_request.external_number.should eq 123456
        order.user_type.code.should eq user['user_type'] if user_response
        order
      end
    end
  end

  describe "Local Scan" do
    before :each do
      FactoryGirl.create(:external_system, code: 'local_scan')
      FactoryGirl.create(:order_status, code: 'new')
      FactoryGirl.create(:order_status, code: 'request')
    end

    it "create order" do
      Rails.application.config.sendit_url = 'http://localhost'
      Rails.application.config.order_prefix = 'TEST'
      stub_request(:post, "http://localhost/send/haitatsu_scan_request").
        to_return(:status => 200, :body => "", :headers => {})
      post :create,
        :email => 'test@dom.ain', :supplier => 'local_scan',
        :callback_url => 'http://localhost/',
        :open_url => @open_request
      Order.count.should eq 1
    end

    it "fails to create order" do
      Rails.application.config.sendit_url = 'http://localhost'
      stub_request(:post, "http://localhost/send/haitatsu_scan_request").
        to_return(:status => 406, :body => "", :headers => {})
      post :create,
        :email => 'test@dom.ain', :supplier => 'local_scan',
        :callback_url => 'http://localhost/',
        :open_url => @open_request
      Order.count.should eq 0
    end
  end

  describe "GET #show" do
    # GET /rest/orders/1.json
    it "assigns and renders @order" do
      order1 = FactoryGirl.create(:order)
      order2 = FactoryGirl.create(:order)
      get :show, id: order1, :format => :json
      assigns(:order).should eq (order1)
      response.header['Content-Type'].should include 'application/json'
      response.body.should eq order1.to_json
    end
  end

end
