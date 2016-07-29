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
    extract_mail_part(mail, 'text/plain')
  end

  def extract_mail_pdf_part(mail)
    extract_mail_part(mail, 'application/pdf')
  end

  def extract_mail_octet_streams(mail)
    extract_mail_parts(mail, 'application/octet-stream')
  end

  private

  def valid_prefix?(prefix)
    logger.info "Rejecting mail on prefix_code '#{@prefix_code}' != '#{prefix}'" unless @prefix_code == prefix
    @prefix_code == prefix
  end

  def valid_order?(order_number)
    @order = Order.find_by_id(@order_number)
    logger.info "Rejecting mail on order not found '#{@order_number}'" unless @order
    @order
  end

  def valid_order_request?(external_number)
    order_request = OrderRequest.where(external_number: external_number)
    return false unless order_request.count > 0
    @order = order_request.first.order
  end

  def handle_mail?(prefix = config.order_prefix)
    valid_prefix?(prefix) && valid_order?(@order_number)
  end

  def enrich_request_with_external_number(supplier, external_number)
    request = @order.request(supplier, nil)
    return if request.nil?

    request.external_number = external_number
    request.save!
  end

  def confirm_request(supplier)
    request = @order.request(supplier, @external_number)
    request ? request.confirm(@external_number) : report_not_found
  end

  def cancel_request(supplier)
    request = @order.request(supplier, @external_number)
    return report_not_found unless request

    request.reason_text = @responder_note
    request.cancel
  end

  def deliver_request(supplier, url)
    request = @order.request(supplier, @external_number)
    request ? request.deliver(url) : report_not_found
  end

  def report_not_found
    logger.info "Request #{@external_number} not found on order_number #{@order_number}"
    false
  end

  def extract_mail_part(mail, mime_type)
    extract_mail_parts(mail, mime_type).first || mail
  end

  def extract_mail_parts(mail, mime_type)
    mail.parts.select {|p| mime_type =~ %r{^#{mime_type}}}
  end

  def config
    Rails.application.config
  end

  def logger
    Rails.logger
  end
end
