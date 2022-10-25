(indeces "stx.net.uri.Test")
(
  "main" include "stx.net.uri.test.UriTest"
)
(
  "iris" include ("stx.net.uri.test.IrisTest")
)
(
  "ipv6" include (
    ("stx.net.uri.test.IPV6Test" include "test")
  )
)