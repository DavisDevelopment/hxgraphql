package graphql.ast;

import tannus.io.*;
import tannus.ds.*;

import graphql.ast.Expr;
import graphql.ast.Field;

import Slambda.fn;
import tannus.math.TMath.*;

using StringTools;
using tannus.ds.StringUtils;
using Slambda;
using tannus.ds.ArrayTools;
using tannus.math.TMath;

class Tools {
/* === Methods === */

    /**
      * convert an Expr to an Expression
      */
    public static function toExpression(e : Expr):Expression {
        switch ( e ) {
            case EDocument( body ):
                var doc = new Document();
                for (de in body) {
                    doc.append(toExpression( de ));
                }
                return cast doc;

            case EOperation(name, body):
                return cast new Operation({
                    name: name,
                    body: body.map( toExpression )
                });

            case EMutation(name, args, body):
                return cast new Mutation({
                    name: name,
                    args: args,
                    body: (body!=null?body.map(toExpression):null)
                });

            case EField(name, alias, args, body):
                return cast new Field({
                    name: name,
                    alias: alias,
                    args: args,
                    body: (body!=null?body.map(toExpression):null)
                });

            case EConnection(name, alias, args, page, body):
                return cast new Connection({
                    name: name,
                    alias: alias,
                    args: args,
                    page: page,
                    body: (body!=null?body.map(toExpression):null)
                });

            case EFragment(name):
                return cast new Fragment({
                    name: name
                });

            case EInlineFragment(type, body):
                return cast new InlineFragment({
                    type: type,
                    body: (body!=null?body.map(toExpression):null)
                });

            case EFragmentDecl(name, type, body):
                return cast new FragmentDeclaration({
                    name: name,
                    onType: type,
                    body: (body!=null?body.map(toExpression):null)
                });
        }
    }

    /**
      * iterate over all Expr values
      */
    public static function iter(e:Expr, i:Expr->Void):Void {
        switch ( e ) {
            case EDocument(body),EOperation(_,body),EInlineFragment(_,body),EFragmentDecl(_,_,body):
                body.iter( i );
            case EMutation(_, _, body) if (body != null):
                body.iter( i );
            case EField(_,_,_,body) if (body != null):
                body.iter( i );
            case EConnection(_,_,_,body) if (body != null):
                body.iter( i );
            case EFragment(_):
            default:
                null;
        }
    }

    /**
     * transform [e] using [f]
     */
    public static function map(e:Expr, f:Expr->Expr):Expr {
        inline function m(a:Array<Expr>) return a.map( f );
        inline function n(?a:Array<Expr>) return (a!=null?m(a):null);

        return switch ( e ) {
            case EDocument(el): EDocument(m(el));
            case EOperation(k,el): EOperation(k, m(el));
            case EMutation(k,a,el): EMutation(k,a,n(el));
            case EField(k,a,p,el): EField(k,a,p,n(el));
            case EConnection(k,k2,a,p,el): EConnection(k,k2,a,p,n(el));
            case EFragment(_): e;
            case EFragmentDecl(k,t,el): EFragmentDecl(k,t,m(el));
            case EInlineFragment(t,el): EInlineFragment(t,m(el));
        };
    }

    public static function freplace(e:Expr, test:Expr->Bool, with:Expr):Expr {
        if (test( e )) {
            return with;
        }
        else {
            function mapper(expr : Expr):Expr {
                if (test( expr )) {
                    return with;
                }
                else {
                    return map(expr, mapper);
                }
            }
            return map(e, mapper);
        }
    }

/* === Fields === */
}
