class IncomingMailController < ActionMailer::Base
  def receive(mail)
    self.methods.each do |m|
      if /^supplier_mail_check/.match m.to_s
        return true if send(m, mail)
      end
    end
    false
  end
end
