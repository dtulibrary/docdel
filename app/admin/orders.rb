ActiveAdmin.register Order do
  menu :priority => 1

  action_item do
    link_to I18n.t('haitstsu.admin.orders.deliver'),
      :controller => "orders", :action => "deliver"
  end

  controller do
    def deliver
      order = Order.find_by_id(params[:id])
      # Create url to static pdf file
      order.deliver(url)
      # Send e-mail of delivery
    end
  end
end
