# Content Security Policy (Level 2 - configured) is a computer security standard introduced to prevent
# cross-site scripting (XSS), clickjacking and other code injection attacks resulting from execution
# of malicious content in the trusted web page context.
#
# Ref:
#   http://www.w3.org/TR/CSP/
#   https://developer.mozilla.org/en-US/docs/Web/Security/CSP/CSP_policy_directives
#   https://developer.mozilla.org/en-US/docs/Web/Security/Public_Key_Pinning
#   https://tools.ietf.org/html/rfc7469 - Not configured

SecureHeaders::Configuration.default do |config|
  config.x_frame_options = 'SAMEORIGIN'
  config.x_content_type_options = 'nosniff'
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'

  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains; preload"

  config.x_xss_protection = '1; mode=block'
  protocol = Rails.application.secrets.secure_connection ? 'https' : 'http'

  csp = {
      default_src: %w('none'),
      img_src: %W('self'
                https://www.google-analytics.com/
                #{protocol}://assets.adobedtm.com/
                #{protocol}://wogaadev.112.2o7.net/
                #{protocol}://wogaaprod.112.2o7.net/
                #{protocol}://wogadobeanalytics.sc.omtrdc.net/
                data:),
      connect_src: %W('self' #{protocol}://dpm.demdex.net/ https://developers.onemap.sg/),
      font_src: %W('self'
                 #{protocol}://fonts.gstatic.com
                 https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/fonts/
                 data:),
      media_src: %w('self'),
      object_src: %w('self'),
      script_src: %W('self'
                   'unsafe-eval'
                   https://www.google.com/recaptcha/
                   https://www.gstatic.com/recaptcha/
                   https://www.google-analytics.com/analytics.js
                   #{protocol}://assets.adobedtm.com/
                   #{protocol}://wogaadev.112.2o7.net/
                   #{protocol}://wogaaprod.112.2o7.net/
                   #{protocol}://www.adobetag.com/
                   #{protocol}://*.demdex.net/
                   #{protocol}://*.everesttech.net/
                   ),
      style_src: %W('self'
                  'unsafe-inline'
                  #{protocol}://fonts.googleapis.com
                  https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/),
      child_src: %W('self'
                  https://fast.wistia.net/
                  https://www.google.com/recaptcha/
                  #{protocol}://www.jusfeedback.asia/Community/),
      form_action: %w('self'),
      frame_ancestors: %W('none' https://fast.wistia.net/ #{protocol}://fast.wogaa.demdex.net/)
  }

  csp_local = csp.merge(img_src: %w(http://localhost:3035/),
                        connect_src: %w(ws://localhost:3035/ http://localhost:3035/),
                        script_src: %w(http://localhost:3035/)) { |_key, o, n| (o | n) }

  if Rails.env.development? || Rails.env.CI?
    csp.each do |k, v|
      if k != :base_uri
        # webpack and browsersync
        csp[k] = v.push("'self'", '*', "'unsafe-inline'")
      end
    end
  end

  csp[:report_only] = false
  csp[:preserve_schemes] = true

  config.csp = Rails.env.development? ? csp_local : csp

  config.hpkp = {
      report_only: false,
      max_age: 60.days.to_i,
      include_subdomains: true,
      tag_report_uri: false
  }
end
