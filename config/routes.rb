Rails.application.routes.draw do
  mount CrawlAPI => '/'
  mount ResultAPI => '/'
end
