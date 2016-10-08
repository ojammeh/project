# Be sure to restart your server when you modify this file.

#AUP::Application.config.session_store :cookie_store, key: '_AUP_session'

AUP::Application.config.session_store :active_record_store, {
  expire_after: 30.minutes
}
