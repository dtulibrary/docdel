ActiveAdmin.register Order do
  menu :priority => 1

  filter :atitle
  filter :email
  filter :customer_order_number
  filter :user_type
  filter :delivered_at
  filter :created_at
  filter :updated_at

  index do
    column :customer_order_number
    column :atitle
    column :email
    column :delivered_at
    column :created_at
    column :updated_at
    default_actions
  end

  member_action :deliver, :method => :get do
    order = Order.find_by_id(params[:id])
    pdfdoc = File.read("#{Rails.root}/public/Order_PlaceHolder.pdf")
    url = StoreIt.store_pdf(pdfdoc, 'application/pdf')
    order.current_request.deliver(url)
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
      column :link do |order_req|
        link_to I18n.t('haitatsu.admin.request.more'),
          admin_order_order_requests_path(order)
      end
      column :external_system
      column :order_status
    end
  end

end
