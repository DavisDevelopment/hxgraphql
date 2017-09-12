package graphql.ast;

import tannus.ds.*;

import graphql.ast.Expr;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

@:forward
abstract Args (Array<Arg>) from Array<Arg> to Array<Arg> {
    /* Constructor Function */
    public inline function new(a : Array<Arg>):Void {
        this = a;
    }

/* === Instance Methods === */

    public function exists(name : String):Bool {
        for (arg in this) {
            if (arg.name == name)
                return true;
        }
        return false;
    }

    public function get<T>(name : String):Null<T> {
        for (arg in this) {
            if (arg.name == name) {
                return arg.value;
            }
        }
        return null;
    }

    public function set<T>(name:String, value:T):T {
        var wasSet:Bool = false;
        for (arg in this) {
            if (arg.name == name) {
                arg.value = value;
                wasSet = true;
                break;
            }
        }
        if ( !wasSet ) {
            this.push({
                name: name,
                value: value
            });
        }
        return value;
    }

    public function getArg(name : String):Null<Arg> {
        for (arg in this) {
            if (arg.name == name) {
                return arg;
            }
        }
        return null;
    }

    public function removeArg(name : String):Bool {
        var arg = getArg( name );
        if (arg != null)
            return this.remove( arg );
        else return false;
    }

/* === Casting Methods === */

    /**
      * create Args from an Object
      */
    @:from
    public static function fromObject(o : Object):Args {
        var args:Args = new Args(new Array());
        for (key in o.keys) {
            trace( key );
            args.set(key, o.get( key ));
        }
        return args;
    }
}
