class CrawlJob
  include Sidekiq::Worker
  include SidekiqStatus::Worker

  require 'simplecrawler'

  def perform(q, url, depth)
    sc = SimpleCrawler::Crawler.new(url)
    sc.skip_patterns = ["\\.doc$", "\\.pdf$", "\\.xls$", "\\.pdf$", "\\.zip$"]
    sc.maxcount = 100

    results = []
    begin sc.crawl { |document|
      next if document.uri.to_s.split('/').length > depth + 1
      if document.http_status[0] == "200"
        hdoc = Hpricot(document.data)
        body = hdoc.search("body").inner_html
        results << { url: document.uri.to_s } if body.include?(q)
      end
      self.payload = results
    }
    rescue RuntimeError => e
      logger.error e
    end
  end
end