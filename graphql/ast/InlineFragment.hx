package graphql.ast;

import graphql.ast.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class InlineFragment extends BlockExpression<InlineFragment> implements Expression {
    /* Constructor Function */
    public function new(options : InlineFragmentOptions):Void {
        super();

        this.type = options.type;
        this.body = options.body;
    }

/* === Instance Methods === */

    public function toExpr():Expr {
        return Expr.EInlineFragment(type, body.map.fn(_.toExpr()));
    }

    public function clone():Expression {
        return new InlineFragment({
            type: type,
            body: body.map.fn(_.clone())
        });
    }

    public function gqlPrint(p : Printer):Void {
        p.oblock('... on $type');
        p.writeBody( body );
        p.cblock();
    }

/* === Instance Fields === */

    public var type : String;
}

typedef InlineFragmentOptions = {
    type: String,
    body: Array<Expression>
};
