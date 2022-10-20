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
 

class Uri {
  static public function id(str:String){
    return __.parse().id(str);
  }
  static public function oBnd<T>(l:Null<Option<T>>,r:Null<Option<T>>){
    return __.option(l).flat_map(x -> x).zip(__.option(r).flat_map(x -> x));
  }
  static public function sBnd<T>(l:Null<Option<T>>,r:Null<Option<T>>){
    return __.option(l).zip(__.option(r));
  }
  
  
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
    
  static public var markR 					= "[-_.!~*'()]";
  static public var mark 						= Regex(markR);
  
  static public var unreserved = 
  [Parse.alphanum, mark].ors();
    
  static public var reservedR				= "[;/?:+@&=~$,]";
  static public var reserved				= Regex(reservedR);
  
  static public var uric 						= 
    [reserved, unreserved, escaped].ors();
  
  static public var fragment 				=  
    '&'.id().not()._and(uric).many().token().then(Fragment);	
    
  static public var fragments				=
    fragment.repsep( '&'.id() ).then( Segments );
  
  static public var query = 
    uric.many().token().then(Query);
    
  static public var pcharR 					= ":@&=~$,";
  static public var pchar 					= [unreserved, escaped].ors().or(Regex(pcharR));
  static public var param 					= pchar.many().token().then(Param);  
  static public var segment 				= 
    param.and_with( ';'.id()._and(param).many(), AddressNode.Segment);
  
  static public var path_segments 	=
    segment.and_with( '/'.id()._and( segment ).many() , 
        function(a, b):PathSegs {
          return [a].concat(b);
        }
    );
  
  static public var port 						= Parse.digit.many().token().then(Std.parseInt);
  static public var digP 						= Parse.digit.one_many().token().then(Std.parseInt);
  
  static public var IPv4addressR 		= "[1-9]+.[1-9]+.[1-9]+.[1-9]+";
  static public var IPv4address     = Regex(IPv4addressR);
    
  static public var toplabel     		= 
    alpha.or( alpha.and_with( alphanum.or('-'.id() ).many().token().and_with(alphanum,sBnd),sBnd ) );
  
  static public var domainlabel			=
    alphanum.or( alphanum.and_with( alphanum.or('-'.id()).many().token().and_with(alphanum,sBnd),sBnd) );
  
  static public var  hostname      	= 
    domainlabel.and_with('.'.id(), sBnd).and_with( toplabel.and_with( '.'.id().option() , oBnd ), sBnd );
    
  static public var host						=
    hostname.or( IPv4address  );
  static public var hostport 				=
    host.and_with( ':'.id()._and(port).option(), Host.Named );
    
  static public var userinfoR 			= ";:&=+$,";
  static public var userinfo 				= 
  [unreserved, escaped].ors().or( Regex(userinfoR) ).many().token();
  
  static public var  server    			=
  userinfo.and_('@'.id()).option().and_with( hostport , 
    function(a, b) { return switch (a) { case Some(v) :  Server.Authenticated(v, b); default : Server.Simple(b); } } 
  );

  static public var reg_nameR     	= 
    "$,;:@&=+";
  static public var reg_name      	=
    [unreserved,escaped].ors().or( Regex(reg_nameR) ).one_many().token();
    
  static public var  authority			= server.then( Authority.Serve ).or(reg_name.then(Authority.Reg));
    
  static public var  schemeR       	=  "[+-.]";
  static public var  scheme        	=  
    alpha.and_with( [ alpha , digit].ors().or( Regex(schemeR) ).many().token(),sBnd );
    
  
  static public var abs_path     		= 
    '/'.id()._and(path_segments).then( Path.Absolute );
  
  static public var net_path    		= 
    '//'.id()._and( authority.and_with( abs_path.option() , Path.Net ) );	
  
  static public var rel_segmentR 		=  "[;@&=~$,]";
  static public var rel_segment 		=
    [unreserved, escaped].ors().or(Regex(rel_segmentR)).one_many().token();
    
  static public var rel_path      	= 
    rel_segment.and_with( abs_path.option() , Path.Relative);
  
  static public var uric_no_slashR 	= "[;?:@&=+$,]";
  static public var uric_no_slash 	= 
    [unreserved,escaped].ors().or( Regex(uric_no_slashR) );

  static public var opaque_part   	= 
  uric_no_slash.and_with(uric.many().token(),sBnd).then(Part.Opaque);
  
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
    net_path.or(abs_path).or(rel_path).and_with( '?'.id()._and(query).option() , Uri.Relative);
  
  static public var absoluteURI   	= 
    scheme.and_(':'.id()).and_with( hier_part.or(opaque_part),Uri.Absolute);
  
  static public var UriReference 		= 
    absoluteURI.or(relativeURI).and( '#'.id()._and(fragments).option() ).and_( Parsers.end );
  }