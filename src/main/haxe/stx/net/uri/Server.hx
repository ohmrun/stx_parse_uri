package stx.net.uri;

enum Server {
  Authenticated(info:String, Host:Host);
  Simple(host:Host);
}