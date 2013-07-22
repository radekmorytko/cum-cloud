require 'rubygems'
require 'logger'
require 'json'
require 'net/ssh'
require 'nokogiri'

module AutoScaling
  class AppstageClient

    @@logger = Logger.new(STDOUT)

    CLIENT = {
        :retries => 3,
        :sleep => 2
    }

    def initialize(options)
      @options = options
    end

    def instantiate_container(appstage_id, template_id)
      Net::SSH.start( host, @options[:username], :password => @options[:password] ) do|ssh|
        output = ssh.exec!("appstage instantiate -t #{template_id} #{appstage_id}")
        # output is in a format: "VM ID: 168"
        id = output.split(' ')[2]

        @@logger.debug("Instantiated vm: #{id} with appstage_id #{appstage_id} and template #{template_id}")

        # get ip address
        retry_count = 0
        ip = ''
        begin
          if ip == nil
            @@logger.debug "Waiting for scheduling vm to get an ip address"
            sleep CLIENT[:sleep]
          end

          xml = ssh.exec!("onevm show #{id} --xml")
          ip = extract_ip xml
          retry_count += 1
        end while retry_count <= CLIENT[:retries] and ip != nil

        raise RuntimeError, "Can't get container ip" if ip == nil
        @@logger.debug "VM #{id} has an address: #{ip}"

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