def boolean_string(option)
  option ? 'true' : 'false'
end

def solr_tarball_sha256sum(version)
  sha256sums = {
    '4.9.0' => 'c42b1251f44f8e1b826d89c362b43dec4dd9094e6a07f2f1c27e990f8c6eafdc', '4.9.1' => 'd03e9daf33df80bae4a37f88525fe19084a4502e8b38a02d7a60e2bc436076e8', '4.10.0' => '0c9c3e03b42e6afd9a2fea97a1fe2078640e97342b8b53e47df8207670661e9f',
    '4.10.1' => '3e6359f4227f17cda7dc280bc32572a514f330dada80539b0b47dba107672563', '4.10.2' => '101bc6b02ac637ac09959140a341e6b02d8409f3f84c37b36c7628c6f8739c1f', '4.10.3' => 'ac7024a0a759c6c53cc3a66b3a84757d599d350f491eb221160613356532e2b6',
    '4.10.4' => 'ac3543880f1b591bcaa962d7508b528d7b42e2b5548386197940b704629ae851', '5.0.0' => '48c77aede40fceda73cf4e13e08e328899685446f80f76f2e893eaffea714297', '5.1.0' => '8718cbfb789a170d210b0b4adbe4fd8187ecdc67c5348ed9d551578087d8a628',
    '5.2.0' => 'dff2c5df505b732e23178e8f12e817dba4a088a8afe6599dcacf9ea241f76a1e', '5.2.1' => '3f54cec862da1376857f96f4a6f2044a5addcebc4df159b8797fd71f7ba8df86', '5.3.0' => '26aec63d81239a65f182f17bbf009b1070f7db0bb83657ac2a67a08b57227f7c',
    '5.3.1' => '34ddcac071226acd6974a392af7671f687990aa1f9eb4b181d533ca6dca6f42d', '5.4.0' => '84c0f04a23047946f54618a092d4510d88d7205a756b948208de9e5afb42f7cd'
  }
  sha256sum = sha256sums[version] || node['solrcloud']['sha256sum']
  fail "sha256sum is missing for solr tarball version #{version}" unless sha256sum
  sha256sum
end

def zookeeper_tarball_sha256sum(version)
  sha256sums = {
    '3.4.6' => '01b3938547cd620dc4c93efe07c0360411f4a66962a70500b163b59014046994'
  }
  sha256sum = sha256sums[version] || node['solrcloud']['zookeeper']['sha256sum']
  fail "sha256sum is missing for zookeeper tarball version #{version}" unless sha256sum
  sha256sum
end
