/*-------------------------------------------------------------------------
 *
 * option.c
 *		  FDW option handling
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/option.c
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
#include "utils/guc.h"

#include "oracle_fdw.h"
#include "routine.h"

/*
 * SQL functions
 */
extern Datum oracle_fdw_validator(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(oracle_fdw_validator);

/*
 * Describes the valid options for objects that use this wrapper.
 */
typedef struct OracleFdwOption
{
	const char *optname;
	Oid			optcontext;		/* Oid of catalog in which options may appear */
} OracleFdwOption;

/*
 * Valid options for oracle_fdw.
 */
static OracleFdwOption valid_options[] = {
	/*
	 * Options for Oracle connection.
	 */
	{"user", UserMappingRelationId},
	{"password", UserMappingRelationId},
	{"dbname", ForeignServerRelationId},

	/*
	 * Options for translation of object names.
	 * Note: Per-column options are not supported in 9.1, so we can't translate
	 * column name.
	 */
	{"nspname", ForeignTableRelationId},
	{"relname", ForeignTableRelationId},

	/*
	 * Options for fetch behavior.
	 * These options can be overridden by finer-grained objects.
	 */
	{"max_value_len", ForeignTableRelationId},
	{"max_value_len", ForeignServerRelationId},
	{"fetchsize", ForeignTableRelationId},
	{"fetchsize", ForeignServerRelationId},

	/*
	 * Options for routine mapping.
	 */
	{"format", RoutineMappingRelationId},
	{"nargs", RoutineMappingRelationId},

	/* Terminating entry --- MUST BE LAST */
	{NULL, InvalidOid}
};

/*
 * Helper functions
 */
static bool is_valid_option(const char *optname, Oid context);

/*
 * Validate the generic options given to a FOREIGN DATA WRAPPER, SERVER,
 * USER MAPPING or FOREIGN TABLE that uses oracle_fdw.
 *
 * Raise an ERROR if the option or its value is considered invalid.
 */
Datum
oracle_fdw_validator(PG_FUNCTION_ARGS)
{
	List	   *options_list = untransformRelOptions(PG_GETARG_DATUM(0));
	Oid			catalog = PG_GETARG_OID(1);
	ListCell   *cell;

	/*
	 * Check that only options supported by oracle_fdw, and allowed for the
	 * current object type, are given.
	 */
	foreach(cell, options_list)
	{
		DefElem    *def = (DefElem *) lfirst(cell);

		if (!is_valid_option(def->defname, catalog))
		{
			OracleFdwOption *opt;
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

		/* fetchsize be positive digit number. */
		if (strcmp(def->defname, "fetchsize") == 0)
		{
			int	value;

			value = parse_int_value(strVal(def->arg), "fetchsize");
		}

		/* max_value_len be integer number. */
		if (strcmp(def->defname, "max_value_len") == 0)
		{
			int	value;

			value = parse_int_value(strVal(def->arg), "max_value_len");

			/* -1 is the terminal null character of the fetch buffer. */
			if (value > MAX_DATA_SIZE - 1)
				ereport(ERROR,
						(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						 errmsg("invalid value for %s: \"%s\"",
								def->defname, strVal(def->arg))));
		}

		/* nargs be positive digit number or zero. */
		if (strcmp(def->defname, "nargs") == 0)
		{
			long value;
			char *p = NULL;

			value = strtol(strVal(def->arg), &p, 10);
			if (*p != '\0' || value < 0 || value > FUNC_MAX_ARGS - 1)
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
 * Check if the provided option is one of the valid options.
 * context is the Oid of the catalog holding the object the option is for.
 */
static bool
is_valid_option(const char *optname, Oid context)
{
	OracleFdwOption *opt;

	/*
	 * look up option table and determine valid context.
	 */
	for (opt = valid_options; opt->optname; opt++)
	{
		if (context == opt->optcontext && strcmp(opt->optname, optname) == 0)
			return true;
	}
	return false;
}

/*
 * Retrieve value of specified option from appropriate catalog; some options
 * are allowed to be stored in multiple objects in different level, e.g.
 * servers and tables, and then finer grained one overrides others.
 * This priority is implemented with the order of valid_optoins array, so
 * keep items which should be overridden after fine-grained one.
 * NULL is returned if such option was not found.
 */
const char *
GetFdwOption(Oid relid, const char *optname)
{
	OracleFdwOption	   *opt;
	ForeignTable   *table;
	UserMapping	   *user;
	ForeignServer  *server;
	ForeignDataWrapper  *wrapper;
	List		   *options = NIL;
	ListCell	   *lc;

	for (opt = valid_options; opt->optname; opt++)
	{
		if (strcmp(opt->optname, optname) == 0)
		{
			/* Determine the type of target object and retrieve options. */
			table = GetForeignTable(relid);
			if (opt->optcontext == ForeignTableRelationId)
			{
				options = table->options;
			}
			else if (opt->optcontext == UserMappingRelationId)
			{
				user = GetUserMapping(GetOuterUserId(), table->serverid);
				options = user->options;
			}
			else if (opt->optcontext == ForeignServerRelationId)
			{
				server = GetForeignServer(table->serverid);
				options = server->options;
			}
			else if (opt->optcontext == ForeignDataWrapperRelationId)
			{
				server = GetForeignServer(table->serverid);
				wrapper = GetForeignDataWrapper(server->fdwid);
				options = wrapper->options;
			}
		}
	}

	/* Find target option from the list. */
	foreach (lc, options)
	{
		DefElem	   *def = lfirst(lc);

		if (strcmp(def->defname, optname) == 0)
			return strVal(def->arg);
	}

	return NULL;
}

const char *
GetFdwOptionList(List *defelems, const char *keyword)
{
	ListCell *lc;

	foreach(lc, defelems)
	{
		DefElem *d = (DefElem *) lfirst(lc);
		if (pg_strcasecmp(keyword, d->defname) == 0)
		{
			if (d->arg)
				return strVal(d->arg);
			else
				return NULL;
		}
	}

	return NULL;
}

int
parse_int_value(const char *value, const char *keyword)
{
	int			result;
	const char *hintmsg;

	if (!parse_int(value, &result, 0, &hintmsg))
	{
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("invalid value for parameter \"%s\": \"%s\"",
						keyword, value),
				 hintmsg ? errhint("%s", _(hintmsg)) : 0));
	}

	return result;
}
