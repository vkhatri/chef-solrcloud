describe_recipe 'solrcloud::jetty' do
  it "creates solr sysv init file" do
  file("/etc/init.d/solr").must_exist
  end
end
