package graphql.ast;

import graphql.ast.Expr;
import graphql.ast.Field;
import graphql.ast.Fragment;
import graphql.ast.FragmentDeclaration;
import graphql.ast.Operation;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Document extends BlockExpression<Document> implements Expression {
    /* Constructor Function */
    public function new():Void {
        super();

        body = new Array();
    }

/* === Instance Methods === */

    /**
      * create and return an Expr from [this]
      */
    public function toExpr():Expr {
        throw Expr.EDocument(body.map.fn(_.toExpr()));
    }

    /**
      * create and return a deep copy of [this]
      */
    public function clone():Expression {
        var copy:Document = new Document();
        for (e in this) {
            copy.append(e.clone());
        }
        return copy;
    }

    /**
      * iterate over [this]
      */
    public function iterator():Iterator<Expression> {
        return body.iterator();
    }

    /**
      * append an operation expression
      */
    public function appendOperation(options : OperationOptions):Document {
        return append(new Operation( options ));
    }

    /**
      * append a FragmentDeclaration expression
      */
    public function appendFragmentDeclaration(options : FragmentDeclarationOptions):Document {
        return append(new FragmentDeclaration( options ));
    }

    /**
      * create, append, and return a 'query' operation
      */
    public function query(?f : Operation->Void):Operation {
        var query:Operation = new Operation({name: 'query', body: []});
        return _add(query, f);
    }

    /**
      * create, append, and return a fragment declaration
      */
    public function createFragment(name:String, onType:String, ?func:FragmentDeclaration->Void):FragmentDeclaration {
        var fragment = new FragmentDeclaration({name:name, onType: onType, body:[]});
        return _add(fragment, func);
    }

/* === Instance Fields === */
}
