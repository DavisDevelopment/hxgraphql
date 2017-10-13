package graphql.ast;

import tannus.io.*;
import tannus.ds.*;

import graphql.ast.Expr;
import graphql.ast.Field;
import graphql.ast.Fragment;
import graphql.ast.FragmentDeclaration;
import graphql.ast.Operation;

import Type;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Printer {
    /* Constructor Function */
    public function new():Void {
        prettyPrint = true;
        spaces = '   ';

        indentLevel = 0;
        buffer = '';
    }

/* === Instance Methods === */

    /**
      * generate and return the String output for the given Expression
      */
    public function print(e : Expression):String {
        printExpr( e );
        return toString();
    }

    /**
      * reset [this] Printer
      */
    public inline function reset():Void {
        buffer = '';
        indentLevel = 0;
    }

    /**
      * print the given Expression
      */
    public inline function printExpr(e : Expression):Void {
        e.gqlPrint( this );
    }

    /**
      * write an argument list
      */
    public function writeArgs(args : Args):Void {
        //var strings = args.map.fn(_.name + ': ' + Std.string( _.value ));
        //write('(' + strings.join(', ') + ')');
        write('(');
        var i = args.iterator();
        var arg : Arg;
        while (i.hasNext()) {
            arg = i.next();
            write( arg.name );
            write(': ');
            writeValue( arg.value );
            if (i.hasNext()) {
                write(', ');
            }
        }
        write(')');
    }

    /**
      * write an argument value
      */
    public function writeValue(value : Dynamic):Void {
        var json = (untyped __js__('JSON.stringify'));
        if ((value is Bool) || (value is Float) || (value is String)) {
            write(json( value ));
        }
        else if ((value is Array<Dynamic>)) {
            writeArray(cast value);
        }
        else if (Reflect.isObject( value )) {
            writeObject( value );
        }
        else {
            write(Std.string( value ));
        }
    }

    /**
      * write an Array value
      */
    public function writeArray(a : Array<Dynamic>):Void {
        write('[');
        var i = a.iterator();
        while (i.hasNext()) {
            writeValue(i.next());
            if (i.hasNext()) {
                write(',');
            }
        }
        write(']');
    }

    /**
      * write an Object value
      */
    public function writeObject(o : Object):Void {
        write('{');
        var i = o.pairs().iterator();
        while (i.hasNext()) {
            var pair = i.next();
            write( pair.name );
            write(':');
            writeValue( pair.value );
            if (i.hasNext()) {
                write(',');
            }
        }
        write('}');
    }

    /**
      * append [x] to [buffer]
      */
    public inline function write(x : Dynamic):Void {
        buffer += Std.string( x );
    }

    /**
      * append [x] to [buffer]
      */
    public inline function w(x : Dynamic):Void write( x );

    /**
      * append [x], followed by a newline character, to [buffer]
      */
    public inline function writeln(x : Dynamic):Void {
        write( x );
        write(newline());
    }

    /**
      * append [x], followed by a newline character, to [buffer]
      */
    public inline function wln(x : Dynamic):Void writeln( x );

    /**
      * get the character to be used as a newline
      */
    public inline function newline():String {
        return (prettyPrint ? '\n' : ' ');
    }

    /**
      * convert [this] to a String
      */
    public inline function toString():String {
        return buffer;
    }

    /**
      * increase the indentation level
      */
    public inline function indent():Int {
        return ++indentLevel;
    }

    /**
      * decrease the indentation level
      */
    public inline function unindent():Int {
        return --indentLevel;
    }

    /**
      * get the indentation level
      */
    public inline function indentation():Int {
        return indentLevel;
    }

    /**
      * get the text used as the start of a new line
      */
    public inline function pre():String {
        return (prettyPrint ? spaces.times(indentation()) : '');
    }

    /**
      * open a block statement
      */
    public function oblock(?opener:Dynamic):Void {
        if (opener != null) {
            w(pre());
            w( opener );
        }
        wln(' {');
        indent();
    }

    /**
      * close a block statement
      */
    public function cblock():Void {
        unindent();
        wln(pre() + '}');
    }

    /**
      * generate a block statement
      */
    public function block(body : Printer->Void):Void {
        oblock();
        body( this );
        cblock();
    }

    public function writeBody(body : Null<Array<Expression>>):Void {
        if (body != null) {
            for (e in body) {
                printExpr( e );
            }
        }
    }

/* === Instance Fields === */

    public var prettyPrint : Bool;
    public var spaces : String;

    private var indentLevel : Int;
    private var buffer : String;
}
