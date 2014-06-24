#!/bin/bash

PARSECOMMAND='grep -v "^#\|^$" | while read n v; do echo $n $v; done'

PG_USER=`IFS="="; cat regress.conf | eval $PARSECOMMAND | grep "PG_USER" | awk '{print $2}'`
OR_DBNM=`IFS="="; cat regress.conf | eval $PARSECOMMAND | grep "OR_DBNM" | awk '{print $2}'`
OR_USER=`IFS="="; cat regress.conf | eval $PARSECOMMAND | grep "OR_USER" | awk '{print $2}'`
OR_PASS=`IFS="="; cat regress.conf | eval $PARSECOMMAND | grep "OR_PASS" | awk '{print $2}'`

#-- postgresql parameters setting--
C_USER=`IFS="="; cat expected/postgres.out | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR" | awk '{print $10}'`
sed -i "s/user $C_USER/user $PG_USER);/g" expected/postgres.out > /dev/null

C_USER=`IFS="="; cat sql/postgres.sql | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR" | awk '{print $10}'`
sed -i "s/user $C_USER/user $PG_USER);/g" sql/postgres.sql > /dev/null

#-- Oracle parameters setting--
C_DBNM=`IFS="="; cat expected/oracle.out | eval $PARSECOMMAND | grep "CREATE SERVER server_oracle2" | awk '{print $10}'`
sed -i "s/dbname $C_DBNM/dbname $OR_DBNM,/g" expected/oracle.out > /dev/null

C_DBNM=`IFS="="; cat sql/oracle.sql | eval $PARSECOMMAND | grep "CREATE SERVER server_oracle2" | awk '{print $10}'`
sed -i "s/dbname $C_DBNM/dbname $OR_DBNM,/g" sql/oracle.sql > /dev/null

C_DBNM=`IFS="="; cat expected/oracle.out | eval $PARSECOMMAND | grep "CREATE SERVER server_oracle FOREIGN DATA WRAPPER oracle OPTIONS (dbname" | awk '{print $10}'`
sed -i "s/dbname $C_DBNM/dbname $OR_DBNM);/g" expected/oracle.out > /dev/null

C_DBNM=`IFS="="; cat sql/oracle.sql | eval $PARSECOMMAND | grep "CREATE SERVER server_oracle FOREIGN DATA WRAPPER oracle OPTIONS (dbname" | awk '{print $10}'`
sed -i "s/dbname $C_DBNM/dbname $OR_DBNM);/g" sql/oracle.sql > /dev/null

C_USER=`IFS="="; cat expected/oracle.out | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle2" | awk '{print $10}'`
sed -i "s/user $C_USER/user $OR_USER,/g" expected/oracle.out > /dev/null

C_USER=`IFS="="; cat sql/oracle.sql | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle2" | awk '{print $10}'`
sed -i "s/user $C_USER/user $OR_USER,/g" sql/oracle.sql > /dev/null

C_PASS=`IFS="="; cat expected/oracle.out | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle2" | awk '{print $12}'`
sed -i "s/password $C_PASS/password $OR_PASS);/g" expected/oracle.out > /dev/null

C_PASS=`IFS="="; cat sql/oracle.sql | eval $PARSECOMMAND | grep "CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle2" | awk '{print $12}'`
sed -i "s/password $C_PASS/password $OR_PASS);/g" sql/oracle.sql > /dev/null
