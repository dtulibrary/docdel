require 'spec_helper'
require 'mail'
require "suppliers/reprintsdesk"
require "suppliers/local_scan"
require 'suppliers/tib'

describe IncomingMailController do
  include WebMock::API

  after :all do
    WebMock.reset!
  end

  it "fails to handle incoming email" do
    mail = Mail.new(File.read("spec/fixtures/incoming_mail/error.eml"))
    expect(IncomingMailController.receive(mail)).to eq false
  end

  it "handle email with proper handler function" do
    class IncomingMailController
      def supplier_mail_check_test(mail)
        mail.subject == "Test mail"
      end
    end
    mail = Mail.new(File.read("spec/fixtures/incoming_mail/ok.eml"))
    expect(IncomingMailController.receive(mail)).to eq true
  end

  context "ReprintsDesk" do
    describe "correct order" do
      before :each do
        setup_reprintsdesk(5000, '123456', 'TEST')
      end

      it "handles New Order" do
        rd_mail_should_set_status('new_order', 'confirm')
      end

      it "handles Confirmation" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/confirmation.eml"))
        expect(IncomingMailController.receive(mail)).to eq true
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

      it "handles Delivery" do
        rd_mail_has_status('delivery', 'deliver')
      end

      it "doesn't handle unknown subject" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_subject.eml"))
        expect(IncomingMailController.receive(mail)).to eq false
      end

      it "doesn't handle unknown information" do
        mail = Mail.new(File.read("spec/fixtures/reprintsdesk/unknown_info.eml"))
        expect(IncomingMailController.receive(mail)).to eq false
      end

    end

    describe "wrong order-id" do
      before :each do
        setup_reprintsdesk(4999, '123456', 'TEST')
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

      it "doesn't handle Delivery" do
        rd_mail_should_not_be_handled('delivery')
      end

    end

    describe "wrong prefix" do
      before :each do
        setup_reprintsdesk(5000, '123456', 'TEST2')
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

      it "doesn't handle Delivery" do
        rd_mail_should_not_be_handled('delivery')
      end

    end

    describe "wrong external-id" do
      before :each do
        setup_reprintsdesk(5000, '123457', 'TEST')
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

      it "doesn't handle Delivery" do
        rd_mail_should_not_be_handled('delivery')
      end

    end

    def setup_reprintsdesk(order_id, external_number, prefix)
      setup_supplier(order_id, external_number, 'reprintsdesk')
      Rails.application.config.order_prefix = prefix
    end

    def rd_mail_should_set_status(mail_file, status)
      mail_should_set_status(mail_file, status, 'reprintsdesk')
    end

    def rd_mail_has_status(mail_file, status)
      mail_has_status(mail_file, status, 'reprintsdesk')
    end

    def rd_mail_should_not_be_handled(mail_file)
      mail = Mail.new(
        File.read("spec/fixtures/reprintsdesk/#{mail_file}.eml"))
      expect(IncomingMailController.receive(mail)).to eq false
    end

  end

  context "Local Scan" do
    before :each do
      Rails.application.config.local_scan.handle_mails_from = /dom.ain/
      Rails.application.config.storeit_url = "http://localhost"
    end

    describe "correct order" do
      before :each do
        setup_local_scan(234, '234', 'T')
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

      it "handles without prefix when configured" do
        Rails.application.config.local_scan.allow_no_prefix = true
        request_set_status('request')
        ls_mail_should_set_status('order_no_prefix', 'deliver')
      end

      it "doesn't handle without prefix when status is wrong" do
        Rails.application.config.local_scan.allow_no_prefix = true
        ls_mail_should_not_be_handled('order_no_prefix')
      end

      it "doesn't handle without prefix when not configured" do
        Rails.application.config.local_scan.allow_no_prefix = false
        ls_mail_should_not_be_handled('order_no_prefix')
      end

    end

    describe "wrong order-id" do
      before :each do
        setup_local_scan(233, '234', 'T')
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
        setup_local_scan(4000, '235', 'T')
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
        setup_local_scan(234, '234', 'F')
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
      expect(IncomingMailController.receive(mail)).to eq false
    end

    def ls_mail_has_status(mail_file, status)
      mail_has_status(mail_file, status, 'local_scan')
    end

  end

  context 'TIB' do
    it "handles a delivery where everything goes smooth" do
      #
      # Setup mock Rails configuration
      #
      Rails.application.config.order_prefix = 'TEST'
      Rails.application.config.sendit_url = 'http://sendit:3000'
      Rails.application.config.storeit_url = 'http://storeit:3000'

      #
      # Setup some mocks
      #
      FactoryGirl.create(:order_status, code: 'deliver')
      FactoryGirl.create(:order_status, code: 'confirm')
      ext = FactoryGirl.create(:external_system, code: 'tib')
      @order = FactoryGirl.create(:order, id: 1234, callback_url: "http://callbackhost/callback")
      @request = FactoryGirl.create(:order_request, :order => @order,
        :external_system => ext, :external_number => nil)

      #
      # We will use this variable later
      #
      status = nil

      #
      # Stub some web requests
      #
      callback_lambda = lambda do |request|
        query_values = request.uri.query_values

        if not query_values["status"].eql?(status)
          raise Exception.new("callback service was called with a bad status: #{status}")
        end

        if "deliver".eql?(status) && !"http://storeit:3000/dummy_document.pdf".eql?(query_values["url"])
          raise Exception.new("callback service was called with a bad url: #{query_values['url']}")
        end

        if "confirm".eql?(status) && (!@request.external_number.nil? && !@request.external_number.eql?(query_values["supplier_order_id"]))
          raise Exception.new("callback service was called with a bad supplier_order_id.")
        end

        return {status: 200, body: '', headers: {}}
      end
      stub_request(:get, /^http:\/\/callbackhost\/callback/).to_return(callback_lambda)

      storeit_lambda = lambda do |request|
        body_is_pdf_document = "%PDF".eql?(request.body[0..3])
        # TODO TLNI: Should the body be a pdf document? Should the document be base64 encoded?
        return :status => 200, :body => "http://storeit:3000/dummy_document.pdf", :headers => {}
      end
      stub_request(:post, "http://storeit:3000/rest/documents.text?drm=false").to_return(storeit_lambda)

      #
      # First we test when a 'confirm' mail is received
      #
      status = 'confirm'

      mail = Mail.new(File.read("spec/fixtures/tib/accepted.eml"))
      IncomingMailController.receive(mail)

      expect(Order.find(@order.id).current_request.order_status.code).to eq 'confirm'
      expect(Order.find(@order.id).current_request.external_number).to eq 'E012345678'

      #
      # ... Then we test when a 'deliver' mail is received
      #
      status = 'deliver'

      mail = Mail.new(
        File.read("spec/fixtures/tib/delivery_no_drm.eml"))
      IncomingMailController.receive(mail)

      expect(Order.find(@order.id).current_request.order_status.code).to eq 'deliver'
      expect(Order.find(@order.id).current_request.external_url).to eq 'http://storeit:3000/dummy_document.pdf'
    end

    context 'when order is accepted' do
      before do
        setup_tib(1234, nil)
      end

      it 'handles the mail' do
        expect(tib_stub_and_receive('accepted', 'confirm')).to eq true
      end

      it "sets request status to 'confirm'" do
        tib_stub_and_receive('accepted', 'confirm')
        expect(Order.find(@order.id).current_request.order_status.code).to eq 'confirm'
      end

      it "sets request status to 'cancel'" do
        tib_stub_and_receive('unfilled', 'cancel')
        expect(Order.find(@order.id).current_request.order_status.code).to eq 'cancel'
      end

      it 'records the reason for not accepting' do
        tib_stub_and_receive('unfilled', 'cancel')
        expect(Order.find(@order.id).current_request.format_reason).to eq 'Double-order, this order is being dealt with order no'
      end

    end

    context 'when mail matches an existing order' do
      before do
        setup_tib(1234, 'E012345678')
      end

      context 'when mail is a status change' do
        context 'when order exists' do
          it 'handles the mail' do
            expect(tib_stub_and_receive('accepted', 'confirm')).to eq true
          end

          context 'when order is accepted' do
            it "sets request status to 'confirm'" do
              tib_stub_and_receive('accepted', 'confirm')
              expect(Order.find(@order.id).current_request.order_status.code).to eq 'confirm'
            end
          end

          context 'when order is shipped' do
            context 'with DRM' do
            end

            context 'without DRM' do
            end
          end
          
          context 'when order is not accepted' do
            it "sets request status to 'cancel'" do
              tib_stub_and_receive('unfilled', 'cancel')
              expect(Order.find(@order.id).current_request.order_status.code).to eq 'cancel'
            end

            it 'records the reason for not accepting' do
              tib_stub_and_receive('unfilled', 'cancel')
              expect(Order.find(@order.id).current_request.format_reason).to eq 'Double-order, this order is being dealt with order no'
            end
          end
        end
      end

      context 'when mail is a delivery' do
        context 'with DRM' do
          before do
            Rails.application.config.storeit_url = 'http://storeit:3000'
            stub_request(:post, 'http://storeit:3000/rest/documents.text?drm=true')
              .with(:headers => {content_type: 'application/pdf'},
                    :body    => IO.read("#{Rails.root}/public/dummy_document.pdf"))
              .to_return(status: 200, body: '/dummy_document.pdf', headers: {})
          end

          it 'handles the mail' do
          end

          it "sets request status to 'deliver'" do
          end

          it 'stores the document in the document store with drm flag' do
          end
        end

        context 'without DRM' do
          it 'stores the document in the document store without drm flag' do
          end
        end
      end
    end
    
    context "when mail contains non-existing order id" do
      it "doesn't handle the mail" do
        expect(tib_stub_and_receive('accepted')).to eq false
      end
    end

    context "when mail contains prefix that doesn't match system prefix" do
      before do
        setup_tib(1234, 'E012345678', 'WRONG')
      end

      it "doesn't handle the mail" do
        expect(tib_stub_and_receive('accepted')).to eq false
      end
    end

    def setup_tib(order_id, external_number, prefix = nil)
      setup_supplier(order_id, external_number, 'tib', prefix || 'TEST')
    end

    def tib_stub_and_receive(mail_file, status = nil)
      stub_and_receive('tib', mail_file, status)
    end

    def tib_mail_should_set_status(mail_file, status)
      mail_should_set_status(mail_file, status, 'tib')
    end

    def tib_mail_should_not_be_handled(mail_file)
      mail = Mail.new(
        File.read("spec/fixtures/tib/#{mail_file}.eml"))
      expect(IncomingMailController.receive(mail)).to eq false
    end
  end

  def setup_supplier(order_id, external_number, supplier, prefix = nil)
    ext = FactoryGirl.create(:external_system, code: supplier)
    # Create order we can test with that means fixed id
    @order = FactoryGirl.create(:order, id: order_id)
    @request = FactoryGirl.create(:order_request, :order => @order,
      :external_system => ext, :external_number => external_number)
    Rails.application.config.order_prefix = prefix unless prefix.nil?
  end

  def stub_and_receive(supplier, mail_file, status = nil)
    stub_status_change_request(status)
    mail = Mail.new(File.read("spec/fixtures/#{supplier}/#{mail_file}.eml"))
    IncomingMailController.receive(mail)
  end

  def stub_status_change_request(status)
    callback_url_regex = Regexp.new("^http://localhost/callback")

    callback_lambda = lambda do |request|
      query_values = request.uri.query_values

      if not query_values["status"].eql?(status)
        raise Exception.new("callback service was called with a bad status.")
      end

      if "deliver".eql?(status) && !"/dummy_document.pdf".eql?(query_values["url"])
        raise Exception.new("callback service was called with a bad url.")
      end

      if "confirm".eql?(status) && (!@request.external_number.nil? && !@request.external_number.eql?(query_values["supplier_order_id"]))
        raise Exception.new("callback service was called with a bad supplier_order_id.")
      end

      return {status: 200, body: '', headers: {}}
    end

    stub_request(:get, callback_url_regex).to_return(callback_lambda)

    FactoryGirl.create(:order_status, code: status) unless status.nil?
  end

  def mail_should_set_status(mail_file, status, supplier)
    url_params = {:status => status}
    url_params[:url]               = '/Order_PlaceHolder.pdf' if status == 'deliver'
    url_params[:supplier_order_id] = @request.external_number if status == 'confirm'

    url = "http://localhost/callback?" + 
           url_params.collect {|k,v| "#{k}=#{URI.encode_www_form_component v}"}.join('&')

    stub_request(:get, url).
      to_return(:status => 200, :body => "", :headers => {})
    FactoryGirl.create(:order_status, code: status)
    mail = Mail.new(
      File.read("spec/fixtures/#{supplier}/#{mail_file}.eml"))
    expect(IncomingMailController.receive(mail)).to eq true
    order = Order.find(@order.id)
    expect(order.current_request.order_status.code).to eq status
    if status == 'deliver'
      expect(order.current_request.external_url).not_to eq 'http://external.'+
        'test.com/external_reference.html'
    end
  end

  def mail_has_status(mail_file, status, supplier)
    request_set_status(status)
    mail = Mail.new(
      File.read("spec/fixtures/#{supplier}/#{mail_file}.eml"))
    expect(IncomingMailController.receive(mail)).to eq true
  end

  def request_set_status(status)
    order_status = FactoryGirl.create(:order_status, code: status)
    @request.order_status = order_status
    @request.save!
  end

end
