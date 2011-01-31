module ServiceUtils
  def response_to_hash(response)
    parts = response.split("&")
    hash = {}
    parts.each do |p| (k,v) = p.split("=")
        hash[k]=CGI.unescape(v)
    end
    hash
  end

  def get_from_cache(cache, cache_key)
    begin
      cache.get(cache_key)
    rescue
      nil
    end
  end
end