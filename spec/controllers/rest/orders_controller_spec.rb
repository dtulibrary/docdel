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
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3A'+
          'ofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&'+
          'rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Lokhande'+
          '%2C+Ram&rft.atitle=Study+of+some+Indian+medicinal+plants+by+'+
          'application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&'+
          'rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&'+
          'rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.'+
          '21004'
      expect(Order.count).to eq 1
      order = Order.first
      expect(order.title).to eq 'Natural Science'
      expect(order.aufirst).to eq  'Ram'
      expect(order.aulast).to eq 'Lokhande'
    end

    it "create order with corporation" do
      post :create, :email => 'test@dom.ain', :supplier => 'bogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3A'+
          'ofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&'+
          'rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Test+'+
          'Corporation&rft.atitle=Study+of+some+Indian+medicinal+plants+by+'+
          'application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science'+
          '&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&'+
          'rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.'+
          '21004'
      expect(Order.count).to eq 1
      order = Order.first
      expect(order.title).to eq 'Natural Science'
      expect(order.aufirst).to eq nil
      expect(order.aulast).to eq  'Test Corporation'
    end

    it "create order without journal title" do
      post :create, :email => 'test@dom.ain', :supplier => 'bogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info'+
          '%3Aofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A'+
          'ctx&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au='+
          'Test+Corporation&rft.atitle=Study+of+some+Indian+medicinal+plants'+
          '+by+application+of+INAA+and+AAS+techniques&rft.issn=21504091&'+
          'rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&'+
          'rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
      expect(Order.count).to eq 1
      order = Order.first
      expect(order.title).to eq ''
    end

    it "create order with long journal title" do
      post :create, :email => 'test@dom.ain', :supplier => 'bogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3A'+
          'ofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&'+
          'rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Lokhande'+
          '%2C+Ram&rft.atitle=Study+of+some+Indian+medicinal+plants+by+'+
          'application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science'+
          (' Long name' * 120) +
          '&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&'+
          'rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.'+
          '21004'
      expect(Order.count).to eq 1
      order = Order.first
      expect(order.title).to eq 'Natural Science' + (' Long name' * 100) +
        ' Long nam'
    end

    it "fails create order" do
      post :create, :email => 'test@dom.ain', :supplier => 'notbogus',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3A'+
          'ofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx'+
          '&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Test+'+
          'Corporation&rft.atitle=Study+of+some+Indian+medicinal+plants+by+'+
          'application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science'+
          '&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02'+
          '&rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010'+
          '.21004'
      expect(Order.count).to eq 0
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
      config.reprintsdesk.timecaps = {
        'type1' => 14.days,
        'default' => 6.days + 14.hours
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
      before :each do
      #  clear_order_information
      end

      it "works for type1" do
        set_user_id('1')
        set_user_name('Test1')
        set_user_response('{"address":{"line1":"A"},"user_type":"type1","dtu":{"org_units":["45"]}}')
        set_user_type('TYPE1')
        set_timecap('2013-10-15T00:00:00Z')
        with_price_lookup
        with_order_request_result(1)
        
        order = reprintsdesk_request
        basic_order_test(order)
        expect(order.institute.code).to eq '45'
      end

      it "works for others" do
        set_user_id('1')
        set_user_name('Test')
        set_user_type('OTHER')
        set_user_response('{"address":{"line1":"A"},"user_type":"other"}')
        set_timecap('2013-10-07T14:00:00Z')
        with_price_lookup
        with_order_request_result(1)

        order = reprintsdesk_request
        basic_order_test(order)
      end

      it "works for anon" do
        set_user_name('Test')
        set_user_type('OTHER')
        set_timecap('2013-10-07T14:00:00Z')
        with_price_lookup
        with_order_request_result(1)
        order = reprintsdesk_request
        basic_order_test(order)
      end

      it "failed rd response" do
        set_user_name('Test')
        set_user_type('OTHER')
        set_timecap('2013-10-07T14:00:00Z')
        with_price_lookup
        with_order_request_result(2)
        order = reprintsdesk_request
        expect(order).to be_valid
      end

      it "fails create order when user lookup fails" do
        set_user_name('Test')
        set_user_type('DTU')
        set_user_response('{"user_type":"type1","dtu":{
          "reason":"lookup_failed"}}')
        order = reprintsdesk_request
        expect(order).to eq nil
        expect(Order.count).to eq 0
      end

      def reprintsdesk_request
        post :create, :format => :json,
          :email => 'test@dom.ain', :supplier => 'reprintsdesk',
          :callback_url => 'http://testhost/',
          :dibs_order_id => 'OID',
          :user_id => @user_id,
          :timecap_base => '2013-10-01T00:00:00Z',
          :open_url => @open_request
        Order.first
      end

      def basic_order_test(order)
        expect(Order.count).to eq 1
        # Check that order/request matches what we want.
        expect(order.current_request.external_service_charge).to eq 10.0
        expect(order.current_request.external_copyright_charge).to eq -1.0
        expect(order.current_request.external_number).to eq '123456'
        expect(order.user_type.code).to eq @user['user_type'] if @user_response
      end

      def with_price_lookup
        price_request = {:issn=>"21504091", :year=>"2010", :totalpages=>1}
        price_response = File.read(
          "spec/fixtures/reprintsdesk/price_response.xml"
        )
        savon.expects(:order_get_price_estimate).with(:message => 
          price_request).returns(price_response)
      end

      def set_user_id(user_id)
        @user_id = user_id
      end

      def set_user_name(user_name)
        @user_name = user_name
      end

      def set_user_response(user_response)
        @user_response = user_response
        stub_request(:get, "http://localhost/users/1.json").
          to_return(:status => 200, :body => user_response,
            :headers => {})
        @user = JSON.parse(user_response)
      end

      def set_user_type(user_type)
        @user_type = user_type
      end

      def set_failed_user_response
        stub_request(:get, "http://localhost/users/1.json").
          to_return(:status => 500, :body => "Failure",
            :headers => {})
      end

      def set_timecap(date)
        @timecap = date 
      end

      def with_order_request_result(order_result)
        # Create binding for ERB
        user_name = @user_name
        user_type = @user_type
        timecap   = @timecap

        order_request = ERB.new(
          File.read("spec/fixtures/reprintsdesk/order_request.xml")
        ).result binding()

        order_response = ERB.new(
          File.read("spec/fixtures/reprintsdesk/order_response.xml")
        ).result binding()

        savon.expects(:order_place_order2).with(:message => 
          order_request).returns(order_response)
      end

      def clear_order_informaion
        @user = nil
        @user_response = nil
        @user_name = nil
        @user_type = nil
        @user_response = nil
        @timecap = nil
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
      stub_request(:post, "http://localhost/send/docdel_scan_request").
        to_return(:status => 200, :body => "", :headers => {})
      post :create,
        :email => 'test@dom.ain', :supplier => 'local_scan',
        :callback_url => 'http://localhost/',
        :open_url => @open_request
      expect(Order.count).to eq 1
    end

    it "fails to create order" do
      Rails.application.config.sendit_url = 'http://localhost'
      stub_request(:post, "http://localhost/send/docdel_scan_request").
        to_return(:status => 406, :body => "", :headers => {})
      post :create,
        :email => 'test@dom.ain', :supplier => 'local_scan',
        :callback_url => 'http://localhost/',
        :open_url => @open_request
      expect(Order.count).to eq 0
    end
  end

  describe "GET #show" do
    # GET /rest/orders/1.json
    it "assigns and renders @order" do
      order1 = FactoryGirl.create(:order)
      order2 = FactoryGirl.create(:order)
      get :show, id: order1, :format => :json
      expect(assigns(:order)).to eq (order1)
      expect(response.header['Content-Type']).to include 'application/json'
      expect(response.body).to eq order1.to_json(:include => {:order_requests => {:include => [:order_status]}})
    end
  end

end
