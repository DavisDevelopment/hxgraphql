package graphql.ast;

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
            startCursor: true,
            endCursor: true
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
        args.set('first', page.first);
        if (page.after != null)
            args.set('after', page.after);
        if (page.offset != null)
            args.set('offset', page.offset);
        if (page.reverse != null)
            args.set('reverse', page.reverse);
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

/* === Instance Fields === */

    public var page : PageOptions;
    public var pagination : PaginationInfoOptions;
}

typedef ConnectionOptions = {
    >FieldOptions,
    page: PageOptions,
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
