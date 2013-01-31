EolRegistryRails::Application.routes.draw do

  # TODO: there is no index page yet, so may as well throw a 404
  root :to => 'errors#error_404'

  resource :push_requests do
    collection do
      get 'make_push'
      get 'query'
    end
  end

  resource :pull_requests do
    collection do
      get 'pull'
      get 'report'
    end
  end

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end

end
