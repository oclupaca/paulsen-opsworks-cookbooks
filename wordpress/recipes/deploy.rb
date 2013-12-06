require 'uri'
require 'net/http'
require 'net/https'

uri = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
keys = response.body

node[:deploy].each do |app_name, deploy|

    template "#{deploy[:deploy_to]}/current/composer.json" do
        source "composer.json.erb"
        mode 0660
        group deploy[:group]

        if platform?("ubuntu")
          owner "www-data"
        elsif platform?("amazon")
          owner "apache"
        end
    end


    if File.directory?("#{deploy[:deploy_to]}/current")
        script "set_permissions" do
          interpreter "bash"
          user "root"
          cwd "#{deploy[:deploy_to]}/current"
          code <<-EOH
          sudo chown -R apache wp-content
          sudo chown apache .htaccess
          EOH
        end
    end

    # script "set_timezone" do
    #   interpreter "bash"
    #   user "root"
    #   code <<-EOH
    #   cp /usr/share/zoneinfo/America/Chicago /etc/localtime
    #   EOH
    # end

    script "install_composer" do
        interpreter "bash"
        user "root"
        cwd "#{deploy[:deploy_to]}/current"
        code <<-EOH
        curl -s https://getcomposer.org/installer | php
        php composer.phar install
        EOH
    end

    template "#{deploy[:deploy_to]}/current/aws-config.php" do
        source "aws-config.php.erb"
        mode 0660
        group deploy[:group]

        if platform?("ubuntu")
          owner "www-data"
        elsif platform?("amazon")
          owner "apache"
        end

        variables(
            # :database   => (deploy[:database][:database] rescue nil),
            :database   => (app_name rescue nil),
            :user       => (deploy[:database][:username] rescue nil),
            :password   => (deploy[:database][:password] rescue nil),
            :host       => (node[:rdsendpoint] rescue nil),
            :keys       => (keys rescue nil),
            :wp_cache   => (deploy[:wp_cache] rescue nil)
        )
    end

end
