package stx.net.uri;

using stx.Log;
using stx.Test;

import stx.net.uri.test.*;

class Test{
  static public function tests(){
    return [
      new UriTest()
    ];
  }
  static public function main(){
    final log = __.log().global;
    __.test().auto();
  }
}