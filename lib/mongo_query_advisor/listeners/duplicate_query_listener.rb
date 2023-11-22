require 'singleton'

class DuplicateQueryListener
  include Singleton

  def initialize
    @queries = Hash.new { |hash, key| hash[key] = { count: 0, max_limit: nil } }
  end

  def started(event)
    
  end

  def succeeded(event)
    puts "Succeeded: #{event.command_name} in #{event.database_name}"
    return if event.command_name != 'find'

    query = event.started_event.command
    key = query_hash_key(query)
    
    if @queries.key?(key)
      if is_subset_of?(query, @queries[key]) 
        puts "Duplicate query found: #{query.to_json}. Consider enabling Mongo Query Cache."
      else
        @queries[key][:max_limit] == query['limit']
      end
    else
      @queries[key] = { count: 1, max_limit: query['limit'] }
    end
  end

  def failed(event)
    puts "Failed: #{event.command_name} in #{event.database_name}"
  end

  private

  def query_hash_key(query)
    [query['find'], query['filter'], query['skip'], query['sort']].hash
  end

  def is_subset_of?(new_query, old_query_info)
    new_limit = new_query['limit']
    old_limit = old_query_info[:max_limit]
    return new_limit == old_limit || (!new_limit && !old_limit) || (new_limit && old_limit && new_limit < old_limit)
  end
end