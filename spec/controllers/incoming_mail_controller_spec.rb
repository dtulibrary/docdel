require 'spec_helper'
require 'mail'
require "suppliers/reprintsdesk"

describe IncomingMailController do
  it "fails to handle incoming email" do
    mail = Mail.new(File.read("spec/fixtures/incoming_mail/error.eml"))
    IncomingMailController.receive(mail).should eq false
  end

  it "handle email with proper handler function" do
    class IncomingMailController
      def supplier_mail_check_test(mail)
        (mail.subject == "Test mail") ? true : false
      end
    end
    mail = Mail.new(File.read("spec/fixtures/incoming_mail/ok.eml"))
    IncomingMailController.receive(mail).should eq true
  end

  describe "ReprintsDesk" do
    before :each do
      ext = FactoryGirl.create(:external_system, code: 'reprintsdesk')
      # Create order we can test with that means fixed id
      @order = FactoryGirl.create(:order, id: 5000)
      @request = FactoryGirl.create(:order_request, order: @order,
        external_system: ext, external_id: 123456)
      Rails.application.config.reprintsdesk.order_prefix = "TEST"
    end

    it "handles New Order" do
      FactoryGirl.create(:order_status, code: 'confirm')
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/new_order.eml"))
      IncomingMailController.receive(mail).should eq true
      order = Order.find(@order.id)
      order.current_request.order_status.code.should eq 'confirm'
    end

    it "handles Confirmation" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/confirmation.eml"))
      IncomingMailController.receive(mail).should eq true
    end

    it "handles Information cancel" do
      FactoryGirl.create(:order_status, code: 'cancel')
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/cancel.eml"))
      IncomingMailController.receive(mail).should eq true
      order = Order.find(@order.id)
      order.current_request.order_status.code.should eq 'cancel'
    end

    it "handles Download" do
      FactoryGirl.create(:order_status, code: 'deliver')
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/download.eml"))
      IncomingMailController.receive(mail).should eq true
      order = Order.find(@order.id)
      order.current_request.order_status.code.should eq 'deliver'
    end

    it "doesn't handle unknown subject" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_subject.eml"))
      IncomingMailController.receive(mail).should eq false
    end

    it "doesn't handle unknown information" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_info.eml"))
      IncomingMailController.receive(mail).should eq false
    end

    it "doesn't handle unknown prefix" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/wrong_prefix.eml"))
      IncomingMailController.receive(mail).should eq false
    end

    it "doesn't handle unknown order number" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/wrong_number.eml"))
      IncomingMailController.receive(mail).should eq false
    end

    it "doesn't handle wrong request on new order" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/wrong_order_req.eml"))
      IncomingMailController.receive(mail).should eq false
    end

    it "doesn't handle wrong request on download order" do
      mail = Mail.new(File.read("spec/fixtures/reprintsdesk/wrong_download_req.eml"))
      IncomingMailController.receive(mail).should eq false
    end

  end

end
