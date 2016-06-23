#
# Cookbook Name:: otp-server
# Recipe:: nginx
#
# Copyright (C) 2015 Reiner Marquez
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nginx'


# Build Nginx conf file
template "/etc/nginx/sites-available/otp" do
  source "otp-nginx.conf.erb"
  owner "root"
  group "root"
  mode 00644
  action :create
  notifies :restart, "service[nginx]", :delayed
end

# disable default site
link "/etc/nginx/sites-enabled/default" do
  action :delete
  only_if 'test -L /etc/nginx/sites-enabled/default'
end

# Symlink the conf file
link "/etc/nginx/sites-enabled/otp" do
  to "/etc/nginx/sites-available/otp"
  owner "root"
  group "root"
  action :create
end