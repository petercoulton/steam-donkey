require 'aws-sdk'
require_relative 'output'

module Donkey
	class Cloudformation
		def list(options = {})
			options[:output] ||= :csv

			output = Donkey::Output::Printer.new({:output => options[:output]})
			output.add_header 'Name'
			output.add_header 'Status'
			output.add_header 'Created'
			output.add_header 'Last Updated'

			client_options = {}
			client_options[:credentials] = Aws::SharedCredentials.new({:profile_name => options[:profile_name]}) if options.has_key? :profile_name
			client_options[:region] = options[:region] if options.has_key? :region

			cloudformation = Aws::CloudFormation::Client.new client_options
			cloudformation.describe_stacks.each do |response|
				response.stacks.each do |stack|
					output.add_row do
						output.add_column 'Name', stack.stack_name
						output.add_column 'Status', stack.stack_status, :color => (stack.stack_status.include?('FAILED') ? :red : :green)
						output.add_column 'Created', stack.creation_time
						output.add_column 'Last Updated', stack.last_updated_time
					end
				end
			end

			output.print options
		end
	end
end