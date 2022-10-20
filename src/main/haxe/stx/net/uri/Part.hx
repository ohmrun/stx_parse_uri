package stx.net.uri;

enum Part {
  Simple(p:Path );
  Query(p:Path, v: AddressNode);
  Opaque(s:String);
}