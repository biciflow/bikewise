require 'spec_helper'

describe 'Locations API V2' do
  
  describe "root" do 
    it "renders with one" do
      incident = Incident.create(latitude: 32.7348953, longitude: -117.0970596)
      # target = '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"id":' + incident.id.to_s + ',"type":"Unconfirmed"},"geometry":{"type":"Point","coordinates":[-117.0970596,32.7348953]}}]}'
      get '/api/v2/locations'
      response.code.should == '200'
      result = JSON.parse(response.body)
      expect(result['type']).to eq('FeatureCollection')
      expect(result['features'][0].keys).to eq(["type", "properties", "geometry"])
    end
  end

  describe "markers" do 
    it "renders with one" do
      hash = JSON.parse(File.read(File.join(Rails.root,'/spec/fixtures/stolen_binx_api_response.json')))
      binx_report = BinxReport.find_or_new_from_external_api(hash)
      binx_report.process_hash
      binx_report.save
      incident = binx_report.create_or_update_incident
      SaverWorker.new.perform(incident.id)
      incident = Incident.create(latitude: 32.7348953, longitude: -117.0970596)      
      get '/api/v2/locations/markers?query=comp'
      result = JSON.parse(response.body)
      pp result
      expect(result['type']).to eq('FeatureCollection')
      expect(result['features'][0]['properties']['marker-color']).to eq("#E74C3C")
      response.code.should == '200'
    end
  end
end