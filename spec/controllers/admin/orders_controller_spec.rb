require 'spec_helper'

describe Admin::OrdersController do
  include Devise::TestHelpers
  include WebMock::API
  render_views

  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  after(:each) do
    @user.destroy
  end

  describe "GET #index" do
    it "renders the order view" do
      FactoryGirl.create(:order)
      get :index
      expect(response.status).to be(200)
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "renders the order" do
      request = FactoryGirl.create(:order_request)
      get :show, id: request.order
      expect(response.status).to be(200)
      expect(response).to render_template :show
    end
  end

  describe "GET #deliver" do
    it "renders the order" do
      Rails.application.config.storeit_url = 'http://localhost'
      stub_request(:get, "http://localhost/callback?status=deliver"\
        "&url=http://localhost/5.pdf").
        to_return(:status => 200, :body => "", :headers => {})
      pdfdoc = File.read("#{Rails.root}/public/Order_PlaceHolder.pdf")
      stub_request(:post, "http://localhost/rest/documents.text?drm=false").
        with(:body => pdfdoc,
             :headers => {'Content-Type'=>'application/pdf'}).
        to_return(:status => 200, :body => "http://localhost/5.pdf",
             :headers => {})
      FactoryGirl.create(:order_status, code: 'deliver')
      request = FactoryGirl.create(:order_request)
      get :deliver, id: request.order
      expect(response.status).to be(302)
      expect(OrderRequest.find_by_id(request.id).order_status.code).
        to eq 'deliver'
    end
  end

  describe "GET #cancel" do
    it "renders the order" do
      stub_request(:get, "http://localhost/callback?status=cancel&supplier_order_id=1").
        to_return(:status => 200, :body => "", :headers => {})
      FactoryGirl.create(:order_status, code: 'cancel')
      request = FactoryGirl.create(:order_request)
      get :cancel, id: request.order
      expect(response.status).to be(302)
      expect(OrderRequest.find_by_id(request.id).order_status.code).
        to eq 'cancel'
    end
  end

end
