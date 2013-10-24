require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_local_scan(mail)
    if mail.from.grep(config.local_scan.handle_mails_from).count > 0
      local_scan_deliver(mail)
    else
      false
    end
  end

  private

  # Handle mail with scanned document
  def local_scan_deliver(mail)
    logger.info "Extract local mail info"
    local_scan_extract(mail)
    return false unless @pdfdoc && local_scan_handle_mail?
    url = StoreIt.store_pdf(@pdfdoc, 'application/pdf')
    deliver_request('local_scan', url)
    true
  end

  def local_scan_extract(mail)
    if mail.subject =~ /^(\w+)-(\d+)/
      @prefix_code = $1.upcase
      @order_number = $2
      @external_number = @order_number
    else
      body = extract_mail_text_part(mail).body.to_s
      if body =~ /^\s*(\w+)-(\d+)/
        @prefix_code = $1.upcase
        @order_number = $2
        @external_number = @order_number
      end
    end
    @pdfdoc = extract_mail_pdf_part(mail).body.to_s
    logger.info "PDF attachment not found" unless(@pdfdoc)
  end

  def local_scan_handle_mail?
    handle_mail?(config.order_prefix)
  end
end
