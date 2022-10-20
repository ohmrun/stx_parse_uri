package stx.net.uri;

enum Path {
  Absolute( xs : PathSegs);
  Net( a :  Authority , xs : Option<Path> );
  Relative( rel : String , rest : Option<Path> );
}