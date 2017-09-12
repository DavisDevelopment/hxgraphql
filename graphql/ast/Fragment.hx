package graphql.ast;

import graphql.ast.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Fragment implements Expression {
    /* Constructor Function */
    public function new(options : FragmentOptions):Void {
        this.name = options.name;

        this.options = options;
    }

/* === Instance Methods === */

    /**
      * convert [this] to Expr
      */
    public function toExpr():Expr {
        return Expr.EFragment( name );
    }
    
    /**
      * create and return a deep copy of [this]
      */
    public function clone():Expression {
        return new Fragment( options );
    }

    /**
      * generate graphql code from [this]
      */
    @:keep
    public function gqlPrint(p : Printer):Void {
        p.wln(p.pre() + '...$name');
    }

/* === Instance Fields === */

    public var name : String;

    private var options : FragmentOptions;
}

typedef FragmentOptions = {
    name : String
};
