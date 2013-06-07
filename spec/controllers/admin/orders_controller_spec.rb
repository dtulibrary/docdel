require 'spec_helper'
include Devise::TestHelpers

describe Admin::OrdersController do
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
      response.status.should be(200)
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "renders the order" do
      request = FactoryGirl.create(:order_request)
      get :show, id: request.order
      response.status.should be(200)
      response.should render_template :show
    end
  end

  describe "GET #deliver" do
    it "renders the order" do
      FactoryGirl.create(:order_status, code: 'deliver')
      request = FactoryGirl.create(:order_request)
      get :deliver, id: request.order
      response.status.should be(302)
    end
  end

end
