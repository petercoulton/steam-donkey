require 'aws-sdk'
require 'to_regexp'

filters=[]
fields=["Name", "PublicIpAddress", "InstanceType", "State"]

if ARGV.length > 0
  filters = ARGV[0].split(",") unless ARGV[0] == "-"
  fields  = ARGV[1].split(",") unless ARGV[1].nil? or ARGV[1].empty?
end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

def from_tags key, instance
  key = key.downcase
  tag = instance.tags.find { |tag| tag.key.downcase == key }
  if tag != nil
    tag[:value]
  else
    nil
  end
end

def name_from_tags instance
  from_tags 'Name', instance
end

def columns names, instance
  {}.tap do |result|
    names.each do |name|
      if name =~ /^Name$|^Tags\./
        tag = name.split(".").last
        result[name] = from_tags(tag, instance)
        next
      end

      if name =~ /^State$|State.Name/
        result[name] = instance.state.name
        next
      end

      if name =~ /^State\.Code$/
        result[name] = instance.state.code
        next
      end

      result[name] = instance.send(name.underscore) 
    end    
  end
end

def field_names fields
  fields.map do |field|
    if field =~ /.+=.+/
      field.split("=").first
    else
      field
    end
  end
end

def field_filters fields
  {}.tap do |filters|
    fields.each do |field|
      if field =~ /.+=.+/
        name, value = field.split("=")
        filters[name] = value
      end
    end
  end
end

search_options={}

puts (fields.map do |field|
  if field.include? "="
    field.split("=").first
  else
    field
  end
end.join(","))

ec2 = Aws::EC2::Client.new
ec2.describe_instances(search_options).each do |response|
  response.reservations.each do |reservation|
    reservation.instances.each do |instance|
      values = columns(fields, instance)

      skip = false
      field_filters(filters).each do |name, value|
        actual_value = values[name] || ""
        expected_value = value

        if expected_value =~ /^\?.+/
          expected_value_regexp = expected_value[1..-1].to_regexp
          if !(actual_value =~ expected_value_regexp)
            skip = true
          end
          next
        end

        if expected_value =~ /^!.+/
          expected_value_regexp = expected_value[1..-1].to_regexp
          if actual_value =~ expected_value_regexp
            skip = true
          end
          next
        end

        if expected_value.downcase != actual_value.downcase
          skip = true
        end
      end

      next if skip

      puts (values.values.map do |v| 
        if v.nil? || (v.instance_of?(String) && v.empty?)
          "-" 
        else 
          if v.instance_of?(Time)
            v.iso8601
          else
            v 
          end
        end 
      end.join(","))
    end
  end
end
