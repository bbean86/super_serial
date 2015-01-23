class DataStruct < OpenStruct
  def to_json
    json = super
    JSON.parse(json)['table'].to_json
  end
end