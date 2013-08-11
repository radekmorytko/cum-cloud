require 'rubygems'
require 'logger'
require 'json'
require 'net/ssh'
require 'nokogiri'
require 'uri'
require 'digest/md5'

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

    def create_template(definition)
      Net::SSH.start( host, @options['username'], :password => @options['password'] ) do |ssh|
        tmp_file = File.join("/tmp", Digest::MD5.hexdigest(definition))
        ssh.exec!("echo '#{definition}' > #{tmp_file}")
        output = ssh.exec!("appstage create #{tmp_file}")
        id = output.split(' ')[1]

        @@logger.debug("Created definition (id: #{id}): #{definition} using file #{tmp_file}")

        id
      end
    end

    private
    def host
      URI(@options['endpoints']['opennebula']).host
    end

    def delete_template(template_id)
      Net::SSH.start( host, @options['username'], :password => @options['password'] ) do |ssh|
        output = ssh.exec!("appstage delete #{template_id}")
        @@logger.debug("Deleted template #{template_id}")
        output
      end
    end

  end
end