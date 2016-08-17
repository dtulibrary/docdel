class SimulateTibProcess
  def call(order_number)
    puts "Using order number: #{order_number}!"

    order = Order.order(:created_at).last

    if order.nil?
      puts "Failure! No orders found!"
      exit 2
    end

    puts "Simulating acceptance of order (id:#{order.id})"
    accept_raw = File.read("spec/fixtures/tib/stahlbau_accept.eml")
    replace_transaction_group_qualifier(accept_raw, order)
    replace_supplier_ordernr(accept_raw, order_number)
    accept_mail = Mail.new(accept_raw)
    IncomingMailController.receive(accept_mail)
    puts "Order accepted!"

    puts "Simulating delivery of order (id:#{order.id})"
    deliver_raw = File.read("spec/fixtures/tib/stahlbau_deliver.eml")
    replace_supplier_ordernr(deliver_raw, order_number)
    deliver_mail = Mail.new(deliver_raw)
    IncomingMailController.receive(deliver_mail)
    puts "Order delivered!"
  end

  private

  def replace_supplier_ordernr(text, order_number)
    text.gsub!(/E033920240/, order_number)
  end

  def replace_transaction_group_qualifier(text, order)
    text.gsub!(/TIBSUBITO:DK400000000/, "TIBSUBITO:DK4" + zero_pad_integer(order.id))
  end

  def zero_pad_integer(integer)
    integer.to_s.rjust(8, "0")
  end
end

if ARGV.length < 1
  puts "Insufficient parameters passed."
  puts "Usage: #{$0} <supplier_order_number>"
  exit 2
end

SimulateTibProcess.new.call(ARGV[0].chomp)
