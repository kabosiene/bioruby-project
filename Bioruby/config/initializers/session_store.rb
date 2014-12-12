# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bioruby_rails_session',
  :secret      => '89114d7ef0f326de5fb1b3742da011bcb83a21cc7f36d9f4c1f60f2aa7966ec4bd92afb4d2dc9205d251ab24a586fd4d3f1959502b5300968d59713461eb33a1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
