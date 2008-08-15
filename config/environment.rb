require 'rubygems'

CHIZZLE_ENV = ENV['CHIZZLE_ENV'] || 'development'
CHIZZLE_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.unshift "#{CHIZZLE_ROOT}/lib"

require "#{CHIZZLE_ROOT}/config/environments/#{CHIZZLE_ENV}"