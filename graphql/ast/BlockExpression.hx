package graphql.ast;

import tannus.ds.Object;

import graphql.ast.Expr;
import graphql.ast.Field;
import graphql.ast.Fragment;
import graphql.ast.Connection;
import graphql.ast.Mutation;
import graphql.ast.InlineFragment;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class BlockExpression <T:Expression> {
    /* Constructor Function */
    public function new():Void {
        body = null;
    }

/* === Instance Methods === */

    /**
      * append an Expression to [this]
      */
    public function append(expression : Expression):T {
        if (body == null) {
            body = new Array();
        }
        body.push( expression );
        return untyped this;
    }

    /**
      * add a Field expression
      */
    public function appendField(options : FieldOptions):T {
        return append(new Field( options ));
    }

    /**
      * append a Fragment expression
      */
    public function appendFragment(options : FragmentOptions):T {
        return append(new Fragment( options ));
    }

    /**
      * append a Connection expression
      */
    public function appendConnection(options : ConnectionOptions):T {
        return append(new Connection( options ));
    }

    public function appendMutation(options : MutationOptions):T {
        return append(new Mutation( options ));
    }

    public function appendInlineFragment(options : InlineFragmentOptions):T {
        return append(new InlineFragment( options ));
    }

    /**
      * add a Field expression
      */
    public function addField(name:String, ?alias:String, ?args:Array<Arg>, ?body:Array<Expression>):T {
        return appendField({
            name: name,
            alias: alias,
            args: args,
            body: body
        });
    }

    /**
      * add a Connection expression
      */
    public function addConnection(name:String, ?alias:String, page:PageOptions, ?body:Array<Expression>, ?pagination:PaginationInfoOptions):T {
        return appendConnection({
            name: name,
            alias: alias,
            body: body,
            page: page,
            pagination: pagination
        });
    }

    /**
      * add a Fragment expression
      */
    public function addFragment(name : String):T {
        return appendFragment({name: name});
    }

    public function addMutation(name:String, args:Args, ?body:Array<Expression>):T {
        return appendMutation({
            name: name, 
            args: args,
            body: body
        });
    }

    public function addInlineFragment(type:String, ?body:Array<Expression>):T {
        return appendInlineFragment({
            type: type,
            body: (body != null ? body : [])
        });
    }

    /**
      * append an Expression, and return it
      */
    private function _add<O:Expression>(expression:O, ?func:O->Void):O {
        append( expression );
        if (func != null) {
            func( expression );
        }
        return expression;
    }

    /**
      * create a Field expression
      */
    public function field(name:String, ?alias:String, ?oargs:Object, ?func:Field->Void):Field {
        var args = (oargs != null ? Args.fromObject( oargs ) : null);
        return _add(new Field({
            name: name,
            alias: alias,
            args: args
        }), func);
    }

    /**
      * create multiple Field expressions
      */
    public function fields(exprs:Array<String>):Void {
        for (se in exprs) {
            var gen = FieldParser.parseString( se );
            for (field in gen) {
                append( field );
            }
        }
    }

    /**
      * create a Connection expression
      */
    public function connection(name:String, ?alias:String, ?oargs:Object, page:Object, ?pagination:PaginationInfoOptions, ?func:Connection->Void):Connection {
        var args = (oargs != null ? Args.fromObject( oargs ) : null);
        return _add(new Connection({
            name: name,
            alias: alias,
            args: args,
            page: page,
            pagination: pagination
        }), func);
    }

    /**
      * create a Fragment expression
      */
    public function fragment(name:String, ?func:Fragment->Void):Fragment {
        return _add(new Fragment({name: name}), func);
    }

    public function inlineFragment(type:String, ?func:InlineFragment->Void):InlineFragment {
        return _add(new InlineFragment({type:type, body:[]}), func);
    }

    public function mutation(name:String, oargs:Object, ?func:Mutation->Void):Mutation {
        return _add(new Mutation({
            name: name,
            args: Args.fromObject( oargs )
        }), func);
    }

/* === Instance Fields === */

    public var body : Null<Array<Expression>>;
}
