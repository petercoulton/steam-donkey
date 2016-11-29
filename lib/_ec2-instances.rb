require 'aws-sdk'

fields=["Tags.Name", "PublicIpAddress", "InstanceType", "State"]

if ARGV.length > 0
  fields=ARGV[0].split(",") unless ARGV[0].empty?
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
  tag = instance.tags.find { |tag| tag.key.downcase == key.downcase }
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
  names.map do |name|
    if name =~ /^Name$|^Tags\./
      tag = name.split(".").last
      next from_tags tag, instance
    end

    if name =~ /^State$|State.Name/
      next instance.state.name
    end

    if name =~ /^State\.Code$/
      next instance.state.code
    end

    instance.send(name.underscore)
  end
end

search_options={}

ec2 = Aws::EC2::Client.new
ec2.describe_instances(search_options).each do |response|
  response.reservations.each do |reservation|
    reservation.instances.each do |instance|
      puts columns(fields, instance).join(",")
    end
  end
end
