module Juggernaut # :nodoc:
  module JuggernautHelper

    def listen_to_juggernaut_channels(channels = nil, unique_id = "null")
      host = Juggernaut::CONFIG["PUSH_HELPER_HOST"]
      port = Juggernaut::CONFIG["PUSH_PORT"]
      num_tries = Juggernaut::CONFIG["NUM_TRIES"]
      num_secs = Juggernaut::CONFIG["NUM_SECS"]
      base64 = Juggernaut::CONFIG["BASE64"] ? true : false
      channels = Array(channels || Juggernaut::CONFIG["DEFAULT_CHANNELS"])
      channels = channels.map { |c| CGI.escape(c.to_s) }.to_json
      content = content_tag :div, '', :id=>'flashcontent'
      content += javascript_tag %{Juggernaut.debug = true;} if Juggernaut::CONFIG["LOG_ALERT"] == 1
      content += javascript_tag %{Juggernaut.listenToChannels({ host: '#{host}', num_tries: #{num_tries}, ses_id: '#{session.session_id}', num_secs: #{num_secs}, unique_id: '#{unique_id}', base64: #{base64}, port: #{port}, channels: #{channels}});}
      content
    end
    
  end
end
