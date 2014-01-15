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

    if File.directory?("#{deploy[:deploy_to]}/current")
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
    end




    # myDirs = ["wp-content", "wp-admin"]
    myDirs = deploy[:writableDirs]

    if defined?myDirs
      if myDirs.kind_of?(Array)
        Chef::Log.info("Paulsen Wordpress - wridableDirs.length is #{deploy[:writableDirs].length}");
        myDirs.each do |dir_name|
          Chef::Log.info("Paulsen Wordpress - CHOWN #{dir_name}")

          # if File.directory?("#{deploy[:deploy_to]}/current")

          #     if File.exist? "#{deploy[:deploy_to]}/current/#{dir_name}"
          #         Chef::Log.info("Paulsen Wordpress - chowning #{deploy[:deploy_to]}/current/#{dir_name}")
          #         script "set_permissions_wp-content" do
          #           interpreter "bash"
          #           user "root"
          #           cwd "#{deploy[:deploy_to]}/current"
          #           code <<-EOH
          #           sudo chown -R apache #{deploy[:deploy_to]}/current/#{dir_name}
          #           EOH
          #         end
          #         Chef::Log.info("Paulsen Wordpress - done chowning #{deploy[:deploy_to]}/current/#{dir_name}")
          #     end

          # end

        end
      end
    end


    if File.directory?("#{deploy[:deploy_to]}/current")
        # if File.exist? "#{deploy[:deploy_to]}/current/wp-content"
        #     Chef::Log.info('Paulsen Wordpress - chowning wp-content')
        #     script "set_permissions_wp-content" do
        #       interpreter "bash"
        #       user "root"
        #       cwd "#{deploy[:deploy_to]}/current"
        #       code <<-EOH
        #       sudo chown -R apache #{deploy[:writableDirs]}
        #       EOH
        #     end
        #     Chef::Log.info("Paulsen Wordpress - done chowning #{deploy[:writableDirs]}")
        # end

        if File.exist? "#{deploy[:deploy_to]}/current/.htaccess"
            Chef::Log.info('Paulsen Wordpress - chowning .htaccess')
            script "set_permissions_htaccess" do
              interpreter "bash"
              user "root"
              cwd "#{deploy[:deploy_to]}/current"
              code <<-EOH
              sudo chown apache .htaccess
              EOH
            end
            Chef::Log.info('Paulsen Wordpress - chowning .htaccess')
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
            # :database   => (deploy[:database][:database] rescue nil),
            :database   => (app_name rescue nil),
            :user       => (node[:rds][:username] rescue nil),
            :password   => (node[:rds][:password] rescue nil),
            :host       => (node[:rds][:endpoint] rescue nil)
        )
    end

end
