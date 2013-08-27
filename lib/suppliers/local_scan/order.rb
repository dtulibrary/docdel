class Order < ActiveRecord::Base

  def request_from_local_scan
    # Send email to scanning team
    request = current_request
    SendIt.local_scan_request self, {
      :not_available_link => @path_controller.rest_order_not_available_url(self),
      :order_id => "#{config.order_prefix}-#{self.id}",
      :from => config.local_scan.from_mail,
      :to => config.local_scan.order_mail }
    request.external_number = self.id
    request.order_status = OrderStatus.find_by_code("request")
    request.save!
    save!
  end
end
