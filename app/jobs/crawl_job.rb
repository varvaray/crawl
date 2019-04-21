class CrawlJob
  include Sidekiq::Worker
  include SidekiqStatus::Worker

  require 'grell'
  require 'wombat'

  def perform(q, url, depth)
    original_link_count = url.to_s.split('/').length
    puts "\n\n\n"
    ap q
    ap url
    ap 'original_link_count = '+original_link_count.to_s
    ap depth
    # add_match_block = Proc.new do |collection_page, page|
    #   puts "\n\n\n**********************\n"
    #   ap 'collection_page.path = ' + collection_page.path
    #   ap 'page.path = ' + page.path
    #   ap '-------------'
    #   return false if page.path.to_s.split('/').length > depth
    #   collection_page.path == page.path
    # end
    # add_match_block: add_match_block
    crawler = Grell::Crawler.new(blacklist: /^.*\.(jpg|JPG|gif|GIF|doc|DOC|pdf|PDF)$/)
    results = []
    begin
      crawler.start_crawling(url) do |page|
        #Grell will keep iterating this block which each unique page it finds
        puts "\n\n\n----------------\nyes we crawled #{page.url}"
        ap 'url length = '+page.url.to_s.split('/').length.to_s
        puts "status: #{page.status}"
        puts "headers: #{page.headers}"
        puts "body has text: #{page.body.to_s.include?(q)}"
        puts "We crawled it at #{page.timestamp}"
        puts "We found #{page.links.size} links"
        puts "page id and parent_id #{page.id}, #{page.parent_id}"
        next if page.headers[:grellStatus] && page.headers[:grellStatus] == 'Error'
        content_type_check = !page.headers["Content-Type"].include?('text/html')
        depth_check = page.url.to_s.split('/').length > original_link_count + depth
        page_status_check = [500, 404].include?(page.status)
        side_url_check = !page.url.to_s.include?(url)
        content_check = !page.body.to_s.include?(q)
        ap 'content_type_check = ' + content_type_check.to_s
        ap 'depth_check = ' + depth_check.to_s
        ap 'page_status_check = ' + page_status_check.to_s
        ap 'side_url_check = ' + side_url_check.to_s
        ap 'content_check = ' + content_check.to_s
        next if content_type_check || depth_check || page_status_check || side_url_check || content_check
        ap 'PASS CHECKS'
        results <<
          begin
            Wombat.scrape do
              base_url page.url
              path "/"

              url page.url
              title "xpath=//title[contains(text(), #{q})]"
              text "xpath=//*[contains(text(), '#{q}')]"
            end
          rescue Mechanize::ResponseCodeError => e
            puts 'failed page ' + page.url.to_s + ' - ' + e.response_code
          end
      end
    rescue Capybara::Poltergeist::TimeoutError => e
      puts 'failed page ' + page.url.to_s + ' - '
      ap e
    end
    ap 'results = '
    ap results

    self.payload = results
  end
end