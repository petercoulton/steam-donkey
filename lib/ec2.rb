require 'OptionParser'
require_relative 'donkey/ec2'

USAGE = <<DOC
usage: donkey ec2 [options] <command> [parameters]

DOC

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = USAGE

  opts.on('--name NAME') do |profile|
    options[:profile_name] = profile
  end

  opts.on('--profile PROFILE') do |profile|
    options[:profile_name] = profile
  end

  opts.on('--region REGION') do |region|
    options[:region] = region
  end

  opts.on('--output FORMAT') do |format|
    options[:output] = format.downcase.to_sym
  end

  opts.on("-1", "Don't print column headers") do |v|
    options[:headers] = false
  end

  opts.on("--[no-]headers", "Toggle  column headers") do |v|
    options[:headers] = v
  end
end
optparse.parse!

options[:profile_name] ||= 'default'
options[:output] ||= :table

operation = ARGV.pop || 'list'

case operation.downcase
  when 'ls', 'list'
    Donkey::EC2::new.list options
  when 'ssh'
    Donkey::EC2::new.ssh options
  else
    puts "Unknown command '%s'" % operation
    puts optparse
    exit -1
end


