class IncomingMailController < ActionMailer::Base
  def receive(mail)
    self.methods.each do |m|
      if /^supplier_mail_check/.match m.to_s
        return true if send(m, mail)
      end
    end
    false
  end

  def extract_mail_text_part(mail)
    extract_mail_part(mail, /text\/plain/)
  end

  def extract_mail_pdf_part(mail)
    extract_mail_part(mail, /application\/pdf/)
  end

  private

  def handle_mail?(prefix)
    unless @prefix_code == prefix
      logger.info "Rejecting mail on prefix_code #{@prefix_code} != "+
        "#{prefix}"
      return false
    end
    @order = Order.find_by_id(@order_number)
    unless @order
      logger.info "Rejecting mail on not found #{@order_number}"
      return false
    end
    true
  end

  def confirm_request(supplier)
    request = @order.request(supplier, @external_number)
    request ? request.confirm(@external_number) : report_not_found
  end

  def cancel_request(supplier)
    request = @order.request(supplier, @external_number)
    request ? request.cancel : report_not_found
  end

  def deliver_request(supplier, url)
    request = @order.request(supplier, @external_number)
    request ? request.deliver(url) : report_not_found
  end

  def report_not_found
    logger.info "Request #{@external_number} not found on order #{@order_number}"
    false
  end

  def extract_mail_part(mail, mime_type)
    if mail.parts.count == 0
      part = mail
    else
      part = nil
      mail.parts.each do |p|
        if p.content_type =~ mime_type
          part = p
        end
      end
    end
    part
  end

  def config
    Rails.application.config
  end

  def logger
    Rails.logger
  end
end
