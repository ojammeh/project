AUP::Application.routes.draw do

  get 'admin' => 'admin#index'
  controller :sessions do
    get  'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  #get "admin/index"
  #get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  resources :users
  resources :shops

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'index#index', as:'index'

  # Example of regular route:
     get 'datawarehouse/track_msisdn'
     get 'datawarehouse/msisdn_tracker'
     get 'datawarehouse/track_imei'
     get 'datawarehouse/imei_tracker'
     get 'datawarehouse/subscriber_records'
     get 'datawarehouse/subscriber_details'
     get 'datawarehouse/sub_details'
     get 'datawarehouse/back_office_logs'
     get 'datawarehouse/office_logs'
     get 'customercare/vas_select'
     get 'customercare/vas'
     get 'customercare/vas_actions'
     post 'customercare/add_details'
     post 'customercare/vas_actions'
     post 'customercare/vas'
     post 'customercare/horoscope'
     post 'customercare/gprs'
     get 'customercare/gprs'
     get 'customercare/rings'
     get 'customercare/invalid_select'
     get 'customercare/over_scratched'
     get 'customercare/invalid'
     get 'customercare/tok'
     post 'customercare/tok'
     get 'customercare/check_registration'
     get 'complaints/search'
     get 'complaints/search_result'
     get 'complaints/new_complaint'
     post 'complaints/new_complaint'
     get 'complaints/status'
     get 'complaints/not_satisfied'
     get 'complaints/dismiss'
     get 'complaints/dismiss_dialout'
     get 'complaints/pending_dialout'
     get 'complaints/pending'
     get 'complaints/foward_complaint'
     post 'complaints/update_tech'
     get 'complaints/update_tech'
     get 'sim_registration/search'
     get 'sim_registration/search_result'
     post 'sim_registration/new'
     get 'sim_registration/new'
     post 'sim_registration/add_new'
     get 'sim_registration/add_new'
     get 'sim_registration/new_add'
     get 'sim_registration/reg_count_select'
     get 'sim_registration/show_image'
     get 'sim_registration/view_image'
     get 'sim_registration/smart_search'
     get 'sim_registration/list_smart'
     get 'sim_registration/validate_smart'
     get 'sim_registration/invalidate_smart'
     get 'sim_registration/search_reg'
     get 'sim_registration/sim_reg_result'
     get 'sim_registration/new_registration'
     get 'sim_registration/unblock_select'
     get 'sim_registration/unblockreg'
     get 'sim_registration/edit'
     post 'sim_registration/edit'
     patch 'sim_registration/update'
     get 'puk/search'
     get 'puk/search_result'
     get 'cos/cos_check_reg'
     get 'cos/cos_select'
     get 'cos/checkreg'
     get 'cos/register'
     get 'cos/new_registration'
     get 'cos/check_reference'
     get 'cyn/cyn_select'
     get 'cyn/cyn_validate'
     get 'cyn/reserve'
     get 'cyn/sell'
     get 'cyn/reserving'
     get 'customercare/new_sheet'
     get 'customercare/new_work_sheet'
     get 'admin/cc_report_select'
     get 'admin/cc_report'
     get 'admin/cc_report_xls'
     get 'admin/manifest_report_select'
     get 'admin/manifest_report'
     get 'admin/manifest_report_xls'
     get 'cashier/receipt'
     get 'cashier/new_receipt'
     get 'cashier/other_receipt'
     get 'cashier/new_other_receipt'
     get 'cashier/products'
     get 'cashier/edit_product'
     post 'cashier/edit_product'
     get 'cashier/delete_product'
     post 'cashier/new_product'
     post 'cashier/update_product'
     post 'cashier/delete_product'
     get 'cashier/report'
     get 'cashier/c_report'
     get 'cashier/c_report_xls'
     get 'directsales/input'
     get 'directsales/list'
     post 'directsales/insert'
     post 'directsales/delete'
     post 'directsales/create_team'
     get 'directsales/add_team'
     get 'directsales/list_teams'
     post 'directsales/edit_team'
     post 'directsales/update_team'
     post 'directsales/delete_team'
     get 'cdr/view_cdr'
     get 'cdr/cdr_select'
     get 'cdr/edit'
     post 'cdr/update'
     get 'hlr/hlr_select'
     get 'hlr/hlr_output'
     get 'hlr/create_sub_select'
     get 'hlr/create_subscriber'
     get 'bsureport/index'
     get 'bsureport/basic'
     get 'it/all_ips'
     get 'it/new_request'
     get 'it/new_it_request'
     post 'it/new_it_request'
     get 'it/pending_requests'
     get 'it/deliver_request'
     get 'sim_registration/reg_count'
     get 'sms/index'
     post 'sms/new'
     get 'arpu/index'
     get 'arpu/update'
     get 'customercare/service_info'
     get 'custcaresales/add_stock_select'
     get 'custcaresales/stock_out_select'
     post 'custcaresales/add_stock'
     post 'custcaresales/stock_out'
     get 'custcaresales/add_item_select'
     post 'custcaresales/add_item'
     get 'custcaresales/list_items'
     get 'custcaresales/delete_item'
     get 'custcaresales/list_transactions'
     get 'custcaresales/stock_in_list'
     get 'custcaresales/bank_money'
     post 'custcaresales/bank'
     get 'custcaresales/list_banked'
     get 'custcaresales/damaged_list'
     get 'custcaresales/damaged_select'
     post 'custcaresales/damaged'
     get 'soap/incall'
     get 'soap/account_details_select'
     get 'soap/account_details'
     get 'cos/create_sim_select'
     post 'cos/create_sim'
     get 'in/account_history'
     get 'in/select_call_history'
     get 'in/select_account_history'
     get 'in/call_history'
     get 'evc/evc_select'
     post 'evc/reverse'
     post 'evc/reverse_transaction'
     post 'evc/reverse_sub'
     post 'evc/reverse_dealer'
     post 'evc/normal_to_evc'
     get  'shops/index'
     get   'shops/show'
     post  'shops/create'
     post  'shops/new_data'
     post 'shops/destroy_data'
     post 'shops/update'
     get 'shops/edit'
     post 'shops/destroy_multiple'
     post 'cugs/home'
     get 'cugs/index'
     post 'cugs/create'
     post 'cugs/new'
     post 'cugs/addnumber'
     post 'cugs/addnum'
     post 'cugs/destroy_number'
     post 'cugs/destroy_multiple'
     post 'cugs/destroy_cug'
     get 'cugs/show'
     post 'cugs/search'
     get 'cugs/details'
     get 'cugs/edit'
     patch 'cugs/update'
     get 'customers/index'
     get 'customers/assign'
     get 'customers/select'
     post 'customers/done'
     post 'customers/update'
     get  'customers/home'
     get  'customers/select'
     post 'customers/new_customer'
     get 'customers/customer_details'
      get 'banks/add_supplier'
     post 'banks/create'
     get 'banks/supplier_bank'
     post 'banks/suppliers_bank'
     get 'banks/supplier_accounts'
     post 'banks/supplier_account'
     get 'banks/africell_banks'
     post 'banks/africell_bank'
     get 'banks/account_types'
     post 'banks/account_type'
     get 'banks/account_numbers'
     post 'banks/account_number'
     get 'banks/b_bans'
     post 'banks/b_ban'
     get 'banks/signatory'
     post 'banks/signatories'
     get 'banks/select_banks'
     get 'banks/list_bank'
     post 'banks/destroy_data'
     get 'banks/edit_bank'
     post 'banks/update_bank'
     get 'banks/list_supplier'
     post 'banks/destroy_supplier'
     get 'banks/edit_supplier'
     post 'banks/update_supplier'
     get 'banks/debit_account'
     get 'banks/generate'
     post 'banks/bank'
     get 'banks/bank'
     get 'banks/publish'
     post 'banks/publish'
     post 'banks/print_log'
     get 'stocks/new'
     get 'stocks/home'
     post 'stocks/new_item'
     get 'stocks/all_stock'
     get 'stocks/edit'
     post 'stocks/update_stock'
     get 'stocks/add_category'
     get 'stocks/add_cat'
     post 'stocks/add_cat'
     get 'stocks/stock_out'
     delete 'stocks/destroy'
     get 'printout/evc_print_out'
     get 'printout/evc_printout'
     get 'printout/evc_select'

     #post 'customercare/invalid'
 # match '/track_msisdn',    to: 'datawarehouse#track_msisdn',    via: 'get'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
