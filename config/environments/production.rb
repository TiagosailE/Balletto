require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings.
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}"
  }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL.
  config.force_ssl = true

  # Log to STDOUT with request id.
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  ###########################################
  # 🔥 DESATIVANDO SOLID CACHE (não funciona no Render)
  ###########################################
  # config.cache_store = :solid_cache_store
  config.cache_store = :memory_store

  ###########################################
  # 🔥 DESATIVANDO SOLID QUEUE (evita necessidade do banco queue)
  ###########################################
  # config.active_job.queue_adapter = :solid_queue
  # config.solid_queue.connects_to = { database: { writing: :queue } }
  config.active_job.queue_adapter = :async

  ###########################################
  # 🔥 DESATIVANDO SOLID CABLE (evita erro do banco cable)
  ###########################################
  config.action_cable.mount_path = nil
  config.action_cable.url = nil
  config.action_cable.allowed_request_origins = []
  config.solid_cable.enabled = false
  ###########################################

  # Email URL configuration (Render)
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_DOMAIN", "balletto.onrender.com"),
    protocol: "https"
  }

  # Enable locale fallbacks for I18n.
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]
end
