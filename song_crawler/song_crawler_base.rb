module SongCrawlerBase
  ERROR_UNKNOWN = 0
  ERROR_INVALID_PARAMS = 1
  ERROR_UNKNOWN_HOST = 2
  ERROR_UNKNOWN_SITE = 3
  ERROR_NO_WORK = 4
  ERROR_INVALID_WORKER = 5
  ERROR_CANT_RENEW = 6
  
  def cdata(s)
    "<![CDATA[#{s}]]>"
  end
end

