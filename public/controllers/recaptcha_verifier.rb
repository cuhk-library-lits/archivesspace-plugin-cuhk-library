require 'net/http'
require 'json'

class GoogleRecaptcha

    Recaptcha_Verify_URL = 'https://www.google.com/recaptcha/api/siteverify'
    
    def self.verify?(secret, token, action)
        result = false
       
        verify_uri = URI(Recaptcha_Verify_URL)
        response = Net::HTTP.post_form(verify_uri, 'secret' => secret, 'response' => token)
        Rails.logger.debug("reCAPTCHA response: " + response.body)
        
        resp_obj = JSON.parse(response.body)
        recaptcha_success = resp_obj["success"]
        if recaptcha_success
            recaptcha_score = resp_obj.key?("score") ? resp_obj["score"] : 0
            recaptcha_action = resp_obj.key?("action") ? resp_obj["action"] : ""
            expected_action = action.nil? ? "" : action

            if recaptcha_score >= AppConfig[:recaptcha_score_threshold] && recaptcha_action == expected_action
                result = true
            end
        else
            Rails.logger.error("reCAPTCHA failed: " + resp_obj["error-codes"])
        end
        
        result
    end

end