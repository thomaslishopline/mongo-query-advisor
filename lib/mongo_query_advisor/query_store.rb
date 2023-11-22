module QueryStore
  @queries = Hash.new { |hash, key| hash[key] = { count: 0, max_limit: nil } }

  class << self
    attr_reader :queries
  end
end