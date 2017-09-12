package graphql.ast;

import tannus.io.*;
import tannus.ds.*;

import graphql.ast.Expr;
import graphql.ast.Field;
import graphql.ast.Fragment;
import graphql.ast.FragmentDeclaration;
import graphql.ast.Operation;

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
    }

/* === Instance Methods === */

/* === Instance Fields === */

    public var prettyPrint : Bool;
    public var spaces : String;

    private var indentLevel : Int;
}
