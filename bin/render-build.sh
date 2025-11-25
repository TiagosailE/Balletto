#!/usr/bin/env bash
set -o errexit

bundle config set without 'development test'
bundle exec rails assets:precompile
bundle exec rails db:prepare
bundle exec rails db:seed