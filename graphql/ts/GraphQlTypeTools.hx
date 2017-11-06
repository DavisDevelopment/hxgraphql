package graphql.ts;

import tannus.ds.Set;

import graphql.ts.GraphQlType as Type;
import graphql.ts.GraphQlTypeKind;

class GraphQlTypeTools {
    public static function scalarName(scalar : ScalarType):String {
        return switch (scalar) {
            case Boolean: 'Boolean';
            case Float: 'Float';
            case Int: 'Int';
            case String: 'String';
            case ID: 'ID';
            case Custom(_.name => name): name;
        };
    }
    public static function kindName(type : GraphQlTypeKind):String {
        return (switch (type) {
            case KScalar(scalarName(_)=>name): name;
            case KArray(_.name=>name): '[$name]';
            case KTypedef(_.name=>name),KInterface(_.name=>name),KUnion(_.name=>name),KInput(_.name=>name),KEnum(_.name=>name): name;
            case KLazy(name): name;
        });
    }
}
