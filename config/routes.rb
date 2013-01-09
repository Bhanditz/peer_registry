EolRegistryRails::Application.routes.draw do
  get "pull_requests/pull"

  get "push_requests/make_push"

  get "push_requests/query"
  
end
