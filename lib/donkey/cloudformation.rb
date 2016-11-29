require 'aws-sdk'
require_relative 'output'
require_relative 'ec2'

module Donkey
  class Cloudformation
    def delete_stack(options = {})
      options[:output] ||= :csv

      cloudformation = cloudformation(options)
      cloudformation.delete_stack({stack_name: options[:name]})
      list options
    end

    def list(options = {})
      options[:output] ||= :csv

      output = Donkey::Output::Printer.new(printer_options(options))

      output.add_header 'Name'
      output.add_header 'Status'
      output.add_header 'Created'
      output.add_header 'Last Updated'

      cloudformation = cloudformation(options)
      responses = cloudformation.describe_stacks

      responses.each do |response|
        stacks = response.stacks
        stacks = stacks.select { |stack| stack.stack_name == options[:name] } if options.has_key?(:name)

        stacks.each do |stack|
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

    def printer_options(options)
      {:output => options[:output]}
    end

    def cloudformation(options)
      Aws::CloudFormation::Client.new client_options(options)
    end

    def client_options(options)
      client_options = {}
      client_options[:credentials] = Aws::SharedCredentials.new({:profile_name => options[:profile_name]}) if options.has_key? :profile_name
      client_options[:region] = options[:region] if options.has_key? :region
      client_options
    end
  end
end