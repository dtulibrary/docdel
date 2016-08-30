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

    puts "Simulating cancellation of order (id:#{order.id})"
    cancel_raw = File.read("spec/fixtures/reprintsdesk/cancel_machine.eml")
    rd_replace_supplier_ordernr(cancel_raw, rd_order_number)
    rd_replace_our_ordernr(cancel_raw, order)
    cancel_mail = Mail.new(cancel_raw)
    IncomingMailController.receive(cancel_mail)
    puts "Order cancelled!"

    puts "Simulating acceptance of order (id:#{order.id})"
    accept_raw = File.read("spec/fixtures/tib/stahlbau_accept.eml")
    tib_replace_our_ordernr(accept_raw, order)
    tib_replace_supplier_ordernr(accept_raw, tib_order_number)
    accept_mail = Mail.new(accept_raw)
    IncomingMailController.receive(accept_mail)
    puts "Order accepted!"

    puts "Simulating delivery of order (id:#{order.id})"
    deliver_raw = File.read("spec/fixtures/tib/stahlbau_deliver.eml")
    tib_replace_supplier_ordernr(deliver_raw, tib_order_number)
    deliver_mail = Mail.new(deliver_raw)
    IncomingMailController.receive(deliver_mail)
    puts "Order delivered!"
  end

  private

  def rd_replace_supplier_ordernr(text, order_number)
    text.gsub!(/123456/, order_number)
  end

  def rd_replace_our_ordernr(text, order)
    text.gsub!(/CustomerReference1: TEST-5000/, "CustomerReference1: TEST-#{order.id}")
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
