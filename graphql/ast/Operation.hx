package graphql.ast;

import graphql.ast.Expr;
import graphql.ast.Field;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Operation extends BlockExpression<Operation> implements Expression {
    /* Constructor Function */
    public function new(options : OperationOptions):Void {
        super();

        this.name = options.name;
        this.body = options.body;

        this.options = options;
    }

/* === Instance Methods === */

    /**
      * convert [this] into an expression
      */
    public function toExpr():Expr {
        return Expr.EOperation(name, body.map.fn(_.toExpr()));
    }

    /**
      * create and return a deep copy of [this]
      */
    public function clone():Expression {
        return new Operation({
            name: name,
            body: body.map.fn(_.clone())
        });
    }

/* === Instance Fields === */

    public var name : Null<String>;

    private var options : OperationOptions;
}

typedef OperationOptions = {
    ?name: String,
    body: Array<Expression>
};
