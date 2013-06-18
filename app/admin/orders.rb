ActiveAdmin.register Order do
  menu :priority => 1

  filter :atitle
  filter :email
  filter :delivered_at
  filter :created_at
  filter :updated_at

  index do
    column :atitle
    column :email
    column :delivered_at
    column :created_at
    column :updated_at
    default_actions
  end

  member_action :deliver, :method => :get do
    order = Order.find_by_id(params[:id])
    # Create url to static pdf file
    order.current_request.deliver(url_for '/Order_PlaceHolder.pdf')
    # Send e-mail of delivery
    redirect_to admin_order_path
  end

  member_action :cancel, :method => :get do
    order = Order.find_by_id(params[:id])
    order.current_request.cancel
    redirect_to admin_order_path
  end

  action_item :only => :show, :if => proc { !Rails.env.production? } do
    link_to I18n.t('haitatsu.admin.order.deliver'), deliver_admin_order_path
  end

  action_item :only => :show, :if => proc { !Rails.env.production? } do
    link_to I18n.t('haitatsu.admin.order.cancel'), cancel_admin_order_path
  end

  sidebar 'orders.requests', :only => [ :show ] do
    table_for(order.order_requests) do
      column :link do |order|
        link_to I18n.t('haitatsu.admin.request.more'), admin_order_order_requests_path(order)
      end
      column :external_system
      column :order_status
    end
  end

end
