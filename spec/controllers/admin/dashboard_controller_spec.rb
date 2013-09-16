require 'spec_helper'
include Devise::TestHelpers

describe Admin::DashboardController do
  render_views

  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  after(:each) do
    @user.destroy
  end

  describe "Get dashboard" do
    it "renders the dashboard view" do
      FactoryGirl.create(:order)
      FactoryGirl.create(:order, :delivered_at => Time.now)
      get :index
      expect(response.status).to be(200)
      expect(response).to render_template :index
    end
  end
end
