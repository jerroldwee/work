OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK['client_id'], FACEBOOK['client_secret'], scope: FACEBOOK['scope']
end
