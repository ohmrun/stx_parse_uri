package stx.net.uri.test;

typedef IrisRoot = {
  @:list('tc:group') var groups : Array<IrisGroup>;
}
typedef IrisGroup = {
  @:attr var id               : String;
  @:attr var href             : String;
  @:tag('tc:desc') var desc   : String;
  @:list('tc:test') var tests : Array<IrisTestItem>;
}
typedef IrisTestItem = {
  @:attr                                        var id            : String; 
  @:optional @:tag("tc:uri")                    var uri           : String;
  @:optional @:tag("tc:base")                   var base          : String;
  @:optional @:tag("tc:scheme")                 var scheme        : String;
  @:optional @:tag("tc:ref")                    var ref           : String;
  @:optional @:tag("tc:expectRef")              var expectRef     : String;
}
private class Util{
  static final cdata_r = "<!\\[CDATA\\[((?!]]>).*)]]>";
  static public function cdata(str:String){
    final a = new hre.RegExp(cdata_r, "g");
    final b = a.exec(str);
    final c = b.groups[0];
    return __.option(c);
  }
}
class IrisTest extends TestCase{
  function p(){
    
  }
  function source(){
    return __.resource('iris').string();
  }
  var value(get,null) : IrisRoot;
  public function get_value(){
    return value == null ? 
        value = new tink.xml.Structure<IrisRoot>().read(Xml.parse(source())).sure() 
      : value;
  }
  function test_value(){
    final val = value;
    for(group in val.groups){
      for(test in group.tests){
        
        if(test.uri !=null){
          trace(test.uri);
          //final uri =  
        }else{

        }
      }
    }
  }
  
}