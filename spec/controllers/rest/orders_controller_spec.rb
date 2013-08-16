require 'spec_helper'
require 'nokogiri'

# require the savon helper module
require "savon/mock/spec_helper"

describe Rest::OrdersController do
  render_views

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
      Rails.application.config.reprintsdesk.wsdl = "spec/fixtures/reprintsdesk/reprints.wsdl"
      Rails.application.config.reprintsdesk.user = "Test"
      Rails.application.config.reprintsdesk.password = "Pass"
      Rails.application.config.reprintsdesk.username = "Test"
      Rails.application.config.reprintsdesk.firstname = "Test"
      Rails.application.config.reprintsdesk.lastname = "Test"
      Rails.application.config.reprintsdesk.companyname = "Test"
      Rails.application.config.reprintsdesk.address1 = "Test"
      Rails.application.config.reprintsdesk.address2 = ""
      Rails.application.config.reprintsdesk.city = "Test"
      Rails.application.config.reprintsdesk.zipcode = "9999"
      Rails.application.config.reprintsdesk.statecode = "*"
      Rails.application.config.reprintsdesk.statename = "*"
      Rails.application.config.reprintsdesk.countrycode = "XX"
      Rails.application.config.reprintsdesk.phone = "*"
      Rails.application.config.reprintsdesk.fax = "*"
      Rails.application.config.reprintsdesk.systemmail = "test@dom.ain"
      Rails.application.config.reprintsdesk.order_prefix = 'TEST'
    end
    after(:all) { 
      savon.unmock!
    }

    before :each do
      FactoryGirl.create(:external_system, code: 'reprintsdesk')
      FactoryGirl.create(:order_status, code: 'new')
      FactoryGirl.create(:order_status, code: 'request')
    end

    it "create order for reprintsdesk" do
      price_request = {:issn=>"21504091", :year=>"2010", :totalpages=>1}
      price_response = File.read("spec/fixtures/reprintsdesk/price_response.xml")
      order_request = File.read("spec/fixtures/reprintsdesk/order_request.xml")
      order_response = File.read("spec/fixtures/reprintsdesk/order_response.xml")
      savon.expects(:order_get_price_estimate).with(message: price_request).returns(price_response)
      savon.expects(:order_place_order2).with(message: order_request).returns(order_response)
      post :create,
        :email => 'test@dom.ain', :supplier => 'reprintsdesk',
        :callback_url => 'http://testhost/',
        :open_url => 'url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.au=Lokhande%2C+Ram&rft.atitle=Study+of+some+Indian+medicinal+plants+by+application+of+INAA+and+AAS+techniques&rft.jtitle=Natural+Science&rft.issn=21504091&rft.issn=21504105&rft.date=2010&rft.volume=02&rft.issue=01&rft.pages=26-32&rft_id=info:doi%2F10.4236%2Fns.2010.21004'
      Order.count.should eq 1
      # Check that order/request matches what we want.
      order = Order.first
      order.current_request.external_service_charge.should eq 10.0
      order.current_request.external_copyright_charge.should eq -1.0
      order.current_request.external_number.should eq 123456
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
