package graphql.ast;

import graphql.ast.Expr;

interface Expression {
/* === Instance Methods === */

    public function toExpr():Expr;
    public function clone():Expression;

    public function gqlPrint(printer:Printer):Void;

/* === Instance Fields === */
}
