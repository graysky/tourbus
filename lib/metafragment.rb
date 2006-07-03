# Time-based fragment caching. Like all Rails caching, it is only enabled in production mode.
#
# Influenced from Typo time-based fragment caching:
# http://www.typosphere.org/trac/browser/trunk/vendor/plugins/expiring_action_cache/lib/metafragment.rb
# 
# Looking at their tests was helpful for usage:
# http://www.typosphere.org/trac/browser/trunk/test/unit/metafragment_test.rb
#
# Based on this:
# http://scottstuff.net/blog/articles/2006/01/20/time-limited-caching-for-rails
#
module MetaFragment
  
  # Get a valid cache key part string from the given strings
  def self.cache_key_part(*chunks)
    part = chunks.join('')
    part.gsub(/[^a-z0-9]/i, '')
  end
  
  # Helper to make the idiom simpler for caching fragments.
  # key => The key for the fragment to check/cache
  # time_to_live => Time that the cached fragment will expire
  # block => To execute when the cached fragment is not valid
  def when_not_cached(key, time_to_live)
    
    # Check if the cache is valid, otherwise execute their
    # block and write the timed meta-key
    unless read_timed_fragment(key)
      yield
      write_timed_fragment(key, time_to_live)
    end    
  end
  
  # Read and return the fragment identified by name, and return it iff:
  # 1) it exists in the cache
  # 2) it has not expired
  # Otherwise, return nil
  def read_timed_fragment(key)
    meta = read_meta_fragment(key)
    
    # Check if the content has expired
    if(meta.kind_of? Hash and meta[:expires].kind_of? Time and meta[:expires] < Time.now)
      # It has expired - clean up the cache
      expire_fragment(key)
      expire_fragment(meta_fragment_key(key))
      return nil
    else
      # Still valid, hit the cached copy
      return read_fragment(key)
    end
  end
  
  # Write a metafragment to remember how long to keep the cached content
  # Set it to expire at the specified time, defaults to 30 seconds
  def write_timed_fragment(key, time = 30.seconds.from_now)
    meta = {:expires => time}
    metakey = meta_fragment_key(key)
    
    content = write_fragment(metakey, YAML.dump(meta))
  end
  
  # Read the meta fragment
  def read_meta_fragment(contentkey)
    metakey = meta_fragment_key(contentkey)
    meta = YAML.load(read_fragment(metakey)) rescue {}
    return meta
  end
  
  # Form a key for the metadata from the given content key
  # Assumes there is a ":part" key if it is a Hash
  def meta_fragment_key(key)
    
    # If it is a has
    if key.kind_of? Hash and key[:part].kind_of? String
      part = key[:part]
      metakey = key.dup
      metakey[:part] = "meta_#{part}"
      return metakey
    elsif key.kind_of? String
      return "meta_#{key}"
    else
      return nil
    end
  end
  
end