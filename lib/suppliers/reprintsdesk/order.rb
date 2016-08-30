require 'time'

class Order
  def request_from_reprintsdesk
    # TODO TLNI: Mock?
    return true if config.respond_to?(:disable_reprintsdesk_request) && config.disable_reprintsdesk_request

    # Find user/password
    user_type = @user['user_type'] || 'other'
    account = config.reprintsdesk.accounts[user_type] ||
              config.reprintsdesk.accounts['default']
    client = Savon.client(
      wsdl: config.reprintsdesk.wsdl,
      env_namespace: :soap,
      soap_version: 1,
      soap_header: {
        'UserCredentials' => {
          'UserName' => account['user'],
          'Password' => account['password'],
        },
        :attributes! => { 'UserCredentials' => { 'xmlns' =>
          "http://reprintsdesk.com/webservices/" }},
      }
    )
    Savon.observers << SavonObserver.new if Rails.env.development?

    request = current_request
    if (issn || eissn) && date
      response = client.call(:order_get_price_estimate,
        message: { issn: issn || eissn, year: date, totalpages: 1 },
        :attributes => { "xmlns" => "http://reprintsdesk.com/webservices/" })
      resp = response.body[:order_get_price_estimate_response]
      if resp[:order_get_price_estimate_result] == "1"
        est = resp[:xml_data][:estimate]
        request.external_service_charge = est[:servicecharge]
        request.external_copyright_charge = est[:copyrightcharge]
        request.external_currency = 'USD'
      end
    end

    timecap_date = nil
    unless config.reprintsdesk.timecaps.nil?
      timecap = config.reprintsdesk.timecaps[user_type] ||
                config.reprintsdesk.timecaps['default']
      logger.info "Timecap #{@timecap_date} + #{timecap}"
      timecap_date = @timecap_date + timecap
    end

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.xmlNode {
        xml.order('xmlns' => '') {
          xml.orderdetail {
          xml.ordertypeid "4"
            xml.deliverymethodid "5"
            xml.comment_ ""
            xml.aulast aulast
            xml.aufirst aufirst
            xml.issn issn
            xml.eissn eissn
            xml.isbn isbn
            xml.title title
            xml.atitle atitle
            xml.volume volume
            xml.issue issue
            xml.spage spage
            xml.epage epage
            xml.pages pages
            xml.date date
          }
          xml.user {
            xml.username account['username']
            xml.email config.reprintsdesk.systemmail
            xml.firstname config.reprintsdesk.firstname
            xml.lastname config.reprintsdesk.lastname
            xml.billingreference id
          }
          xml.deliveryprofile {
            xml.firstname config.reprintsdesk.firstname
            xml.lastname config.reprintsdesk.lastname
            xml.companyname config.reprintsdesk.companyname
            xml.address1 config.reprintsdesk.address1
            xml.address2 config.reprintsdesk.address2
            xml.city config.reprintsdesk.city
            xml.zip config.reprintsdesk.zipcode
            xml.statecode config.reprintsdesk.statecode
            xml.statename config.reprintsdesk.statename
            xml.countrycode config.reprintsdesk.countrycode
            xml.phone config.reprintsdesk.phone
            xml.fax config.reprintsdesk.fax
            xml.email config.reprintsdesk.systemmail
          }
          xml.processinginstructions {
            xml.processinginstruction('id' => '1', 'valueid' => '1')
            xml.processinginstruction('id' => '2', 'valueid' => ['student', 'dtu_empl'].include?(user_type) ? '2' : '0')
            unless timecap_date.nil?
              xml.processinginstruction('id' => '7', 'valueid' => '1') do
                xml.textvalue timecap_date.iso8601
              end
            end
          }
          xml.customerreferences {
            xml.customerreference(config.order_prefix + "-#{id}", 'id' => '1')
            xml.customerreference(user_type.upcase, 'id' => '2')
          }
        }
      }
    end

    response = client.call(:order_place_order2,
      message: builder.to_xml(:save_with =>
        Nokogiri::XML::Node::SaveOptions::NO_DECLARATION),
      attributes: { "xmlns" => "http://reprintsdesk.com/webservices/" })
    resp = response.body[:order_place_order2_response]
    if resp[:order_place_order2_result] == "1"
      request.external_number = resp[:order_id].to_s
      request.order_status = OrderStatus.find_by_code("request")
    else
      logger.warn "RD failed response #{response.body.inspect}"
    end
    unless request.save
      logger.warn "Request save failed #{request.errors}"
    end
    unless save
      logger.warn "Order save failed #{self.errors}"
    end
  end

end
