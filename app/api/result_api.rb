class ResultAPI < Base

  helpers do
    def set_response(status, matches)
      response = { status: status }
      response.merge!("matches": matches) if matches.any?
      response.to_json
    end
  end

  params do
    requires :job_id, type: String, desc: 'Job id'
  end
  desc 'Gets the status of a job.  If the job is done a list of pages containing the search term is returned'
  get '/status' do
    container = SidekiqStatus::Container.load(params[:job_id])
    set_response(container.status, container.payload)
  end

end

