require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_tib(mail)
    # Return true if this is a TIB mail and we handled it

    if mail.from.grep(/@tib\.eu$/).count > 0
      #dod1t.tib.uni-hannover.de
      case mail.subject
      when 'ACCEPTED'
        tib_accept(mail)
      when 'DELIVERY-FAILED'
        return true unless tib_handle_mail?
      when 'Status change'
        tib_status_change(mail)
      when 'RETRY'
        return true unless tib_handle_mail?
      when 'WILL-SUPPLY'
        return true unless tib_handle_mail?
      else
        # mail from tib, but unhandled status
        false
      end
    else
      # Mail not from tib
      false
    end
  end

  private

  def tib_accept(mail)
    tib_extract_mail_body(mail)

    return false unless tib_handle_mail?
    confirm_request('tib')

    # Mark the order in our system as Accepted?
    # Let user know the order was processed?
  end

  def tib_status_change(mail)
    tib_extract_mail_body(mail)

    if @message_type == 'ANSWER'
      case @results_explanation
      when 'ACCEPTED'
        # TIB is processing, the next email should arrive in 15 hours?
      when 'UNFILLED'
      when 'NOT-ACCEPTED'
      end
    elsif @message_type == 'SHIPPED'
      # Order has been sent from TIB
      # TODO: Update DRM info
    end

    tib_handle_mail?
    confirm_request('tib')
  end

  def tib_extract_mail_body(mail)

    # call the generic/reusable extract_mail_text_part(mail) to get the email body into a variable
    body = extract_mail_text_part(mail).body.to_s

    /supplier-ordernr: \D*0*(\d+)$/.match body
    @external_number = $1

    # MAX 13 chars after the ':DK'
    # TIBSUBITO:DK201600012
    /transaction-group-qualifier: TIBSUBITO:DK(.)0*(\d+)/.match body
    
    case $1.to_i
    when 1
      @prefix_code = 'PROD'
    when 2
      @prefix_code = 'STAGING'
    when 3
      @prefix_code = 'UNSTABLE'
    when 4
      @prefix_code = 'T'
    end
    
    @order_number = $2

    # TIB unique fields:
    /message-type: +(\S+)/.match body
    @message_type = $1

    /responder-note: +(\S+)/.match body
    @responder_note = $1

    /results-explanation: +(\S+)/.match body
    @results_explanation = $1

    /customer-no: +(\S+)/.match body
    @customer_nr = $1

    # TIB document format: DRM / VGW
    /transaction-qualifier: +(\S+)/.match body
    @transqual = $1

   # # Temp testing
   # puts "======================="
   # puts "@prefix_code     : #{@prefix_code}"
   # puts "@order_number    : #{@order_number}"
   # puts "@external_number : #{@external_number}"
   # puts "======= TIB specific ======"
   # puts "@message_type    : #{@message_type}"
   # puts "@responder_note  : #{@responder_note}"
   # puts "@results_explan  : #{@results_explanation}"
   # puts "@customer_nr     : #{@customer_nr}"
   # puts "======================="

  end

  def tib_handle_mail?
    handle_mail?(config.order_prefix)
  end

end
