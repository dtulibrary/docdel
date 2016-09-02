class SimulateRdCancelTibDeliverProcess
  def call(our_order_id, rd_order_number, tib_order_number)
    puts "Using our order number: #{our_order_id}!"
    puts "Using RD order number: #{rd_order_number}!"
    puts "Using TIB order number: #{tib_order_number}!"

    order = Order.where(:id => our_order_id).first

    if order.nil?
      puts "Failure! No orders found!"
      exit 2
    end

    puts "Simulating acceptance of order (id:#{order.id})"
    rd_accept_raw = File.read("spec/fixtures/reprintsdesk/new_order.eml")
    rd_replace_our_ordernr(rd_accept_raw, order)
    rd_replace_supplier_ordernr(rd_accept_raw, rd_order_number)
    rd_accept_mail = Mail.new(rd_accept_raw)
    IncomingMailController.receive(rd_accept_mail)
    puts "Order accepted!"

    puts "Simulating cancellation of order (id:#{order.id})"
    cancel_raw = File.read("spec/fixtures/reprintsdesk/cancel_machine.eml")
    rd_replace_supplier_ordernr(cancel_raw, rd_order_number)
    rd_replace_our_ordernr(cancel_raw, order)
    cancel_mail = Mail.new(cancel_raw)
    IncomingMailController.receive(cancel_mail)
    puts "Order cancelled!"

    puts "Simulating acceptance of order (id:#{order.id})"
    tib_accept_raw = File.read("spec/fixtures/tib/stahlbau_accept.eml")
    tib_replace_our_ordernr(tib_accept_raw, order)
    tib_replace_supplier_ordernr(tib_accept_raw, tib_order_number)
    tib_accept_mail = Mail.new(tib_accept_raw)
    IncomingMailController.receive(tib_accept_mail)
    puts "Order accepted!"

    puts "Simulating cancellation of order (id:#{order.id})"
    cancel_raw = File.read("spec/fixtures/tib/stahlbau_cancel.eml")
    tib_replace_our_ordernr(cancel_raw, order)
    tib_replace_supplier_ordernr(cancel_raw, tib_order_number)
    cancel_mail = Mail.new(cancel_raw)
    IncomingMailController.receive(cancel_mail)
    puts "Order cancelled!"
  end

  private

  def rd_replace_supplier_ordernr(text, order_number)
    text.gsub!(/123456/, order_number)
    text.gsub!(/1137271/, order_number)
    text.gsub!(/orderid: 123456/, "orderid: #{order_number}")
  end

  def rd_replace_our_ordernr(text, order)
    text.gsub!(/CustomerReference1: TEST-5000/, "CustomerReference1: TEST-#{order.id}")
    text.gsub!(/Ref: TEST-5000/, "Ref: TEST-#{order.id}")
  end

  def tib_replace_supplier_ordernr(text, order_number)
    text.gsub!(/E033920240/, order_number)
  end

  def tib_replace_our_ordernr(text, order)
    text.gsub!(/TIBSUBITO:DK400000000/, "TIBSUBITO:DK4" + zero_pad_integer(order.id))
  end

  def zero_pad_integer(integer)
    integer.to_s.rjust(8, "0")
  end
end

if ARGV.length < 3
  puts "Insufficient parameters passed."
  puts "Usage: #{$0} <our_order_id> <rd_supplier_order_number> <tib_supplier_order_number>"
  exit 2
end

SimulateRdCancelTibDeliverProcess.new.call(ARGV[0].chomp, ARGV[1].chomp, ARGV[2].chomp)
