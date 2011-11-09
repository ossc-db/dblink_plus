/*-------------------------------------------------------------------------
 *
 * option.c
 *		  FDW option handling
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/option.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/reloptions.h"
#include "catalog/pg_foreign_data_wrapper.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_foreign_table.h"
#include "catalog/pg_user_mapping.h"
#include "fmgr.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "miscadmin.h"

#include "pgsql_fdw.h"

/*
 * SQL functions
 */
extern Datum pgsql_fdw_validator(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pgsql_fdw_validator);

/*
 * Describes the valid options for objects that use this wrapper.
 */
typedef struct PgsqlFdwOption
{
	const char *optname;
	Oid			optcontext;		/* Oid of catalog in which options may appear */
	bool		is_libpq_opt;	/* true if it's used in libpq */
} PgsqlFdwOption;

/*
 * Valid options for pgsql_fdw.
 */
static PgsqlFdwOption valid_options[] = {

	/*
	 * Options for libpq connection.
	 * Note: This list should be updated along with PQconninfoOptions in
	 * interfaces/libpq/fe-connect.c, so the order is kept as is.
	 *
	 * Some useless libpq connection options are not accepted by pgsql_fdw:
	 *   client_encoding: set to local database encoding automatically
	 *   fallback_application_name: fixed to "pgsql_fdw"
	 *   replication: pgsql_fdw never be replication client
	 */
	{"authtype", ForeignServerRelationId, true},
	{"service", ForeignServerRelationId, true},
	{"user", UserMappingRelationId, true},
	{"password", UserMappingRelationId, true},
	{"connect_timeout", ForeignServerRelationId, true},
	{"dbname", ForeignServerRelationId, true},
	{"host", ForeignServerRelationId, true},
	{"hostaddr", ForeignServerRelationId, true},
	{"port", ForeignServerRelationId, true},
#ifdef NOT_USED
	{"client_encoding", ForeignServerRelationId, true},
#endif
	{"tty", ForeignServerRelationId, true},
	{"options", ForeignServerRelationId, true},
	{"application_name", ForeignServerRelationId, true},
#ifdef NOT_USED
	{"fallback_application_name", ForeignServerRelationId, true},
#endif
	{"keepalives", ForeignServerRelationId, true},
	{"keepalives_idle", ForeignServerRelationId, true},
	{"keepalives_interval", ForeignServerRelationId, true},
	{"keepalives_count", ForeignServerRelationId, true},
#ifdef USE_SSL
	{"requiressl", ForeignServerRelationId, true},
#endif
	{"sslmode", ForeignServerRelationId, true},
	{"sslcert", ForeignServerRelationId, true},
	{"sslkey", ForeignServerRelationId, true},
	{"sslrootcert", ForeignServerRelationId, true},
	{"sslcrl", ForeignServerRelationId, true},
	{"requirepeer", ForeignServerRelationId, true},
#if defined(KRB5) || defined(ENABLE_GSS) || defined(ENABLE_SSPI)
	{"krbsrvname", ForeignServerRelationId, true},
#endif
#if defined(ENABLE_GSS) && defined(ENABLE_SSPI)
	{"gsslib", ForeignServerRelationId, true},
#endif
#ifdef NOT_USED
	{"replication", ForeignServerRelationId, true},
#endif

	/*
	 * Options for translation of object names.
	 */
	{"nspname", ForeignTableRelationId, false},
	{"relname", ForeignTableRelationId, false},
	{"colname", AttributeRelationId, false},

	/*
	 * Options for cursor behavior.
	 * These options can be overridden by finer-grained objects.
	 */
	{"fetch_count", ForeignTableRelationId, false},
	{"fetch_count", ForeignServerRelationId, false},

	/* Terminating entry --- MUST BE LAST */
	{NULL, InvalidOid, false}
};

/*
 * Helper functions
 */
static bool is_valid_option(const char *optname, Oid context);

/*
 * Validate the generic options given to a FOREIGN DATA WRAPPER, SERVER,
 * USER MAPPING or FOREIGN TABLE that uses pgsql_fdw.
 *
 * Raise an ERROR if the option or its value is considered invalid.
 */
Datum
pgsql_fdw_validator(PG_FUNCTION_ARGS)
{
	List	   *options_list = untransformRelOptions(PG_GETARG_DATUM(0));
	Oid			catalog = PG_GETARG_OID(1);
	ListCell   *cell;

	/*
	 * Check that only options supported by pgsql_fdw, and allowed for the
	 * current object type, are given.
	 */
	foreach(cell, options_list)
	{
		DefElem    *def = (DefElem *) lfirst(cell);

		if (!is_valid_option(def->defname, catalog))
		{
			PgsqlFdwOption *opt;
			StringInfoData buf;

			/*
			 * Unknown option specified, complain about it. Provide a hint
			 * with list of valid options for the object.
			 */
			initStringInfo(&buf);
			for (opt = valid_options; opt->optname; opt++)
			{
				if (catalog == opt->optcontext)
					appendStringInfo(&buf, "%s%s", (buf.len > 0) ? ", " : "",
									 opt->optname);
			}

			ereport(ERROR,
					(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
					 errmsg("invalid option \"%s\"", def->defname),
					 errhint("Valid options in this context are: %s",
							 buf.data)));
		}

		/* fetch_count be positive digit number. */
		if (strcmp(def->defname, "fetch_count") == 0)
		{
			long value;
			char *p = NULL;

			value = strtol(strVal(def->arg), &p, 10);
			if (*p != '\0' || value < 1)
				ereport(ERROR,
						(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						 errmsg("invalid value for %s: \"%s\"",
								def->defname, strVal(def->arg))));
		}
	}

	/*
	 * We don't care option-specific limitation here; they will be validated at
	 * the execution time. 
	 */

	PG_RETURN_VOID();
}

/*
 * Check whether the given option is one of the valid pgsql_fdw options.
 * context is the Oid of the catalog holding the object the option is for.
 */
static bool
is_valid_option(const char *optname, Oid context)
{
	PgsqlFdwOption *opt;

	for (opt = valid_options; opt->optname; opt++)
	{
		if (context == opt->optcontext && strcmp(opt->optname, optname) == 0)
			return true;
	}
	return false;
}

/*
 * Check whether the given option is one of the valid libpq options.
 * context is the Oid of the catalog holding the object the option is for.
 */
static bool
is_libpq_option(const char *optname)
{
	PgsqlFdwOption *opt;

	for (opt = valid_options; opt->optname; opt++)
	{
		if (strcmp(opt->optname, optname) == 0 && opt->is_libpq_opt)
			return true;
	}
	return false;
}

/*
 * Generate key-value arrays which includes only libpq options from the list
 * which contains any kind of options.
 */
int
ExtractConnectionOptions(List *defelems, const char **keywords, const char **values)
{
	ListCell *lc;
	int i;

	i = 0;
	foreach(lc, defelems)
	{
		DefElem *d = (DefElem *) lfirst(lc);
		if (is_libpq_option(d->defname))
		{
			keywords[i] = d->defname;
			values[i] = strVal(d->arg);
			i++;
		}
	}
	return i;
}

/*
 * If an option entry which matches the given name was found in the given
 * list, returns a copy of arg string, otherwise returns NULL.
 */
static char *
get_options_value(List *options, const char *optname)
{
	ListCell   *lc;

	/* Find target option from the list. */
	foreach (lc, options)
	{
		DefElem	   *def = lfirst(lc);

		if (strcmp(def->defname, optname) == 0)
			return pstrdup(strVal(def->arg));
	}

	return NULL;
}

/*
 * Returns a copy of the value of specified option with searching the option
 * from appropriate catalog.  If an option was stored in multiple object
 * levels, one in the finest-grained object level is used; lookup order is:
 *   1) pg_foreign_table
 *   2) pg_user_mapping
 *   3) pg_foreign_server
 *   4) pg_foreign_data_wrapper
 * This priority rule would be useful in most cases using FDW options.
 *
 * If attnum was InvalidAttrNumber, we don't retrieve FDW optiosn from
 * pg_attribute.attfdwoptions.
 */
char *
GetFdwOptionValue(Oid relid, const char *optname)
{
	ForeignTable   *table = NULL;
	UserMapping	   *user = NULL;
	ForeignServer  *server = NULL;
	ForeignDataWrapper  *wrapper = NULL;
	char		   *value;

	table = GetForeignTable(relid);
	value = get_options_value(table->options, optname);
	if (value != NULL)
		return value;

	user = GetUserMapping(GetOuterUserId(), table->serverid);
	value = get_options_value(user->options, optname);
	if (value != NULL)
		return value;

	server = GetForeignServer(table->serverid);
	value = get_options_value(server->options, optname);
	if (value != NULL)
		return value;

	wrapper = GetForeignDataWrapper(server->fdwid);
	value = get_options_value(wrapper->options, optname);
	if (value != NULL)
		return value;

	return NULL;
}
