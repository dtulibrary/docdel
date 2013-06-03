class Rest::OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.json { render :json => @order }
    end
  end

  def create
    @order = Order.create_from_param(params, self)

    respond_to do |format|
      format.json { render :json => @order, :status => @order ? 200 : 404 }
    end
  end

  if Rails.env.development?
    def test
      request = eval(File.read("test_order.local.rb"))
      request.each do |k, v|
        params[k] = v
      end

      @order = Order.create_from_param(params, self)
      respond_to do |format|
        format.json { render :json => @order, :status => @order ? 200 : 404 }
      end
    end
  end
end
