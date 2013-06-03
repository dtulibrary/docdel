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
    @order.request('reprintsdesk', @external_id).confirm
    true
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
      @order.request('reprintsdesk', @external_id).cancel
      true
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
    @order.request('reprintsdesk', @external_id).deliver(@deliver_url)
    true
  end

  # Extract the external_id, prefix code and order number
  def reprintsdesk_extract_from_body(mail)
    body = reprintsdesk_extract_text_part(mail).body.to_s

    / orderid: ([^ ]+)/.match body
    @external_id = $1

    / CustomerReference1: ([^ ]+)/.match body
    ref = $1
    /(\w+)-(\d+)/.match ref
    @prefix_code = $1
    @order_number = $2

    / download_link: (\S+)/.match body
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
    part = nil
    mail.parts.each do |p|
      if /text\/plain/.match p.content_type
        part = p
      end
    end
    part
  end

  def reprintsdesk_handle_mail?
    return false unless @prefix_code == config.reprintsdesk.order_prefix
    @order = Order.find_by_id(@order_number)
    return false unless @order
    true
  end

end
