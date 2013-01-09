EolRegistryRails::Application.routes.draw do
  resource :push_requests do
    collection do
      get 'make_push'
      get 'query'
    end
  end
  
  resource :pull_requests do
    collection do
      get 'pull'
    end
  end
end
