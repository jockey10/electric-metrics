require 'yaml'
require 'optparse'

=begin
This script can be used to patch a deployment config for the 
OpenShift 'Electric Metrics' demo.
=end

delete=false

opt_parser = OptionParser.new do |opt|
  opt.banner = " Usage: ruby prom-patcher.rb EXPORTED_DC_FILE.yml"
  opt.separator ""
  opt.separator " Options:"

  opt.on "-h","--help","Print help" do
    puts opt
    exit
  end

  opt.on "-v","--version","Display version" do
    puts "Prometheus DeploymentConfig Patcher v1.0.0"
    exit
  end

  opt.separator ""

end

unless ARGV[0]
  puts opt_parser
  exit
end

opt_parser.parse!

file = YAML::load_file(ARGV[0])
volumeMounts = {"mountPath"=>"/etc/prometheus","name"=>"electric-prom-config-vol-1"}
puts "INFO :: Patching the volume mounts config"
file["spec"]["template"]["spec"]["containers"][0]["volumeMounts"] << volumeMounts

puts "INFO :: Patching the volume definitions"
volumes = {"configMap"=>{"defaultMode"=>420,"name"=>"electric-prom-config"},"name"=>"electric-prom-config-vol-1"}
file["spec"]["template"]["spec"]["volumes"] << volumes

puts "INFO :: Patching the metadata"
file["metadata"] = {"labels"=>{"app"=>"prometheus"},"name"=>"prometheus"}

puts "INFO :: Remove the status section"
file.delete("status")

# Patch and cleanup
File.open(ARGV[0],'w') {|f| f.write file.to_yaml }
puts "INFO :: Successfully patched deployment config #{ARGV[0]}"
