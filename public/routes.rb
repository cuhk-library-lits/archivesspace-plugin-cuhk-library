Rails.application.routes.draw do
  scope AppConfig[:public_proxy_prefix] do
    match('/repositories/:rid/resources/:id/pdf_uni' => 'pdf_uni#resource', :via => [:post])
  end
end
