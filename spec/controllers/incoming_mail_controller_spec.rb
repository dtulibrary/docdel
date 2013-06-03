require 'spec_helper'
require 'mail'

describe IncomingMailController do
  it "fails to handle incoming email" do
    mail = Mail.new(File.read("spec/fixtures/incoming_test_email"))
    IncomingMailController.receive(mail).should eq false
  end

  it "handle email with proper handler function" do
    class IncomingMailController
      def supplier_mail_check_test(mail)
        (mail.subject == "Test mail") ? true : false
      end
    end
    mail = Mail.new(File.read("spec/fixtures/incoming_test_email"))
    IncomingMailController.receive(mail).should eq true
  end

end
