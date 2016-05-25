class Order
  def request_from_tib
    # TODO: Send TIB order mail
    request = current_request
    SendIt.tib_request self, {
      # TODO: these are copied from local_scan/order.rb
      :not_available_link => @path_controller.order_url(self),
      :order_id => "#{config.order_prefix}#{'%08d' % self.id}",
      :from => config.tib.from_mail,
      :to => config.tib.order_mail
    }

    request.external_number = self.id
    request.order_status = OrderStatus.find_by_code("request")
    request.save!
    save!

  end
end
