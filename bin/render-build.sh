#!/usr/bin/env bash
set -o errexit

bundle binstubs bundler --force
bundle config set without 'development test'
bundle install
bundle exec rails assets:precompile
bundle exec rails db:prepare
bundle exec rails db:seed