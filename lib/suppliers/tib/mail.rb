require 'base64'
require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_tib(mail)
    # Return true if this is a TIB mail and we handled it

    if mail.from.grep(/@tib\.eu$/).count > 0
      case mail.subject
      when 'Status change'
        tib_handle_mail?(mail) && tib_status_change(mail)
      when /^Lieferung zu Bestellung/
        tib_handle_delivery?(mail) && tib_deliver(mail)
      else
        # TODO: Mail from tib, but unhandled status - perhaps this should be logged?
        false
      end
    else
      # Mail not from tib
      false
    end
  end

  private

  def tib_status_change(mail)
    case @message_type
    when 'ANSWER'
      tib_status_answer
    when 'SHIPPED'
      tib_status_shipped
    else
    end
  end

  def tib_status_answer
    case @results_explanation
    when 'ACCEPTED'
      # TIB confirmed that they will deliver
      confirm_request('tib')
    when 'UNFILLED'
      # TIB will not deliver
      cancel_request('tib')
    when 'NOT-ACCEPTED'
      # Bad or inadequate request
      cancel_request('tib')
    else
    end
  end

  def tip_status_shipped
    # Order has been sent from TIB
    # TODO: Update DRM info
  end

  def tib_deliver(mail)
    tib_extract_delivery(mail)
    return false unless @pdf
    url = StoreIt.store_pdf(Base64.encode64(@pdf), 'application/octet-stream', drm: true)
    deliver_request('tib', url)
  end

  def prefix_map
    {
      '1' => 'PROD',     # Production
      '2' => 'STAGING',  # Staging
      '3' => 'UNSTABLE', # Unstable
      '4' => 'TEST'      # Test
    }
  end

  def tib_extract_mail_body(mail)
    return if @mail_body_extracted
    
    text_part = extract_mail_text_part(mail)
    return if text_part.nil?

    body = text_part.body.to_s

    # TIB controlled number
    /supplier-ordernr: (\S+)/.match body
    @external_number = $1


    # Combination of service qualifier (TIB controlled) and our "prefix + zero-padded" order number
    # Note that TIB doesn't support letters in the value supplied by us, so we use a mapping of
    # our normal prefixes for TIB.
    # Example for a production order with order number 1234: "TIBSUBITO:DK2016100001234"
    /transaction-group-qualifier: TIBSUBITO:DK(.)0*(\d+)/.match body
    @prefix_code  = prefix_map[$1] 
    @order_number = $2

    # TIB unique fields:
    /message-type: (\S+)/.match body
    @message_type = $1

    /responder-note: ([^\n]+)/.match(body) { |m| @responder_note = m[1] }

    /results-explanation: (\S+)/.match body
    @results_explanation = $1

    # TIB document format: DRM / VGW
    /transaction-qualifier: (\S+)/.match body
    @transqual = $1
    
    if @transqual
      @drm = @transqual.upcase.match(/DRM/)
    end
    

    # Temp testing
    logger.info "======================="
    logger.info "@prefix_code     : #{@prefix_code}"
    logger.info "@order_number    : #{@order_number}"
    logger.info "@external_number : #{@external_number}"
    logger.info "@message_type    : #{@message_type}"
    logger.info "@responder_note  : #{@responder_note}"
    logger.info "@results_explan  : #{@results_explanation}"
    logger.info "@customer_nr     : #{@customer_nr}"
    
    @mail_body_extracted = true
  end

  def tib_extract_mail_subject(mail)
    m = mail.subject.match(/Lieferung zu Bestellung (\S+)$/)
    @external_number = m[1] unless m.nil? 
  end

  def tib_extract_delivery(mail)
    return if @delivery_extracted
    part = extract_mail_octet_streams(mail).select {|p| p.content_description == "#{@external_number}.pdf"}.first
    @pdf = part.body.to_s if part
    @delivery_extracted = true
  end

  def tib_handle_delivery?(mail)
    tib_extract_mail_subject(mail)
    valid_order_request?(@external_number)
  end

  def tib_handle_mail?(mail)
    tib_extract_mail_body(mail)
    handle_mail?
  end

end
