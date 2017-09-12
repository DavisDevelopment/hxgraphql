package graphql.ast;

enum Expr {
    EDocument(body : Array<Expr>);
    EOperation(name:Null<String>, body:Array<Expr>);
    EField(name:String, ?alias:String, ?args:Args, ?body:Array<Expr>);
    EConnection(name:String, ?alias:String, ?args:Args, ?body:Array<Expr>);
    EFragmentDecl(name:String, onType:String, body:Array<Expr>);
    EFragment(name : String);
}

typedef Arg = {
    var name : String;
    var value : Dynamic;
}
