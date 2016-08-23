require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_reprintsdesk(mail)
    if mail.from.grep(/reprintsdesk\.com/).count > 0
      case mail.subject
      when /New Order/
        reprintsdesk_new_order(mail)
      when /Reprints Desk Article Order Confirmation/
        reprintsdesk_confirmation(mail)
      when /Reprints Desk message: Important Information/
        reprintsdesk_information(mail)
      when /Download Order/
        reprintsdesk_download(mail)
      when /Cancelled Order/
        reprintsdesk_machine_cancelled(mail)
      when /Reprints Desk (?:article|LinkOut) delivery/
        reprintsdesk_delivery_mail(mail)
      else
        logger.info "Reprintsdesk unhandled subject "+mail.subject
        false
      end
    else
      logger.info "No case matched in mail subject"
      false
    end
  end

  private

  # Handle new order mail (machine readable)
  def reprintsdesk_new_order(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    confirm_request('reprintsdesk')
  end

  # Handle confirmation mail (human mail)
  def reprintsdesk_confirmation(mail)
    reprintsdesk_extract_from_subject(mail.subject)
    return false unless reprintsdesk_handle_mail?
    # We simply ignore this
    true
  end

  # Handle information mail (human mail)
  def reprintsdesk_information(mail)
    reprintsdesk_extract_from_subject(mail.subject)
    return false unless reprintsdesk_handle_mail?
    case extract_mail_text_part(mail).body.to_s
    when /This order has been canceled/
      reprintsdesk_cancel
    else
      logger.info "Unhandled information mail "+
        extract_mail_text_part(mail).body.to_s
      false
    end
  end

  # Handle download order (machine readable)
  def reprintsdesk_download(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    raise ArgumentError unless(@deliver_url)
    deliver_request('reprintsdesk', @deliver_url)
  end

  def reprintsdesk_machine_cancelled(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    reprintsdesk_cancel
  end

  def reprintsdesk_delivery_mail(mail)
    reprintsdesk_extract_from_subject(mail.subject)
    return false unless reprintsdesk_handle_mail?
    request = @order.request('reprintsdesk', @external_number)
    logger.info "Creating RD order #{request.inspect}"
    return true if request && request.order_status.code == 'deliver'
    false
  end

  def reprintsdesk_cancel
    cancel_request('reprintsdesk')
  end

  # Extract the external_number, prefix code and order number
  def reprintsdesk_extract_from_body(mail)
    body = extract_mail_text_part(mail).body.to_s

    /orderid: +(\S+)/.match body
    @external_number = $1

    /CustomerReference1: +(\S+)/.match body
    ref = $1
    /(\w+)-(\d+)/.match ref
    @prefix_code = $1
    @order_number = $2

    /download_link: (\S+)/.match body
    @deliver_url = $1 ? $1.gsub('&amp;', '&') : nil
  end

  def reprintsdesk_extract_from_subject(subject)
    / Ref: (\w+)-(\d+)/.match subject
    @prefix_code = $1
    @order_number = $2
    / #(\d+) /.match subject
    @external_number = $1

    logger.info "======= RD ========"
    logger.info "@prefix_code     : #{@prefix_code}"
    logger.info "@order_number    : #{@order_number}"
    logger.info "@external_number : #{@external_number}"

  end

  def reprintsdesk_handle_mail?
    handle_mail?(config.order_prefix)
  end

end
