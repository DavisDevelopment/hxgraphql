package graphql.ast;

import tannus.ds.Object;

import graphql.ast.Expr;
import graphql.ast.Field;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;

class Connection extends Field {
    /* Constructor Function */
    public function new(options : ConnectionOptions):Void {
        super({
            name: options.name,
            alias: options.alias
        });

        pagination = {
            hasNextPage: true,
            hasPreviousPage: true,
            startCursor: false,
            endCursor: false
        };
        page = options.page;

        // copy [options.pagination] onto [pagination]
        if (options.pagination != null) {
            var p = options.pagination;
            if (p.hasNextPage != null)
                pagination.hasNextPage = p.hasNextPage;
            if (p.hasPreviousPage != null)
                pagination.hasPreviousPage = p.hasPreviousPage;
            if (p.startCursor != null)
                pagination.startCursor = p.startCursor;
            if (p.endCursor != null)
                pagination.endCursor = p.endCursor;
        }

        // ensure that [args] exists
        if (args == null)
            args = new Args([]);

        // copy [page] data onto [args]
        for (key in page.keys) {
            args.set(key, page[key]);
        }
    }

/* === Instance Methods === */

    /**
      * convert [this] to an Expr
      */
    override function toExpr():Expr {
        var bod:Null<Array<Expr>> = null;
        if (body != null) {
            bod = body.map.fn(_.toExpr());
        }
        return Expr.EConnection(name, alias, args, bod);
    }

    /**
      * create and return a clone of [this]
      */
    override function clone():Expression {
        return new Connection({
            name: name,
            alias: alias,
            args: args,
            body: body,
            pagination: pagination,
            page: page
        });
    }

    /**
      * generate GraphQl code for [this]
      */
    @:keep
    override function gqlPrint(p : Printer):Void {
        p.w(p.pre());
        if (alias != null) {
            p.w('$alias: ');
        }
        p.w( name );
        if (args != null) {
            p.writeArgs( args );
        }
        p.wln(' {');
        p.indent();

        // write pageInfo
        var pif = pageInfoField();
        p.printExpr( pif );
        // end pageInfo

        // write edges
        p.oblock( 'edges' );
        p.wln(p.pre() + 'cursor');

        // write node
        p.oblock( 'node' );
        for (e in body) {
            p.printExpr( e );
        }
        // end node
        p.cblock();

        // end edges
        p.cblock();

        // end connection
        p.cblock();
    }

    /**
      * generate 'pageInfo' Field
      */
    private function pageInfoField():Field {
        var pi = new Field({name:'pageInfo'});
        pi.field('hasNextPage');
        pi.field('hasPreviousPage');
        return pi;
    }

/* === Instance Fields === */

    //public var page : PageOptions;
    public var page : Object;
    public var pagination : PaginationInfoOptions;
}

typedef ConnectionOptions = {
    >FieldOptions,
    page: Object,
    ?pagination: {?hasNextPage:Bool, ?hasPreviousPage:Bool, ?startCursor:Bool, ?endCursor:Bool}
};

typedef PaginationInfoOptions = {
    hasNextPage: Bool,
    hasPreviousPage: Bool,
    startCursor: Bool,
    endCursor: Bool
};

typedef PageOptions = {
    first: Int,
    ?after: String,
    ?offset: Int,
    ?reverse: Bool
};
