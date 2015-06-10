json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :token
  json.url organization_url(organization, format: :json)
end
