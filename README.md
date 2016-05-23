DocDel (docdel)
========

Delivery Proxy gateway


Suppliers
---------

In order to deliver something you need one or more suppliers. The code for the supplier are in lib/suppliers. Each supplier must extend the Order class with a request_from_<supplier>

The default supplier is: _reprintsdesk_


Configuration
-------------

In order to be able to request anything you need to enable the suppliers that you want. You must also give any configuration that the supplier need in order to process the request, that might be accountinformation, email-address, billing information or whatever. Add the configuration to config/initializiers.

An example:

```ruby
require "order"
require "suppliers/reprintsdesk.rb"

Docdel::Application.configure do
  config.reprintsdesk.wsdl = 'https://www.demo.reprintsdesk.com/webservice/main.asmx?wsdl'
  config.reprintsdesk.user = <reprintsdesk account name>
  config.reprintsdesk.password = <password for account>
  config.reprintsdesk.username = <reprintdesk user name>
  config.reprintsdesk.firstname = 'Firstname of requestor'
  config.reprintsdesk.lastname = 'Lastname of requestor'
  config.reprintsdesk.companyname = 'Companyname of requstor'
  config.reprintsdesk.address1 = 'Address line 1 of requestor'
  config.reprintsdesk.address2 = ''
  config.reprintsdesk.city = 'City of requstor'
  config.reprintsdesk.zip = 'Zipcode of requestor'
  config.reprintsdesk.statecode = 'Statecode of requestor (US)'
  config.reprintsdesk.statename = 'Statename of requestor (Non-US)'
  config.reprintsdesk.countrycode = 'Country code of requestor'
  config.reprintsdesk.phone = 'Phone number of requestor'
  config.reprintsdesk.fax = 'Fax number of requestor'
  config.reprintsdesk.systemmail = <email address for system e-mail'
end
```

Parameters:
-----------

Creating an order is done by POST to rest/orders.
The following parameters must be supplied:

Parameter      | Description
---------------|----------------------------------------
 open_url      |  Open url for the item to be ordered.
 callback_url  |  The url to call when something happens. The url will be appended with status=<new status> as parameter 
 supplier      |  The supplier to use.
 email         |  The email address of the customer.

Optional parameters:

Parameter        | Description
-----------------|-----------------------------------------------
 dibs_order_id   |  The ID number the customer has for this order
