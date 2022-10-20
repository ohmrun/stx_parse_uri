package stx.net.uri;

enum Uri {
  Absolute(scheme:String, p:Part);
  Relative(p:Path, xs:Option<AddressNode>);
}