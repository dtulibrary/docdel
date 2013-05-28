class Order
  def request_from_reprintsdesk
    client = Savon.client(
      wsdl: config.reprintsdesk.wsdl,
      env_namespace: :soap,
      soap_version: 2,
      soap_header: '<UserCredentials xmlns="http://reprintsdesk.com/webservices/"><UserName>'+config.reprintsdesk.user+'</UserName><Password>'+config.reprintsdesk.password+'</Password></UserCredentials>'
    )
    Savon.observers << SavonObserver.new if Rails.env.development?

    request = current_request
    response = client.call(:order_get_price_estimate,
      message: { issn: issn || eissn, year: date, totalpages: 1 },
      :attributes => { "xmlns" => "http://reprintsdesk.com/webservices/" })
    if response.body[:order_get_price_estimate_response][:order_get_price_estimate_result] == "1"
      request.external_service_charge = response.body[:order_get_price_estimate_response][:xml_data][:estimate][:servicecharge]
      request.external_copyright_charge = response.body[:order_get_price_estimate_response][:xml_data][:estimate][:copyrightcharge]
    end

    message = {
      xmlNode: {
        order: {
          orderdetail: {
            ordertypeid: "4",
            deliverymethodid: "5",
            comment: "",
            aulast: aulast,
            aufirst: aufirst,
            issn: issn,
            eissn: eissn,
            isbn: isbn,
            title: title,
            atitle: atitle,
            volume: volume,
            issue: issue,
            spage: spage,
            epage: epage,
            pages: pages,
            date: date,
          },
          user: {
            username: config.reprintsdesk.username,
            email: config.reprintsdesk.systemmail,
            firstname: config.reprintsdesk.firstname,
            lastname: config.reprintsdesk.lastname,
            billingreference: id,
          },
          deliveryprofile: {
            firstname: config.reprintsdesk.firstname,
            lastname: config.reprintsdesk.lastname,
            companyname: config.reprintsdesk.companyname,
            address1: config.reprintsdesk.address1,
            address2: config.reprintsdesk.address2,
            city: config.reprintsdesk.city,
            statecode: config.reprintsdesk.statecode,
            statename: config.reprintsdesk.statename,
            zip: config.reprintsdesk.zipcode,
            countrycode: config.reprintsdesk.countrycode,
            email: email,
            phone: config.reprintsdesk.phone,
            fax: config.reprintsdesk.fax,
          },
          processinginstructions: {
            processinginstruction: ['', ''],
            :attributes! => { :processinginstruction => { 'id' => ['1', '2'], 'valueid' => ['1', '0'] } },
          },
          customerreferences: {
            customerreference: [id.to_s, 'OTHER'],
            :attributes! => { :customerreference => { 'id' => ['1', '2'] } },
          },
        },
        :attributes! => { :order => { 'xmlns' => '' } },
      }
    }
    response = client.call(:order_place_order2,
      message: message,
      attributes: { "xmlns" => "http://reprintsdesk.com/webservices/" })
    # If response ok, update request with information
    # update status to requested.
    request.save!
    save!
  end
end
