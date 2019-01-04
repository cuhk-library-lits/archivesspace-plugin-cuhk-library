class CuhkLibRequestsController < ApplicationController

  def make_request
    @request = CuhkLibRequestItem.new(params)

    errs = []

    if AppConfig.has_key?(:enable_recaptcha) && AppConfig[:enable_recaptcha]
      if !GoogleRecaptcha.verify?(AppConfig[:recaptcha_secret_key], request[:g_recaptcha_response], AppConfig[:request_form_action])
        errs << I18n.t('request.recaptcha_failed').html_safe
      end
    end

    if errs.blank?
      errs.concat @request.validate
      if params["comment"].present?
        errs << I18n.t('request.failed').html_safe
      end
    end

    if errs.blank?
      flash[:notice] = I18n.t('request.submitted')

      CuhkLibRequestMailer.request_received_staff_email(@request).deliver
      CuhkLibRequestMailer.request_received_email(@request).deliver

      redirect_to params.fetch('base_url', (AppConfig[:public_proxy_url].sub(/\/^/, '') + request[:request_uri]))
    else
      flash[:error] = errs
      redirect_back(fallback_location: (AppConfig[:public_proxy_url].sub(/\/^/, '') + request[:request_uri])) and return
    end
  end

end
