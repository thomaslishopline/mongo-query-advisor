# frozen_string_literal: true

require_relative "mongo_query_advisor/version"
require_relative "mongo_query_advisor/listeners/duplicate_query_listener"

module MongoQueryAdvisor
  class Error < StandardError; end
  class << self
    attr_accessor :enable_all, :enable_duplicate_query

    def enable_duplicate_query=(value)
      @enable_duplicate_query = value
      enable_duplicate_query_listener if value
    end
  end

  def self.enable_duplicate_query_listener
    ::Mongo::Monitoring::Global.subscribe(::Mongo::Monitoring::COMMAND, DuplicateQueryListener.instance)
  end
end
