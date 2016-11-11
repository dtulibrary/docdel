class Rest::OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.json { render :json => @order, :include => {:order_requests => {:include => [:order_status]}} }
    end
  end

  def create
    @order = Order.create_from_param(params, self)

    respond_to do |format|
      format.json { render :json => @order, :status => @order ? 200 : 404 }
    end
  end

  # TODO TLNI: Update all fields ... Or rename this method
  def update
    @order = Order.find(params[:id])
    return if @order.nil?

    @order.path_controller = self

    system = params[:supplier]
    external_sys = ExternalSystem.find_by_code(system)
    request = @order.current_request
    return if request.nil?

    # Has the supplier changed?
    if request.external_system != external_sys
      new_request = OrderRequest.new
      new_request.order = @order
      new_request.order_status = OrderStatus.find_by_code('new')
      new_request.external_system = external_sys

      # Return error if we can't validate and save the record
      new_request.valid? or raise "Request not valid"
      new_request.save

      # Send a request to the new supplier
      @order.send("request_from_"+system)
    end

    @order.save!

    respond_to do |format|
      format.json { render :json => @order, :status => 200 }
    end
  end

end
