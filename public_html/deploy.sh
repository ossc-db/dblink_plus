#!/bin/bash

if [ x$1 == x"" ]
then
    echo "enter accountid"
    exit 1;
fi

USERNAME=$1

rsync -avz index.html $USERNAME@web.sourceforge.net:/home/project-web/interdbconnect/htdocs/index.html
rsync -avz style.css $USERNAME@web.sourceforge.net:/home/project-web/interdbconnect/htdocs/style.css
rsync -avz ../syncdb/doc/ $USERNAME@web.sourceforge.net:/home/project-web/interdbconnect/htdocs/syncdb/
rsync -avz ../dblink_plus/doc/ $USERNAME@web.sourceforge.net:/home/project-web/interdbconnect/htdocs/dblink_plus/
rsync -avz ../pgsql_fdw/doc/ $USERNAME@web.sourceforge.net:/home/project-web/interdbconnect/htdocs/pgsql_fdw/

