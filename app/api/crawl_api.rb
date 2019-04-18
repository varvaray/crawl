class CrawlAPI < Base

  helpers do
    def set_response(job_id)
      { jobId: job_id }.to_json
    end
  end

  params do
    requires :q, type: String, desc: 'The keyword or phrase to search for'
    requires :url, type: String, desc: 'The URL at which to start crawling'
    requires :depth, type: Integer, desc: 'The maximum depth of the crawl'
  end
  desc 'Starts a job to crawl a website looking for a specific search term.'
  get '/search' do
    jid = CrawlJob.perform_async(params[:q], params[:url], params[:depth])
    set_response(jid)
  end


end

