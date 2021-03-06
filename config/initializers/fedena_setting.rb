FEDENA_DEFAULTS = {
  :company_name => 'Preston International College',
  :company_url  => 'http://www.prestonchennai.ac.in'
}

USER_SETTINGS = {}

if File.exists?("#{Rails.root}/config/company_details.yml")
  company_settings = YAML.load_file(File.join(Rails.root,"config","company_details.yml"))
  USER_SETTINGS = {:company_name => company_settings['company_details']['company_name'],
                   :company_url  => company_settings['company_details']['company_url']
  }
end

FEDENA_SETTINGS = FEDENA_DEFAULTS.merge!(USER_SETTINGS)

 