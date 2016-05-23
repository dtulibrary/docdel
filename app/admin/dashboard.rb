ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel I18n.t("docdel.admin.order.recent_ordered") do
          ul do
            Order.recent.map do |o|
              li link_to o.atitle, admin_order_path(o)
            end
          end
        end
      end

      column do
        panel I18n.t("docdel.admin.order.recent_delivered") do
          ul do
            Order.recent_delivered.map do |o|
              li link_to o.atitle, admin_order_path(o)
            end
          end
        end
      end
    end
  end # content
end
