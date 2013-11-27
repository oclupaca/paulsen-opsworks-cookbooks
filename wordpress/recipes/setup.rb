packages = [
	'libphp-phpmailer'
]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# include_recipe 'wordpress::bind_mounts'