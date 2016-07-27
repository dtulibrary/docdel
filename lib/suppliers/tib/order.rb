class Order
  def prefix_map
    {
      'PROD'     => '1',
      'STAGING'  => '2',
      'UNSTABLE' => '3',
      'TEST'     => '4'
    }
  end

  def request_from_tib
    request = current_request

    SendIt.tib_request(self,
      :not_available_link => @path_controller.order_url(self),
      :order_id           => "#{prefix_map[config.order_prefix]}#{'%08d' % self.id}",
      :from               => config.tib.from_mail,
      :to                 => config.tib.order_mail
    )

    request.order_status = OrderStatus.find_by_code("request")
    request.save!
    save!
  end
end
