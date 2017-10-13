package graphql.ast;

import tannus.io.*;
import tannus.ds.*;

import graphql.ast.Expr;
import graphql.ast.Field;

import Slambda.fn;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class FieldParser extends LexerBase {
    /* Constructor Function */
    public function new():Void {
        //
    }

/* === Instance Methods === */

    public function parse(s : String):Array<Field> {
        buffer = new ByteStack(ByteArray.ofString( s ));
        fields = new Array();
        cur = {
            name: ''
        };

        while ( !done ) {
            parseNext();
        }

        return fields;
    }

    private function parseNext():Void {
        var c = next();
        if (c.isWhiteSpace()) {
            advance();
            if ( !done )
                parseNext();
        }
        // identifier
        else if (c.isAlphaNumeric()) {
            // get the identifier
            var ident:String = tkident();
            caws();
            // end of input
            if ( done ) {
                // name-only
                cur.name = ident;
                curcom();
            }
            else {
                // alias
                if (next().equalsChar(':')) {
                    advance();
                    caws();
                    if ( done ) {
                        throw 'SyntaxError: Unexpected end of input';
                    }
                    else if (next().isAlphaNumeric()) {
                        var alias = ident;
                        var name = tkident();
                        if (!done && next().equalsChar('(')) {
                            var args = tkargs();
                            cur.name = name;
                            cur.alias = alias;
                            cur.args = args;
                            curcom();
                        }
                        else {
                            cur.name = name;
                            cur.alias = alias;
                            curcom();
                        }
                    }
                }
                else if (next().equalsChar('(')) {
                    var args = tkargs();
                    cur.name = ident;
                    cur.args = args;
                    curcom();
                }
            }
        }
        else {
            throw 'SyntaxError: unexpected "$c"';
        }
    }

    /**
      * tokenize Args
      */
    private function tkargs():Args {
        if ( done ) {
            throw 'SyntaxError: Unexpected end of input';
        }

        var args:Args = new Args([]);
        var c = next();
        if (c.equalsChar('(')) {
            advance();
            c = next();
        }
        while (!done && !next().equalsChar(')')) {
            c = next();
            if (c.isWhiteSpace()) {
                caws();
                continue;
            }
            else if (c.isAlphaNumeric()) {
                var arg = tkarg();
                args.push( arg );
                if (next().equalsChar(',')) {
                    advance();
                }
                else if (next().equalsChar(')')) {
                    advance();
                    break;
                }
                else {
                    throw 'Unexpected "${next()}"';
                }
            }
            else {
                throw 'Unexpected $c';
            }
        }

        return args;
    }

    /**
      * tokenize an Arg
      */
    private function tkarg():Arg {
        var name = tkident();
        caws();
        if (next().equalsChar(':')) {
            advance();
            caws();
            var value = tkvalue();
            caws();
            return {
                name: name,
                value: value
            };
        }
        else {
            throw 'SyntaxError: Unexpected "${next()}"';
        }
    }

    /**
      * tokenize a raw value
      */
    private function tkvalue():Dynamic {
        caws();
        var c = next();
        if (c.isNumeric() || c.equalsChar('.')) {
            var snum:String = advance();
            while (!done && (next().equalsChar('.') || next().isNumeric())) {
                snum += advance();
            }
            return Std.parseFloat( snum );
        }
        else if (c.equalsChar('"') || c.equalsChar("'")) {
            var del = advance();
            var str = this.readGroup(del, del, '\\'.code);
            return str;
        }
        else if (c.isAlphaNumeric()) {
            var id = tkident();
            switch ( id ) {
                case 'true':
                    return true;
                case 'false':
                    return false;
                case 'null':
                    return null;
                default:
                    return id;
            }
        }
        else {
            throw 'SyntaxError: Unexpected "$c"';
        }
    }

    /**
      * tokenize an identifier
      */
    private function tkident():String {
        var id:String = advance();
        while (!done && next().isAlphaNumeric()) {
            id += advance();
        }
        return id;
    }

    /**
      * consume all whitespace characters
      */
    private function caws():Void {
        while (!done && next().isWhiteSpace()) {
            advance();
        }
    }

    /**
      * reset [cur] field
      */
    private inline function recur():Void {
        cur = {name: ''};
    }

    /**
      * add Field
      */
    private function addcur():Void {
        if (cur.name != '') {
            var field = new Field( cur );
            fields.push( field );
        }
    }

    /**
      * declare completion of [cur]
      */
    private inline function curcom():Void {
        addcur();
        recur();
    }

/* === Instance Fields === */

    public var fields : Array<Field>;

    private var cur : FieldOptions;

/* === Static Methods === */

    public static function parseString(s : String):Array<Field> {
        return (new FieldParser().parse( s ));
    }
}
