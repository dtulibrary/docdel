require 'spec_helper'
require 'mail'
require "suppliers/reprintsdesk"
require "suppliers/local_scan"

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
        rd_mail_should_set_status('new_order', 'confirm')
      end

      it "handles Confirmation" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/confirmation.eml"))
        IncomingMailController.receive(mail).should eq true
      end

      it "handles Information cancel" do
        rd_mail_should_set_status('cancel', 'cancel')
      end

      it "handles Machine cancel" do
        rd_mail_should_set_status('cancel_machine', 'cancel')
      end

      it "handles Download" do
        rd_mail_should_set_status('download', 'deliver')
      end

      it "handles Download - html only" do
        rd_mail_should_set_status('download_html_only', 'deliver')
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
        rd_mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        rd_mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        rd_mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        rd_mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        rd_mail_should_not_be_handled('download_html_only')
      end

    end

    describe "wrong prefix" do
      before :each do
        setup_reprintsdesk(5000, 123456, 'TEST2')
      end

      it "doesn't handle unknown order number" do
        rd_mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        rd_mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        rd_mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        rd_mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        rd_mail_should_not_be_handled('download_html_only')
      end

    end

    describe "wrong external-id" do
      before :each do
        setup_reprintsdesk(5000, 123457, 'TEST')
      end

      it "doesn't handle order" do
        rd_mail_should_not_be_handled('new_order')
      end

      it "doesn't handle Information cancel" do
        rd_mail_should_not_be_handled('cancel')
      end

      it "doesn't handle Machine cancel" do
        rd_mail_should_not_be_handled('cancel_machine')
      end

      it "doesn't handle Download" do
        rd_mail_should_not_be_handled('download')
      end

      it "doesn't handle Download - html only" do
        rd_mail_should_not_be_handled('download_html_only')
      end

    end

    def setup_reprintsdesk(order_id, external_number, prefix)
      setup_supplier(order_id, external_number, 'reprintsdesk')
      Rails.application.config.order_prefix = prefix
    end

    def rd_mail_should_set_status(mail_file, status)
      mail_should_set_status(mail_file, status, 'reprintsdesk')
    end

    def rd_mail_should_not_be_handled(mail_file)
      mail = Mail.new(
        File.read("spec/fixtures/reprintsdesk/#{mail_file}.eml"))
      IncomingMailController.receive(mail).should eq false
    end

  end

  context "Local Scan" do
    before :each do
      Rails.application.config.local_scan.handle_mails_from = /dom.ain/
      Rails.application.config.storeit_url = "http://localhost"
    end

    describe "correct order" do
      before :each do
        setup_local_scan(234, 234, 'T')
      end

      it "handles delivery from subject" do
        ls_mail_should_set_status('order_subject', 'deliver')
      end

      it "handles delivery from body" do
        ls_mail_should_set_status('order_body', 'deliver')
      end

      it "doesn't handle with StoreIt error" do
        assert_raise StandardError do
          ls_mail_should_not_be_handled('order_subject')
        end
      end

    end

    describe "wrong order-id" do
      before :each do
        setup_local_scan(233, 234, 'T')
      end

      it "doesn't handle delivery from subject" do
        ls_mail_should_not_be_handled('order_subject')
      end

      it "doesn't handle delivery from body" do
        ls_mail_should_not_be_handled('order_body')
      end

    end

    describe "wrong external-id" do
      before :each do
        setup_local_scan(4000, 235, 'T')
      end

      it "doesn't handle delivery from subject" do
        ls_mail_should_not_be_handled('order_subject')
      end

      it "doesn't handle delivery from body" do
        ls_mail_should_not_be_handled('order_body')
      end
    end

    describe "wrong prefix" do
      before :each do
        setup_local_scan(234, 234, 'F')
      end

      it "doesn't handle delivery from subject" do
        ls_mail_should_not_be_handled('order_subject')
      end

      it "doesn't handle delivery from body" do
        ls_mail_should_not_be_handled('order_body')
      end
    end

    def setup_local_scan(order_id, external_number, prefix)
      setup_supplier(order_id, external_number, 'local_scan')
      Rails.application.config.order_prefix = prefix
    end

    def ls_mail_should_set_status(mail_form, status)
     stub_request(:post, "http://localhost/rest/documents.text?drm=false").
       with(:headers => {'Content-Type'=>'application/pdf'}).
       to_return(:status => 200, :body => "/Order_PlaceHolder.pdf",
         :headers => {})
      mail_should_set_status(mail_form, status, 'local_scan')
    end

    def ls_mail_should_not_be_handled(mail_file)
     stub_request(:post, "http://localhost/rest/documents.text?drm=false").
       with(:headers => {'Content-Type'=>'application/pdf'}).
       to_return(:status => 404, :body => "", :headers => {})
      mail = Mail.new(
        File.read("spec/fixtures/local_scan/#{mail_file}.eml"))
      IncomingMailController.receive(mail).should eq false
    end

  end

  def setup_supplier(order_id, external_number, supplier)
    ext = FactoryGirl.create(:external_system, code: supplier)
    # Create order we can test with that means fixed id
    @order = FactoryGirl.create(:order, id: order_id)
    @request = FactoryGirl.create(:order_request, :order => @order,
      :external_system => ext, :external_number => external_number)
  end

  def mail_should_set_status(mail_file, status, supplier)
    url = "http://localhost/callback?status=#{status}" +
      (status == 'deliver' ? '&url=/Order_PlaceHolder.pdf' : '')
    stub_request(:get, url).
      to_return(:status => 200, :body => "", :headers => {})
    FactoryGirl.create(:order_status, code: status)
    mail = Mail.new(
      File.read("spec/fixtures/#{supplier}/#{mail_file}.eml"))
    IncomingMailController.receive(mail).should eq true
    order = Order.find(@order.id)
    order.current_request.order_status.code.should eq status
    if status == 'deliver'
      order.current_request.external_url.should_not eq 'http://external.test.com/external_reference.html'
    end
  end

end
