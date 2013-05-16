require 'spec_helper'

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
