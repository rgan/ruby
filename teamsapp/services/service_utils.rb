module ServiceUtils
  def response_to_hash(response)
    parts = response.split("&")
    hash = {}
    parts.each do |p| (k,v) = p.split("=")
        hash[k]=CGI.unescape(v)
    end
    hash
  end
end