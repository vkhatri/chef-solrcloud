require 'serverspec'

set :backend, :exec

describe 'Working SOLR node' do
  it 'is listening on port 8983' do
    expect(port(8983)).to be_listening
  end

  it 'has a running solr service' do
    expect(service('solr')).to be_running
  end
end
