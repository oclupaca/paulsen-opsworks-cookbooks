node[:deploy].each do |app_name, deploy|

  template "#{deploy[:deploy_to]}/current/aws-config.php" do
    Chef::Log.info('Paulsen Wordpress - creating aws-config ')
    source "aws-config.php.erb"
    mode 0660
    group deploy[:group]

    if platform?("ubuntu")
      owner "www-data"
    elsif platform?("amazon")
      owner "apache"
    end

    variables(
      :host => ([:rdshos])
    )

  end

end
