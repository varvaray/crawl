class Base < Grape::API

  logger Logger.new(Rails.root.join("log/crawl_api.log"))
  insert_after Grape::Middleware::Formatter, Grape::Middleware::Logger, logger: logger

  format :json

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    logger.warn e.message
    error!({ with: Entities::Errors::BadRequest, details: e.message }, 400)
  end

  rescue_from :all do |e|
    ap e
    logger.error e
    error!({ with: Entities::Errors::Server, details: e.message }, 500)
  end

  helpers do
    def logger
      Base.logger
    end

    # def permitted_params
    #   @permitted_params ||= declared(params, include_missing: false)
    # end
  end

  mount Crawl

  route :any, '*path' do
    error!({ with: Entities::Errors::NotFound }, 404)
  end
end