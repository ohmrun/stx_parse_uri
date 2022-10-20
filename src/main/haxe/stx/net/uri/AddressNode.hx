package stx.net.uri;

enum AddressNode {
  Param(v:String);
  Segment(head:AddressNode,tail:PathSegs);
  Fragment(v:String);
  Query(v:String);
  Segments(v:Array<AddressNode>);
}