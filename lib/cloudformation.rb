require 'OptionParser'
require_relative 'donkey/cloudformation'

USAGE = <<DOC
usage: donkey cloudformation [options] <command> [parameters]

DOC

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = USAGE

  opts.on('--profile PROFILE') do |profile|
  	options[:profile_name] = profile
  end

  opts.on('--region REGION') do |region|
  	options[:region] = region
  end

  opts.on('--output FORMAT') do |format|
    options[:output] = formatformat.downcase.to_sym
  end

  opts.on("-1", "Don't print column headers") do |v|
    options[:headers] = false
  end

  opts.on("--[no-]headers", "Print column headers") do |v|
    options[:headers] = v
  end
end
optparse.parse!

options[:profile_name] ||= 'default'
options[:output] ||= :table

operation = ARGV.pop || 'list'

case operation.downcase
when 'ls', 'list'
	Donkey::Cloudformation::new.list options
else
	puts "Unknown command '%s'" % operation
	puts optparse
	exit -1
end


