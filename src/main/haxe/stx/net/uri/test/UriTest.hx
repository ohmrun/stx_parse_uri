package stx.net.uri.test;

using stx.Parse;

import stx.parse.parser.term.Uri;

class UriTest extends TestCase{
  /**
    TODO number ranges
  **/
  public function test_ipv4(){
    final ipt = '255.255.255.255'.reader();
    final p = Uri.IPv4address();
    final o = p.apply(ipt);
    for(v in o.toRes()){
      trace(v);
    }
  }
} 