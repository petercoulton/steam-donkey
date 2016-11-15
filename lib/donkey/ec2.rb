require 'aws-sdk'
require_relative 'output'

module Donkey
  class EC2

    def ssh(options = {})
      exec "ssh -i ~/.ssh/amplience/dev/dev fedora@54.229.206.251"
    end

    def list(options = {})
      options[:output] ||= :table

      output = Donkey::Output::Printer.new(options)
      output.add_header 'Name'
      output.add_header 'Public IP'
      output.add_header 'Status'
      output.add_header 'Key Name'

      ec2 = Aws::EC2::Client.new client_options(options)
      ec2.describe_instances.each do |response|
        response.reservations.each do |reservation|
          reservation.instances.each do |instance|
            output.add_row do
              output.add_column 'Name', name_from_tags(instance)
              output.add_column 'Public IP', instance.public_ip_address
              output.add_column 'Status', instance.state.name, :color => status_color(instance.state.name)
              output.add_column 'Key Name', instance.key_name
            end
          end
        end
      end

      output.print options
    end

    private

    def client_options(options)
      client_options = {}
      client_options[:credentials] = Aws::SharedCredentials.new({:profile_name => options[:profile_name]}) if options.has_key? :profile_name
      client_options[:region] = options[:region] if options.has_key? :region
      client_options
    end

    def status_color status
      case status
        when 'pending'
          :yellow
        when 'running'
          :green
        when 'shutting-down', 'stopping'
          :orange
        when 'terminated', 'stopped'
          :red
      end
    end

    def name_from_tags instance
      name_tag = instance.tags.find { |tag| tag.key == 'Name' }
      if name_tag != nil
        name_tag[:value]
      else
        nil
      end
    end
  end
end