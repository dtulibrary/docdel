ActiveAdmin.register OrderRequest do
  belongs_to :order

  remove_filter :order
end
