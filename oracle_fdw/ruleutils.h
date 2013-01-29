/*
 * ruleutils.h
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/ruleutils.h
 *
 */

#ifndef RULEUTILS_H
#define RULEUTILS_H

extern char * ora_deparse_expression(Node *expr, List *dpcontext,
				   bool forceprefix, bool showimplicit);
extern const char *ora_quote_identifier(const char *ident);

#endif   /* RULEUTILS_H */
