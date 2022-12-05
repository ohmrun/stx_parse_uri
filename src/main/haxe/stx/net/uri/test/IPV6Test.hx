package stx.net.uri.test;

import stx.parse.parser.term.Uri;

using stx.Parse;

class IPV6Test extends TestCase{
  var value : Array<String>;

  override public function __setup():Option<Async>{
    final  a = __.resource("ipv6").string();
    final  b = a.split("\n").ldropn(2);
    value = b;
    return None;
  } 
  public function test(){
    var count = 0;
    for(x in value){
      count++;
      //trace(count);
      //trace(x);
      if(count<1000){
        try{
          final res = Uri.IPv6Address.apply(x.reader());
          if(res.is_ok()){
            trace('ok $x at $count');
          }else{
            trace('failed $count');
            trace(res.error);
          }
        }catch(e:haxe.Exception){
          trace('ERROR $x at $count');
          trace(e);
          //trace(e.details());
        }
      }
    }   
  }
  public function test_h16(){
    trace(value[1]);
    var v = value[1].reader();
    trace(v);
    var x = Uri.h16.apply(v);
    trace(x);
  }
  public function test_full(){
    final v = "2001:569:7e0e:6f00:cd4a:d90f:d5ea:f9e5".reader();
    final p = Uri.IPv6Address.apply(v);
    trace(v);
  }
  public function test_null_error(){
    final v = "2001:678:be4:8::29".reader();
    final p = Uri.IPv6Address.apply(v);
    trace(v);
  }
}