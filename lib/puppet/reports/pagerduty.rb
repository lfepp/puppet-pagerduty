require 'puppet'
require 'json'
require 'yaml'

begin
  require 'redphone/pagerduty'
rescue LoadError => e
  Puppet.info "You need the `redphone` gem to use the PagerDuty report"
end

Puppet::Reports.register_report(:pagerduty) do

  config_file = File.join(File.dirname(Puppet.settings[:config]), "pagerduty.yaml")
  raise(Puppet::ParseError, "PagerDuty report config file #{config_file} not readable") unless File.exist?(config_file)
  config = YAML.load_file(config_file)
  PAGERDUTY_API = config[:pagerduty_api]
  IGNORE_ENVS = [*config[:ignore_envs]]
  CACHE_DIR = File.join(Puppet.settings[:vardir], 'pagerduty-report-cache')
  if not File.directory?(CACHE_DIR)
    Dir.mkdir(CACHE_DIR)
  end

  desc <<-DESC
  Send notification of failed reports to a PagerDuty service. You will need to create a receiving service
  in PagerDuty that uses the Generic API and add the API key to configuration file.
  DESC

  def process
    if ! IGNORE_ENVS.empty? && IGNORE_ENVS.include?(self.environment)
      Puppet.debug "Ignoring report from #{self.host} environment #{self.environment}"
      return
    end
    cache_file = "#{CACHE_DIR}/#{self.host}"
    if self.status == "failed"
      Puppet.debug "Sending status for #{self.host} to PagerDuty."
      err_events = Hash[*self.logs.select { |line| line.level == 'err' }.sort_by { |line| line.time }.map {|line| [line.time, line]}.flatten]
      response = Redphone::Pagerduty.trigger_incident(
        :service_key => PAGERDUTY_API,
        :incident_key => "puppet/#{self.host}",
        :description => "#{self.environment.upcase} Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}",
        :details => err_events
      )
      case response['status']
      when "success"
        Puppet.debug "Created PagerDuty incident: puppet/#{self.host}"
        cache_file = File.open(cache_file, "w")
        cache_file.write("Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}\n")
      else
        Puppet.warning "Failed to create PagerDuty incident: puppet/#{self.host}"
      end
    else # status == changed/unchanged
      if File.file?(cache_file)
        response = Redphone::Pagerduty.resolve_incident(
          :service_key => PAGERDUTY_API,
          :incident_key => "puppet/#{self.host}"
        )
        case response["status"]
        when "success"
          Puppet.debug "Closed PagerDuty incident: puppet/#{self.host}"
          File.delete(cache_file)
        else
          Puppet.warning "Failed to close PagerDuty incident: puppet/#{self.host}"
        end
      end
    end
  end
end
