Rails.application.routes.draw do

  post "repositories/:rid/resources/:id/pdf_uni"  => 'pdf_uni#resource'

end