# Be sure to restart your server when you modify this file.

#Lending::Application.config.session_store :cookie_store, key: '_lending_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Lending::Application.config.session_store :active_record_store, :key => '_lending'
#Lending::Application.config.session_store :redis_store, servers: 'redis://localhost:6379/0/cache'
