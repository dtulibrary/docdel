require 'incoming_mail_controller'

class IncomingMailController
  def supplier_mail_check_tib(mail)
    # Return true if this is a TIB mail and we handled it

    if mail.from.grep(/other/).count > 0
      #dod1t.tib.uni-hannover.de
      case mail.subject


      when /^ACCEPTED/
        # unconfirmed
        return true
      when /DELIVERY-FAILED/
        return true
      when /^NOT-ACCEPTED/
        return true
      when /Status change/
        # Confirmed, this was the email reply jimmy got 
        return true
      when /RETRY/
        return true
      when /UNFILLED/
        return true
      when /WILL-SUPPLY/
        return true

      else
        # mail from tib, but unhandled status
        false
      end
    else
      # Mail not from tib
      false
    end
      
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

    /result-explanation: +(\S+)/.match body
    @result_explanation = $1

    /supplier-ordernr: +(\S+)/.match body
    @supplier_ordernr = $1
  end

  private

end
