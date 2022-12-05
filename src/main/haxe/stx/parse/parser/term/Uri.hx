package stx.parse.parser.term;

using stx.parse.parser.term.Uri;

using Std;
import stx.parse.Parsers.*;
import stx.net.uri.*;

/**
 * @author 0b1kn00b
 * 
 * from  : http://www.ietf.org/rfc/rfc2396.txt
 */
 
final alts = __.parse().alts;

class Uri {
  static public function tp<Pi,Pii,R>(fn:Pi->Pii->R){
    return __.decouple(fn);
  }
  static public function ct<T>(l:T,r:T):String{
    return '$l$r';
  }
  static public function ctlo<T>(l:Option<T>,r:T):String{
    return l.map((l:T) -> '$l$r').defv('$r');
  }
  static public function ctro<T>(l:T,r:Option<T>):String{
    return r.map((r:T) -> '$l$r').defv('$l');
  }
  static public function id(str:String){
    return __.parse().id(str);
  }
  static public function oBnd(l:Null<String>,r:Null<Option<String>>){
    return __.option(l).zip(__.option(r).flat_map(x -> x)).map(__.decouple((x,y) -> '$x$y'));
  }
  static public function sBnd(l:Null<String>,r:Null<String>):Option<String>{
    return __.option(l).zip(__.option(r)).map(__.decouple((x,y) -> '$x$y'));
  }
  
  static public final ALPHA         = Parse.alpha;
  static public final DIGIT         = Parse.digit;
  static public final HEXDIG        = Regex("^[a-fA-F0-9]");

  static public final unreserved    = ALPHA.or(DIGIT).or(id("-")).or(id(".")).or(id("_")).or(id("~"));
  static public final pct_encoded   = id("#")._and(HEXDIG).and(HEXDIG).then(__.decouple((x,y) -> '$x$y'));
  static public final sub_delims    = Regex("[!\\$&'\\(\\)\\*\\+,;=]");
  static public final reg_name      = unreserved.or(pct_encoded).or(sub_delims).many().tokenize();
  static public final h16           = RepeatedUpto(HEXDIG,4).tokenize();
  static public final ls32          = h16.and(id(":")).then(tp(ct)).and(h16).then(tp(ct)).or(IPv4address());
  static public final IPv6Section   = h16.and(id(":")).then(tp(ct));
  static public final IPv6Address   = 
    RepeatedOnly(IPv6Section,6).tokenize().and(ls32).then(tp(ct))
    .or(
      id("::").and(RepeatedOnly(IPv6Section,5).tokenize()).then(tp(ct)).and(ls32).then(tp(ct))
    ).or(
      h16.option()
         .and(id("::"))
         .then(tp(ctlo))
         .and(RepeatedOnly(IPv6Section,4).tokenize()).then(tp(ct))
         .and(ls32)
         .then(tp(ct))
    ).or(
      IPv6Section.option().and(h16).then(tp(ctlo))
        .option()
        .and(id("::"))
        .then(tp(ctlo))
        .and(RepeatedOnly(IPv6Section,3).tokenize())
        .then(tp(ct))
        .and(ls32)
        .then(tp(ct))
    ).or(
      RepeatedOnlyUpto(IPv6Section,2).tokenize().and(h16).then(tp(ct))
      .option()
      .and(id("::")).then(tp(ctlo))
      .and(RepeatedOnly(IPv6Section,2).tokenize()).then(tp(ct))
      .and(ls32).then(tp(ct))
    ).or(
      RepeatedOnlyUpto(IPv6Section,3).tokenize().and(h16).then(tp(ct))
      .option()
      .and(id("::")).then(tp(ctlo))
      .and(h16).then(tp(ct))
      .and(ls32).then(tp(ct))
    ).or(
      RepeatedOnlyUpto(IPv6Section,4).tokenize().and(h16).then(tp(ct))
      .option()
      .and(id("::")).then(tp(ctlo))
      .and(ls32).then(tp(ct))
    ).or(
      RepeatedOnlyUpto(IPv6Section,5).tokenize().and(h16).then(tp(ct))
      .option()
      .and(id("::")).then(tp(ctlo))
      .and(h16).then(tp(ct))
    ).or(
      RepeatedOnlyUpto(IPv6Section,6).tokenize().and(h16).then(tp(ct))
      .option()
      .and(id("::")).then(tp(ctlo))
    );

  static public var digit						= Parse.digit;
  static public var alpha 					= Parse.alpha;
  static public var alphanum 				= Parse.alphanum;
  
  static public var hexR 						= "[A-F1-9]";
  static public var hex 						= Parsers.Regex(hexR).then(parseHex);

  static public function parseHex(x:String):Int {
    return ('0x' + x ).parseInt();
  }
  static public var escaped         =
    '%'.id()._and(hex).and(hex).then( function(x) return Std.string(x.fst() << 8 | x.snd()) );
    
    
  static public var reservedR				= "[;/?:+@&=~$,]";
  static public var reserved				= Regex(reservedR);
  
  static public var uric 						= 
    [reserved, unreserved, escaped].ors();
  
  static public var fragment 				=  
    '&'.id().not()._and(uric).many().tokenize().then(AddressNode.Fragment);	
    
  static public var fragments				=
    fragment.repsep( '&'.id() ).then(AddressNode.Segments);
  
  static public var query = 
    uric.many().tokenize().then(AddressNode.Query);
    
  static public var pcharR 					= ":@&=~$,";
  static public var pchar 					= [unreserved, escaped].ors().or(Regex(pcharR));
  static public var param 					= pchar.many().tokenize().then(AddressNode.Param);  
  static public var segment 				= 
    param.and_with( ';'.id()._and(param).many(), AddressNode.Segment.fn().then(Some));
  
  static public var path_segments 	=
    segment.and_with(('/'.id()._and( segment ).many()), 
        function(a:Null<AddressNode>, b:Null<Cluster<AddressNode>>):Option<PathSegs> {
          return Some([a].imm().concat(b));
        }
    );
  
  static public var port 						= Parse.digit.many().tokenize().then(Std.parseInt);
  static public var digP 						= Parse.digit.one_many().tokenize().then(Std.parseInt);
  
  //static public var IPV4Byte        = 
  static public var IPv4addressR 		= "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+";
  static public function IPv4address(){
    return Regex(IPv4addressR);
  }
    
  static public var toplabel     		= 
    alpha.or( alpha.and_with( alphanum.or('-'.id() ).many().tokenize().and_with(alphanum,sBnd),sBnd ) );
  
  static public var domainlabel			=
    alphanum.or( alphanum.and_with( alphanum.or('-'.id()).many().tokenize().and_with(alphanum,sBnd),sBnd) );
  
  static public var  hostname      	= 
    domainlabel.and_('.'.id()).and(toplabel).then(tp(ct)).and('.'.id().option()).then(tp(ctro));
    
  static public var host						=
    hostname.or( IPv4address()  );
  static public var hostport 				=
    host.and_with( ':'.id()._and(port).option(), Host.Named.fn().then(Some) );
    
  static public var userinfoR 			= ";:&=+$,";
  static public var userinfo 				= 
  [unreserved, escaped].ors().or( Regex(userinfoR) ).many().tokenize();
  
  static public var  server    			=
  userinfo.and_('@'.id()).option().and_with( hostport , 
    function(a, b) { return switch (a) { case Some(v) :  Server.Authenticated(v, b); default : Server.Simple(b); } } 
  );
    
  static public var  authority			= server.then( Authority.Serve ).or(reg_name.then(Authority.Reg));
    
  static public var  schemeR       	=  "[+-.]";
  static public var  scheme        	=  
    alpha.and_with( [ alpha , digit].ors().or( Regex(schemeR) ).many().tokenize(),sBnd );
    
  
  static public var abs_path     		= 
    '/'.id()._and(path_segments).then( Path.Absolute );
  
  static public var net_path    		= 
    '//'.id()._and( authority.and_with( abs_path.option() , Path.Net.fn().then(Some) ) );	
  
  static public var rel_segmentR 		=  "[;@&=~$,]";
  static public var rel_segment 		=
    [unreserved, escaped].ors().or(Regex(rel_segmentR)).one_many().tokenize();
    
  static public var rel_path      	= 
    rel_segment.and_with( abs_path.option() , Path.Relative.fn().then(Some));
  
  static public var uric_no_slashR 	= "[;?:@&=+$,]";
  static public var uric_no_slash 	= 
    [unreserved,escaped].ors().or( Regex(uric_no_slashR) );

  static public var opaque_part   	= 
  uric_no_slash.and_with(uric.many().tokenize(),sBnd).then(Part.Opaque);
  
  static public var	hier_part     	= 
    net_path.or(abs_path).and_with( '?'.id()._and(query).option(),
    function(a, b) {
      return switch (b) {
        case Some(v):
          Part.Query(a, v);
        default:
          Part.Simple(a);
      }
    }
  );
  static public var relativeURI   	= 
    net_path.or(abs_path).or(rel_path).and_with( '?'.id()._and(query).option() , Uri.Relative.fn().then(Some));
  
  static public var absoluteURI   	= 
    scheme.and_(':'.id()).and_with( hier_part.or(opaque_part),Uri.Absolute.fn().then(Some));
  
  static public var UriReference 		= 
    absoluteURI.or(relativeURI).and( '#'.id()._and(fragments).option() ).and_( Parsers.Eof() );
  }