package graphql.ts;

import graphql.ts.GraphQlTypeKind;

using graphql.ts.GraphQlTypeTools;

class GraphQlType {
    /* Constructor Function */
    public function new(type:GraphQlTypeKind, nonNull:Bool=false):Void {
        this.kind = type;
        this.nonNull = nonNull;
        this.name = kind.kindName();
    }

/* === Instance Methods === */

/* === Instance Fields === */

    public var name : String;
    public var nonNull : Bool;
    public var kind : GraphQlTypeKind;
}
