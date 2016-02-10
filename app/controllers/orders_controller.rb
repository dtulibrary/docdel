class OrdersController < ApplicationController
  def index
    @order = Order.all
  end

 def show
   @order = Order.find(params[:id])
   @order_request = @order.system_request('local_scan')
 end

 def not_available
   @order = Order.find(params[:id])
   @order_request = @order.system_request('local_scan')
   @order_request.reason_id = params['order_requests']['reason_id']
   @order_request.reason_text = params['reason_text']
   @order_request.cancel
 end

end
