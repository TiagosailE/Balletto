json.extract! evento, :id, :EVE_NOME, :EVE_DATA, :EVE_LOCAL, :EVE_DESC, :created_at, :updated_at
json.url evento_url(evento, format: :json)
