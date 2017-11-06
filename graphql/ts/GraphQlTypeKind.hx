package graphql.ts;

import tannus.ds.Set;

import graphql.ts.GraphQlType as Type;

enum GraphQlTypeKind {
    KScalar(scalar : ScalarType);
    KArray(type : Type);
    KInterface(i : InterfaceType);
    KTypedef(def : TypedefType);
    KUnion(union : UnionType);
    KInput(input : TypedefType);
    KEnum(enumeration : EnumType);

    KLazy(name : String);
}

enum ScalarType {
    Boolean;
    Float;
    Int;
    String;
    ID;
    Custom(cs : CustomScalarType);
}

@:structInit
class CustomScalarType {
    public var name : String;
    //public var config : Dynamic;
}

@:structInit
class InterfaceType {
    public var name : String;
    public var fields : Array<Field>;
}

@:structInit
class TypedefType {
    public var name : String;
    @:optional
    public var interfaces : Null<Array<InterfaceType>>;
    public var fields : Array<Field>;
}

@:structInit
class Field {
    public var name:String;
    public var type:Type;
    @:optional
    public var arguments:Null<Array<Argument>>;
}

@:structInit
class Argument {
    public var name : String;
    public var type : Type;
    @:optional
    public var defaultValue : Dynamic;
}

@:structInit
class UnionType {
    public var name : String;
    public var types : Array<Type>;
}

@:structInit
class EnumType {
    public var name : String;
    public var constructs : Set<String>;
}
