package graphql.ast;

import graphql.ast.Expr;
import graphql.ast.Field;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class FragmentDeclaration extends BlockExpression<FragmentDeclaration> implements Expression {
    /* Constructor Function */
    public function new(options : FragmentDeclarationOptions):Void {
        super();

        this.name = options.name;
        this.onType = options.onType;
        this.body = options.body;

        this.options = options;
    }

/* === Instance Methods === */

    public function toExpr():Expr {
        return Expr.EFragmentDecl(name, onType, body.map.fn(_.toExpr()));
    }

    public function clone():Expression {
        return new FragmentDeclaration({
            name: name,
            onType: onType,
            body: body.map.fn(_.clone())
        });
    }

    /**
      * generate GraphQl code for [this]
      */
    @:keep
    public function gqlPrint(p : Printer):Void {
        p.oblock('fragment $name on $onType');
        for (e in body) {
            p.printExpr( e );
        }
        p.cblock();
    }

/* === Instance Fields === */

    public var name : String;
    public var onType : String;

    private var options : FragmentDeclarationOptions;
}

typedef FragmentDeclarationOptions = {
    name: String,
    onType: String,
    body: Array<Expression>
};
