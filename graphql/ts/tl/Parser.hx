package graphql.ts.tl;

import tannus.io.*;
import tannus.ds.*;
import tannus.ds.tuples.*;
import tannus.async.Either;

import graphql.ts.GraphQlType as Type;
import graphql.ts.GraphQlTypeKind;
import graphql.ts.GraphQlTypeKind.TypedefType;
import graphql.ts.GraphQlTypeKind.ScalarType;
import graphql.ts.GraphQlTypeKind.InterfaceType;
import graphql.ts.GraphQlTypeKind.EnumType;
import graphql.ts.GraphQlTypeKind.Field;
import graphql.ts.GraphQlTypeKind.Argument;

import Slambda.fn;

using StringTools;
using Slambda;
using tannus.ds.StringUtils;
using tannus.ds.ArrayTools;
using graphql.ts.GraphQlTypeTools;

@:access( tannus.io.ByteStack )
class Parser extends LexerBase {
    /* Constructor Function */
    public function new():Void {
        keywords = new Set();
        keywords.pushMany([
            'schema', 'query', 'mutation',
            'type', 'interface', 'union', 'enum',
            'scalar', 'input', 'implements'
        ]);
        scalars = [
            'Boolean' => ScalarType.Boolean,
            'Float' => Float,
            'Int' => Int,
            'String' => String,
            'ID' => ID
        ];
        types = new Dict();
    }

/* === Instance Methods === */

    public function parseType(s : String):Null<Type> {
        buf( s );
        nni();
        var ident = readIdent();
        if (ident == null) {
            return null;
        }
        else if (keywords.exists( ident )) {
            return parseTypeFromKeyword( ident );
        }
        else {
            return null;
        }
    }

    private function parseTypeFromKeyword(kw:String):Null<Type> {
        var kind : GraphQlTypeKind;
        nni();
        var name:String = readIdent( true );
        nni();
        switch ( kw ) {
            case 'type':
                var def = readTypedef( name );
                if (def == null) {
                    throw 'WhatTheFuck';
                }
                return types[name] = new Type(KTypedef( def ));

            case _:
                trace('unsupported keyword "$kw"');
                return null;
        }
    }

    private function readTypedef(name:String):Null<TypedefType> {
        nni();
        var interfaces:Null<Array<InterfaceType>> = [];
        if (isIdentChar(next())) {
            var kw = readIdent( true );
            if (kw == 'implements') {
                nni();
                var iname = readIdent( true );
                nni();
                trace('implements $iname');
                var it = getInterfaceType( iname );
                if (it == null)
                    error('Error: Type $iname not found');
                interfaces.push( it );
            }
            wtf();
        }
        if (atBoxOpen()) {
            advance();
            if (interfaces.empty())
                interfaces = null;
            var fields = readFields();
            var tdef:TypedefType = {
                name: name,
                fields: fields,
                interfaces: interfaces
            };
            return tdef;
        }
        else {
            throw 'WhatTheAnus';
        }
    }

    private function readFields():Null<Array<Field>> {
        var fl:Array<Field> = new Array();
        while (!atBoxClose()) {
            var field = readField();
            if (field != null) {
                fl.push( field );
            }
            nni();
        }
        if (fl.length == 0) {
            return null;
        }
        else {
            return fl;
        }
    }

    /**
      * parse a Field object
      */
    private function readField():Null<Field> {
        nni();
        var fieldName:String = readIdent(true);
        var fieldArgs:Null<Array<Argument>> = null;
        nni();
        trace(fieldName);
        if (next().equalsChar('(')) {
            advance();
            fieldArgs = readArguments();
            nni();
            trace(fieldArgs);
            if (next().equalsChar(')')) {
                advance();
            }
            else {
                throw 'SyntaxError: Missing )';
            }
        }
        nni();
        if (next().equalsChar(':')) {
            advance();
            nni();
            var fieldType:Null<Type> = readValueType();
            if (fieldType == null) {
                throw 'WhatTheFuck';
            }
            var field:Field = {
                name: fieldName, 
                arguments: fieldArgs,
                type: fieldType
            };
            return field;
        }
        else {
            throw 'Unexpected ${next().aschar}';
        }
    }

    /**
      * parse the Type declaration for a value
      */
    private function readValueType():Null<Type> {
        // Identifier => Type name
        if (next().isLetter()) {
            var typeName:Null<String> = readIdent( true );
            if (typeName == null) {
                throw 'WhatTheFuck';
            }
            else {
                var kind : GraphQlTypeKind;
                var type:Null<Type> = types.get( typeName );
                // type not found
                if (type == null) {
                    // defer typing to end of parsing
                    kind = KLazy( typeName );
                }
                else {
                    kind = type.kind;
                }
                type = new Type( kind );
                nni();
                if (next().equalsChar('!')) {
                    advance();
                    type.nonNull = true;
                }
                return type;
            }
        }
        // Array Type
        else if (next().ec('[')) {
            advance();
            var arrayType:Null<Type> = readValueType();
            if (arrayType == null) {
                throw 'WhatTheFuck';
            }
            var type:Type = new Type(KArray(arrayType));
            if (next().ec(']')) {
                advance();
                if (next().ec('!')) {
                    advance();
                    type.nonNull = true;
                }
            }
            else {
                throw 'SyntaxError: Missing ]';
            }
            return type;
        }
        else {
            throw 'WhatTheFuck';
        }
    }

    private function readArguments():Array<Argument> {
        var args = [];
        while (!next().ec(')')) {
            var nt = readNameTypePair();
            var dv:Dynamic = null;
            if (next().ec('=')) {
                advance();
                nni();
                dv = valueTokenValue(valueToken());
            }
            nni();
            var arg:Argument = {
                name: nt._0,
                type: nt._1,
                defaultValue: dv
            };
            args.push( arg );
            if (next().ec(',')) {
                advance();
                nni();
            }
            else if (next().ec(')')) {
                error('SyntaxError: Missing ,');
            }
        }
        return args;
    }

    private function readNameTypePair():Tup2<String, Type> {
        var name:String;
        var type:Type;
        nni();
        name = readIdent( true );
        nni();
        if (!next().equalsChar(':'))
            wtf();

        advance();
        nni();
        type = readValueType();
        nni();
        return new Tup2(name, type);
    }

    private function valueToken():Null<ValueToken> {
        if (next().isNumeric()) {
            var num = readFloat();
            if ((num is Int)) {
                return VInt(Std.int( num ));
            }
            else return VFloat( num );
        }
        else if (next().isLetter()) {
            var kw = readIdent();
            if (kw == 'true')
                return VBool(true);
            else if (kw == 'false')
                return VBool(false);
            else if (kw == 'null')
                return VNull;
            error('BettyError: "$kw" is not a value');
            return null;
        }
        else if (next().isAny('"', "'")) {
            return VString(readString());
        }
        wtf();
        return null;
    }

    private function valueTokenValue(t : ValueToken):Dynamic {
        return switch ( t ) {
            case VNull: null;
            case VBool(x): x;
            case VFloat(x): x;
            case VInt(x): x;
            case VString(x): x;
            case VArray(array): array.map(valueTokenValue);
        };
    }

    private function readIdent(fatal:Bool=false):Null<String> {
        return rod(fatal, fn(isIdentChar(next())), function() {
            var id:String = advance();
            while (!done && isIdentChar(next()))
                id += advance();
            return id;
        });
    }

    private function readString(fatal:Bool=false):Null<String> {
        return rod(fatal, fn(next().equalsChar('"')||next().equalsChar("'")), function() {
            var d:Byte = advance();
            return readGroup(d, d, '\\'.code).toString();
        });
    }

    private function readID(?fatal:Bool):Null<String> {
        return readString( fatal );
    }

    private function readInt(fatal:Bool=false):Null<Int> {
        return rod(fatal, fn(next().isNumeric()), function() {
            var s:String = advance();
            while (!done && next().isNumeric())
                s += advance();
            return Std.parseInt( s );
        });
    }

    private function readFloat(fatal:Bool=false):Null<Float> {
        return rod(fatal, fn(next().isNumeric()), function() {
            var s:String = advance(), dot:Bool = false;
            while (!done && (next().isNumeric() || (next().ec('.') && !dot))) {
                if (next().ec('.')) {
                    dot = true;
                }
                s += advance();
            }
            return Std.parseFloat( s );
        });
    }

    private function readBoolean(fatal:Bool=false):Null<Bool> {
        var s = readIdent( fatal );
        if (s == null)
            return null;
        else if (s == 'true')
            return true;
        else if (s == 'false')
            return false;
        else {
            throw 'TypeError: Expected Boolean; got "$s"';
        }
    }

    private function rod<T>(fatal:Bool, check:Void->Bool, consume:Void->T, ?error:Void->Dynamic):Null<T> {
        cws();
        if (done && fatal) {
            throw 'Error: Unexpected end of input';
        }
        else if ( !done ) {
            if (fatal && error == null) {
                error = untyped fn('Error: Unexpected ${next().char}');
            }

            if (check()) {
                return consume();
            }
            else if ( fatal ) {
                throw error();
            }
            else {
                return null;
            }
        }
        else {
            return null;
        }
    }
    private function _read<T>(check:Void->Bool, consume:Void->T):Null<T> {
        cws();
        if (!done && check()) {
            return consume();
        }
        else {
            return null;
        }
    }

    private function readt2():Tup2<Byte, Byte> return new Tup2(next(0), next(1));
    private function readt3():Tup3<Byte, Byte, Byte> return new Tup3(next(0), next(1), next(2));
    private function readt4():Tup4<Byte,Byte,Byte,Byte> return new Tup4(next(0),next(1),next(2),next(3));
    private function readt5():Tup5<Byte,Byte,Byte,Byte,Byte> return new Tup5(next(0),next(1),next(2),next(3),next(4));
    private function readt6():Tup6<Byte,Byte,Byte,Byte,Byte,Byte> return new Tup6(next(0),next(1),next(2),next(3),next(4),next(5));

/* === Utility Methods === */

    private function save():{b:ByteStack, i:Int} {
        return {b:buffer,i:buffer.i};
    }
    private function restore(x:{b:ByteStack,i:Int}) {
        this.buffer = x.b;
        this.buffer.seek( x.i );
    }
    private inline function buf(s : String):Void {
        buffer = new ByteStack(ByteArray.ofString( s ));
    }
    private inline function error(msg:String):Void throw new tannus.utils.Error( msg );
    private inline function wtf():Void error('WhatTheFuck');
    private inline function isSafeToRead(numChars:Int):Bool return (buffer.remaining()>=numChars);
    private inline function istr(n:Int):Bool return isSafeToRead(n);
    private function consumeComment():Void {
        if (atComment()) {
            switch (new Tup2(advance(), advance())) {
                case {_0:'/'.code, _1:betty}:
                    switch ( betty ) {
                        case '/'.code:
                            consumeLine();

                        case '*'.code:
                            advance();
                            advance();
                            var commentTxt:String = '';
                            while (isSafeToRead( 2 )) {
                                switch (readt2()) {
                                    case {_0:'*'.code, _1:'/'.code}:
                                        advance();
                                        advance();
                                        break;
                                    case _:
                                        commentTxt += advance();
                                }
                            }

                        case _:
                            throw 'WhatTheFuck';
                    }

                case _:
                    throw 'WhatTheFuck';
            }
        }
    }
    private inline function nni():Void nextNonIgnored();
    private function nextNonIgnored():Void {
        cws();
        if (atComment()) {
            consumeComment();
            return nextNonIgnored();
        }
        else {
            return ;
        }
    }
    private function nextNonWhiteSpace(?check:Void->Bool, ?error:Dynamic):Bool {
        consumeWhiteSpace();
        if ( done ) {
            if (error != null) {
                throw error;
            }
            else {
                return false;
            }
        }
        else if (check != null && !check() && error != null) {
            throw error;
        }
        else {
            return true;
        }
    }
    private inline function nnws(?f:Void->Bool, ?e:Dynamic):Bool return nextNonWhiteSpace(e);
    private function consumeWhiteSpace():Void {
        while (!done && next().isWhiteSpace())
            advance();
    }
    private inline function cws():Void consumeWhiteSpace();
    private function consumeLine():Void {
        while (!done && !next().isLineBreaking())
            advance();
    }

    private function isIdentChar(c : Byte):Bool {
        trace('butthole wanker');
        return (c.isAlphaNumeric() || (c.isAny('_', "$")));
    }
    private function atComment():Bool {
        switch ([next(), next(1)]) {
            case ['/'.code, '/'.code|'*'.code]:
                return true;
            default:
                return false;
        }
    }
    private inline function atBoxOpen():Bool { return (next().ec('{')); }
    private inline function atBoxClose():Bool return (next().ec('}'));

    private function getInterfaceType(name:String):Null<InterfaceType> {
        var type = types[name];
        return switch ( type.kind ) {
            case KInterface( i ): i;
            case _: null;
        };
    }

/* === Instance Fields === */

    private var keywords:Set<String>;
    private var scalars:Map<String, ScalarType>;

    public var types:Dict<String, Type>;
}

enum Token {}
enum ValueToken {
    VNull;
    VBool(v : Bool);
    VFloat(v : Float);
    VInt(v : Int);
    VString(s : String);
    VArray(a : Array<ValueToken>);
}
