require 'spec_helper'
require 'mail'
require "suppliers/reprintsdesk"

describe IncomingMailController do
  include WebMock::API

  after :all do
    WebMock.reset!
  end

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

  context "ReprintsDesk" do
    describe "correct order" do
      before :each do
        setup_reprintsdesk(5000, 123456, 'TEST')
      end

      it "handles New Order" do
        mail_should_set_status('new_order', 'confirm')
      end

      it "handles Confirmation" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/confirmation.eml"))
        IncomingMailController.receive(mail).should eq true
      end

      it "handles Information cancel" do
        mail_should_set_status('cancel', 'cancel')
      end

      it "handles Machine cancel" do
        mail_should_set_status('cancel_machine', 'cancel')
      end

      it "handles Download" do
        mail_should_set_status('download', 'deliver')
      end

      it "handles Download - html only" do
        mail_should_set_status('download_html_only', 'deliver')
      end

      it "doesn't handle unknown subject" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_subject.eml"))
        IncomingMailController.receive(mail).should eq false
      end

      it "doesn't handle unknown information" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_info.eml"))
        IncomingMailController.receive(mail).should eq false
      end

    end

    describe "wrong order-id" do
      before :each do
        setup_reprintsdesk(4999, 123456, 'TEST')
      end

      it "doesn't handle unknown order number" do
        mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        mail_should_not_be_handled('download_html_only')
      end

    end

    describe "wrong prefix" do
      before :each do
        setup_reprintsdesk(5000, 123456, 'TEST2')
      end

      it "doesn't handle unknown order number" do
        mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        mail_should_not_be_handled('download_html_only')
      end

    end

    describe "wrong external-id" do
      before :each do
        setup_reprintsdesk(5000, 123457, 'TEST')
      end

      it "doesn't handle unknown order number" do
        mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        mail_should_not_be_handled('download_html_only')
      end

    end

    def setup_reprintsdesk(order_id, external_id, prefix)
      ext = FactoryGirl.create(:external_system, code: 'reprintsdesk')
      # Create order we can test with that means fixed id
      @order = FactoryGirl.create(:order, id: order_id)
      @request = FactoryGirl.create(:order_request, :order => @order,
        :external_system => ext, :external_id => external_id)
      Rails.application.config.reprintsdesk.order_prefix = prefix
    end

    def mail_should_set_status(mail_file, status)
      stub_request(:get, "http://localhost/callback?status=#{status}").
        to_return(:status => 200, :body => "", :headers => {})
      FactoryGirl.create(:order_status, code: status)
      mail = Mail.new(
        File.read("spec/fixtures/reprintsdesk/#{mail_file}.eml"))
      IncomingMailController.receive(mail).should eq true
      order = Order.find(@order.id)
      order.current_request.order_status.code.should eq status
    end

    def mail_should_not_be_handled(mail_file)
      mail = Mail.new(
        File.read("spec/fixtures/reprintsdesk/#{mail_file}.eml"))
      IncomingMailController.receive(mail).should eq false
    end

  end

end
