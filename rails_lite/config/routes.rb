RailsLite::Router.new.draw do
  #convert to -get '/cats', 'cats#index'-
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
end
