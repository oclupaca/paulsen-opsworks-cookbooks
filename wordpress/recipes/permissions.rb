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

node[:permissions].each do |app_name, permissions|


    script "set_permissions" do
        interpreter "bash"
        user "root"
        cwd "#{deploy[:deploy_to]}/current"
        code <<-EOH
        mkdir thisIsNew
        EOH
    end



end
