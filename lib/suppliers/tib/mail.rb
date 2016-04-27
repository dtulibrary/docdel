require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_tib(mail)
    # Return true if this is a TIB mail and we handled it

    if mail.from.grep(/other/).count > 0
      #dod1t.tib.uni-hannover.de
      case mail.subject


      when /^ACCEPTED/
        tib_accept(mail)
        return true unless tib_handle_mail?
      when /DELIVERY-FAILED/
        return true unless tib_handle_mail?
      when /^NOT-ACCEPTED/
        return true unless tib_handle_mail?
      when /Status change/
        return true unless tib_handle_mail?
      when /RETRY/
        return true unless tib_handle_mail?
      when /UNFILLED/
        return true unless tib_handle_mail?
      when /WILL-SUPPLY/
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

    #confirm_request('tib')

    # Mark the order in our system as Accepted?
    # Let user know the order was processed?
  end

  def tib_extract_mail_body(mail)

    # call the generic/reusable extract_mail_text_part(mail) to get the email body into a variable
    body = extract_mail_text_part(mail).body.to_s

    #example reg ex gymnastics

    /message-type: +(\S+)/.match body
    @message_type = $1

    /customer-no: +(\S+)/.match body
    @customer_nr = $1

    /responder-note: +(\S+)/.match body
    @responder_note = $1

    /results-explanation: +(\S+)/.match body
    @results_explanation = $1

    /supplier-ordernr: +(\S+)/.match body
    @supplier_ordernr = $1

    # Temp testing
    puts "======================="
    puts "@message_type    : #{@message_type}"
    puts "@customer_nr     : #{@customer_nr}"
    puts "@responder_note  : #{@responder_note}"
    puts "@results_explan  : #{@results_explanation}"
    puts "@supplier_ordernr: #{@supplier_ordernr}"

  end

  def tib_handle_mail?
    handle_mail?(config.order_prefix)
  end

end
