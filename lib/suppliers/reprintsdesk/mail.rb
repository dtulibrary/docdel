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
      else
        logger.info "Reprintsdesk subject "+mail.subject
        false
      end
    else
      false
    end
  end

  private

  # Handle new order mail (machine readable)
  def reprintsdesk_new_order(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    request = @order.request('reprintsdesk', @external_id)
    if request
      request.confirm
      true
    else
      logger.info "Request #{@external_id} not found on order #{@order_number}"
      false
    end
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
    case reprintsdesk_extract_text_part(mail).body.to_s
    when /This order has been canceled/
      reprintsdesk_cancel
    else
      logger.info "Information mail "+reprintsdesk_extract_text_part(mail).body.to_s
      false
    end
  end

  # Handle download order (machine readable)
  def reprintsdesk_download(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    raise ArgumentError unless(@deliver_url)
    request = @order.request('reprintsdesk', @external_id)
    if request
      request.deliver(@deliver_url)
      true
    else
      logger.info "Request #{@external_id} not found on order #{@order_number}"
      false
    end
  end

  def reprintsdesk_machine_cancelled(mail)
    reprintsdesk_extract_from_body(mail)
    return false unless reprintsdesk_handle_mail?
    reprintsdesk_cancel
  end

  def reprintsdesk_cancel
    request = @order.request('reprintsdesk', @external_id)
    if request
      request.cancel if(request.order_status.code != 'cancel')
      true
    else
      logger.info "Request #{@external_id} not found on order #{@order_number}"
      false
    end
  end

  # Extract the external_id, prefix code and order number
  def reprintsdesk_extract_from_body(mail)
    body = reprintsdesk_extract_text_part(mail).body.to_s

    /orderid: ([^ ]+)/.match body
    @external_id = $1

    /CustomerReference1: ([^ ]+)/.match body
    ref = $1
    /(\w+)-(\d+)/.match ref
    @prefix_code = $1
    @order_number = $2

    /download_link: (\S+)/.match body
    @deliver_url = $1
  end

  def reprintsdesk_extract_from_subject(subject)
    / Ref: (\w+)-(\d+)/.match subject
    @prefix_code = $1
    @order_number = $2
    / #(\d+) /.match subject
    @external_id = $1
  end

  def reprintsdesk_extract_text_part(mail)
    if mail.parts.count == 0
      part = mail
    else
      part = nil
      mail.parts.each do |p|
        if /text\/plain/.match p.content_type
          part = p
        end
      end
    end
    part
  end

  def reprintsdesk_handle_mail?
    unless @prefix_code == config.reprintsdesk.order_prefix
      logger.info "Rejecting mail on prefix #{@prefix_code} != "+
        "#{config.reprintsdesk.order_prefix}"
      return false
    end
    @order = Order.find_by_id(@order_number)
    unless @order
      logger.info "Rejecting mail on not found #{@order_number}"
      return false
    end
    true
  end

end
