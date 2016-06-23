default[:otp][:local_repo_path] = "/opt/OpenTripPlanner"

default[:otp][:base_path] = '/home/otp'

default[:otp][:user] = "otp"
default[:otp][:group] = "otp"

default[:otp][:gtfs_files] = [
  { 'gtfs_bus' => 'https://gitlab.com/LACMTA/gtfs_bus/raw/master/gtfs_bus.zip' },
  { 'gtfs_rail' => 'https://gitlab.com/LACMTA/gtfs_rail/raw/master/gtfs_rail.zip' },
]
