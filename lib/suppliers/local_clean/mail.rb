require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_local_clean(mail)
    if mail.from.grep(/reprintsdesk\.com/).count > 0
      case mail.subject
      when /New Order/
        local_clean_new_order(mail)
      when /Download Order/
        local_clean_download(mail)
      when /Cancelled Order/
        local_clean_machine_cancel(mail)
      else
        false
      end
    else
      false
    end
  end

  # Handle new order mail (machine readable)
  def local_clean_new_order(mail)
    local_clean_extract_from_body(mail)
    return false unless @order_number
    logger.info "Cleanup of #{@order_number}"
    true
  end

  def local_clean_download(mail)
    local_clean_extract_from_body(mail)
    return false unless @order_number
    logger.info "Cleanup of #{@order_number}"
    true
  end

  def local_clean_machine_cancel(mail)
    local_clean_extract_from_body(mail)
    return false unless @order_number
    logger.info "Cleanup of #{@order_number}"
    true
  end

  def local_clean_extract_from_body(mail)
    body = extract_mail_text_part(mail).body.to_s

    /orderid: +(\S+)/.match body
    @external_number = $1

    @order_number = nil
    /CustomerReference1: +(\S+)/.match body
    ref = $1
    logger.info "CustomerRef #{ref}"
    if /\A([S]\d+)\z/.match ref
      @order_number = $1
    end
  end
end

