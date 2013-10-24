module Cache
  mattr_accessor :redis

  class << self
    def get(key)
      Cache.redis.get(key)
    end

    def set(key, value, ttl=nil)
      if ttl
        Cache.redis.setex(key, ttl, value)
      else
        Cache.redis.set(key, value)
      end
    end

    def fetch(key)
      value = get(key)
      value = yield if block_given? && value.nil?
      value
    end

    def expire(key)
      Cache.redis.expire(key)
    end

    def establish_connection(info)
      Cache.redis.client.disconnect if Cache.redis
      Cache.redis = Redis.new(info)
    end
  end
end
