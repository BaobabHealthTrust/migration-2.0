# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_migrator2.0_session',
  :secret      => 'c4080a9a7400765731e2fc0493bf357630e3ffddfe988c348174f42be8b83cb03f7791e31448c368fa433b4d57c69a4e9faaa23a6c1d3239f11769bd6d2033ee'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
