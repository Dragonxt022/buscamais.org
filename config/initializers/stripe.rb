Rails.configuration.to_prepare do
  Stripe.api_key = SiteSetting["stripe_secret_key"].presence || ENV["STRIPE_SECRET_KEY"]
end
