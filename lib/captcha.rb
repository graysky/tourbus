# Simple CAPTCHA to prevent spammers
module Captcha
  
  # Simple key, passphrase pairs
  CAPTHCA_PHRASES = {
    "1" => "tunez", 
    "2" => "rock",
    "3" => "drummer",
    "4" => "guitar",
    "5" => "backstage"
  } unless const_defined?("CAPTHCA_PHRASES")
  
  # Handles CAPTCHA testing
  def captcha_passed?
    return handle_captcha(params[:cap_key], params[:cap_value])
  end
  
  # Handles rules for CAPTCHA passing:
  # 1) if they are logged in
  # 2) if they have a valid captcha cookie
  # 3) if the entry matches the secret
  def handle_captcha(key, entry)

    return true if !require_captcha?

    if captcha_phrase_match?(key, entry)
      # Captcha passed, remember they are not a robot
      cookies[:tb_cap] = { :value => 'norobot', :expires => Time.now + 5.days }
      return true
    end
    
    # Default to returning false
    return false    
  end
  
  # Validates if the captcha response was valid
  def captcha_phrase_match?(key, entry)
    return false if !CAPTHCA_PHRASES.has_key?(key)
  
    secret = CAPTHCA_PHRASES[key]
    return secret.eql?(entry)
  end
  
  # Return array of [key, value] for the random captcha
  def pick_captcha
    i = rand(CAPTHCA_PHRASES.keys.length)
    k = CAPTHCA_PHRASES.keys[i]
    v = CAPTHCA_PHRASES.fetch(k)
    return [k, v]
  end
  
end