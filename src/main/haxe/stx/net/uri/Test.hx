package stx.net.uri;

using stx.Log;
using stx.Test;

import stx.net.uri.test.*;

class Test{
  static public function tests(){
    return [
      new UriTest(),
      new IrisTest(),
      new IPV6Test()
    ];
  }
  static public function main(){
    final log = __.log().global;
          log.includes.push("stx/parse");
          log.level = TRACE;
    __.test().auto();
  }
}