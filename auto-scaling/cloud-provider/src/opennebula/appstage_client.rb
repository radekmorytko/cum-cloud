require 'rubygems'
require 'logger'
require 'json'
require 'net/ssh'
require 'nokogiri'

module AutoScaling
  class AppstageClient

    @@logger = Logger.new(STDOUT)

    def initialize(options)
      @options = options
    end

    def instantiate_container(appstage_id, template_id)
      Net::SSH.start( host, @options[:username], :password => @options[:password] ) do|ssh|
        output = ssh.exec!("appstage instantiate -t #{template_id} #{appstage_id}")
        # output is in a format: "VM ID: 168"
        id = output.split(' ')[2]

        @@logger.debug("Instantiated vm: #{id} with appstage_id #{appstage_id} and tempalte #{template_id}")

        # get ip address here
        ip = ''

        {:id => id.to_i, :ip => ip}
      end
    end

    def delete_container(instance_id)
      Net::SSH.start( host, @options[:username], :password => @options[:password] ) do|ssh|
        output = ssh.exec!("onevm delete #{instance_id}")
        @@logger.debug("Deleted vm: #{instance_id}")
      end
    end

    private
    def host
      @options[:server].split(':')[0]
    end

    def extract_ip(xml)
      doc = Nokogiri::XML(xml)
      cdata = doc.xpath("//IP").children[0]

      if cdata == nil
        nil
      else
        cdata.content
      end
    end

  end
end