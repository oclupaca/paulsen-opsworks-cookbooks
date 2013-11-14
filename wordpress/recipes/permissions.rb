node[:deploy].each do |app_name, deploy|
  execute "modify-permissions" do
    command "mkdir testDir"
    # not_if "/usr/bin/mysql -u#{deploy[:database][:username]} -p#{deploy[:database][:password]} #{deploy[:database][:database]} -e'SHOW TABLES' | grep #{node[:phpapp][:dbtable]}"
    action :run
  end
end