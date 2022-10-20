package stx.net.uri;

enum Host {
  IP4(s:String, port:Option<Int>);
  Named(s:String, port:Option<Int>);
}