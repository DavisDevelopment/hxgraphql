package graphql.ast;

import graphql.ast.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Mutation extends BlockExpression<Mutation> implements Expression {
    /* Constructor Function */
    public function new(options : MutationOptions):Void {
        super();

        this.name = options.name;
        this.args = options.args;
        this.body = options.body;
        if (body == null) {
            body = new Array();
        }
    }

/* === Instance Methods === */

    public function toExpr():Expr {
        var bod:Null<Array<Expr>> = null;
        if (body != null) {
            bod = body.map.fn(_.toExpr());
        }
        return Expr.EMutation(name, args, bod);
    }

    public function clone():Expression {
        return new Mutation({
            name: name,
            args: args,
            body: {
                if (body != null)
                    body.map.fn(_.clone());
                else null;
            }
        });
    }

    @:keep
    public function gqlPrint(p : Printer):Void {
        p.w(p.pre());
        p.w( name );
        p.writeArgs( args );
        if (body != null) {
            p.oblock();
            for (e in body) {
                p.printExpr( e );
            }
            p.cblock();
        }
        else {
            p.w(p.newline());
        }
    }

/* === Instance Fields === */

    public var name : String;
    public var args : Args;
}

typedef MutationOptions = {
    name: String,
    args: Args,
    ?body: Array<Expression>
}
