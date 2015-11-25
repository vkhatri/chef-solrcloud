def boolean_string(option)
  option ? 'true' : 'false'
end

def solr_tarball_sha256sum(version)
  sha256sum = node['solrcloud']['solr']['checksum'][version]
  fail "sha256sum is missing for solr tarball version #{version}" unless sha256sum
  sha256sum
end

def zookeeper_tarball_sha256sum(version)
  sha256sum = node['solrcloud']['zookeeper']['checksum'][version]
  fail "sha256sum is missing for zookeeper tarball version #{version}" unless sha256sum
  sha256sum
end
