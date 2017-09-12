package graphql.ast;

import graphql.ast.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Field extends BlockExpression<Field> implements Expression {
    /* Constructor Function */
    public function new(options : FieldOptions):Void {
        super();

        this.name = options.name;
        this.alias = options.alias;
        this.args = options.args;
        this.body = options.body;

        this.options = options;
    }

/* === Instance Methods === */

    /**
      * convert to a Expr instance and return
      */
    public function toExpr():Expr {
        var bod:Null<Array<Expr>> = null;
        if (body != null) {
            bod = body.map.fn(_.toExpr());
        }
        return Expr.EField(name, alias, args, bod);
    }

    /**
      * create and return a clone of [this]
      */
    public function clone():Expression {
        return new Field({
            name: name,
            alias: alias,
            args: args,
            body: {
                if (body != null)
                    body.map.fn(_.clone());
                else null;
            }
        });
    }

/* === Instance Fields === */

    public var name : String;
    public var alias : Null<String>;
    public var args : Null<Args>;

    private var options : FieldOptions;
}

typedef FieldOptions = {
    name: String,
    ?alias: String,
    ?args: Args,
    ?body: Array<Expression>
};