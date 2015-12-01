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
  distribution node[:lsb][:codename]
end

# Install packages for building OTP locally
%w(openjdk-8-jdk git).each do |pkg|
  package pkg
end

# Install maven via a cookbook
include_recipe "maven::default"

# Create User
user node[:otp][:user] do
  home "/home/#{node[:otp][:user]}"
  supports :manage_home=>true
  shell "/bin/bash"
  system true
end

directory "/home/#{node[:otp][:user]}/.ssh/" do
  owner node[:otp][:user]
  group node[:otp][:group]
  mode "0700"
  action :create
end

# create a private key file
file "/home/#{node[:otp][:user]}/.ssh/id_rsa" do
  content node[:otp][:git_key]
  owner node[:otp][:user]
  group node[:otp][:group]
  mode 00600
  action [:delete, :create]
end

# Create OTP main folder
directory node[:otp][:local_repo_path] do
  owner node[:otp][:user]
  group node[:otp][:group]
  mode "0755"
  action :create
end

# script with ssh wrapper to git
file "/home/#{node[:otp][:user]}/git_wrapper.sh" do
  owner node[:otp][:user]
  group node[:otp][:group]
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -o \"StrictHostKeyChecking=no\" -i /home/#{node[:otp][:user]}/.ssh/id_rsa \"$@\""
end

# clone OTP source code from git repo
git node[:otp][:local_repo_path] do
  group node[:otp][:group]
  user node[:otp][:user]
  repository node[:otp][:git_repository]
  revision node[:otp][:git_revision]
  ssh_wrapper "/home/#{node[:otp][:user]}/git_wrapper.sh"
  action :sync
end

# build JAR file from the OTP source code
# TODO: maven command is returning the following error. fix it
#
execute "Start a build" do
  group node[:otp][:group]
  user node[:otp][:user]
  cwd node[:otp][:local_repo_path]
  environment ({"PATH" => "/usr/local/maven-3.1.1/bin:#{ENV['PATH']}"})
  command "mvn clean package"
  not_if { ::File.exists?("#{node[:otp][:local_repo_path]}/otp") }
end

directory ::File.join(node[:otp][:base_path], 'cache') do
  owner node[:otp][:user]
  group node[:otp][:group]
  mode "0755"
  action :create
end

directory ::File.join(node[:otp][:base_path], 'graphs', 'lax') do
  owner node[:otp][:user]
  group node[:otp][:group]
  mode "0755"
  action :create
  recursive true
end

# download GTFS feed for Metro Los Angeles
remote_file ::File.join(node[:otp][:base_path], 'graphs', 'lax', 'gtfs.zip') do
  source 'http://developer.metro.net/gtfs/google_transit.zip'
  owner node[:otp][:user]
  group node[:otp][:group]
  mode '0755'
  action :create
end

# Download OpenStreetMap database
remote_file ::File.join(node[:otp][:base_path], 'graphs', 'lax', 'los-angeles_california.osm.pbf') do
  source 'https://s3.amazonaws.com/metro-extracts.mapzen.com/los-angeles_california.osm.pbf'
  owner node[:otp][:user]
  group node[:otp][:group]
  mode '0755'
  action :create
end

# OTP Configuration files
template ::File.join(node[:otp][:base_path], 'otp-config.json') do
  source 'otp-config.json.erb'
  owner node[:otp][:user]
  group node[:otp][:group]
  mode '0755'
end

template ::File.join(node[:otp][:base_path], 'graphs', 'lax', 'build-config.json') do
  source 'build-config.json.erb'
  owner node[:otp][:user]
  group node[:otp][:group]
  mode '0755'
end

template ::File.join(node[:otp][:base_path], 'graphs', 'lax', 'router-config.json') do
  source 'router-config.json.erb'
  owner node[:otp][:user]
  group node[:otp][:group]
  mode '0755'
end

# build graph and get Grizzly server running
# java -Xmx2G -jar otp-0.20.0-SNAPSHOT-shaded.jar --build /home/otp/graphs/lax --basePath /home/otp --preFlight
#
execute "Build graph and get Grizzly server running" do
  group node[:otp][:group]
  user node[:otp][:user]
  cwd ::File.join(node[:otp][:local_repo_path], "target")
  command "java -Xmx2G -jar otp-0.20.0-SNAPSHOT-shaded.jar --build #{node[:otp][:base_path]}/graphs/lax --basePath #{node[:otp][:base_path]} --preFlight"
end
