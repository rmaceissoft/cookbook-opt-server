#
# Cookbook Name:: otp-server
# Recipe:: default
#
# Copyright (C) 2015 Reiner Marquez
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt::default"
apt_repository 'openjdk-8' do
  uri 'ppa:openjdk-r/ppa'
  distribution node['lsb']['codename']
end


# Install packages for building OTP locally
%w(openjdk-8-jdk maven git).each do |pkg|
  package pkg
end

# Create Logs folder
directory node[:otp][:deploy_to] do
  mode "0755"
  action :create
end

git node[:otp][:deploy_to] do
  repository node[:opt][:git_repository]
  revision node[:opt][:git_revision]
  action :sync
end

execute "Start a build" do
  cwd node[:otp][:deploy_to]
  command "mvn clean package"
end
