# SPEC file for dblink_plus
# Copyright(C) 2019 NIPPON TELEGRAPH AND TELEPHONE CORPORATION

%define _pgdir   /usr/pgsql-11
%define _bindir  %{_pgdir}/bin
%define _libdir  %{_pgdir}/lib
%define _datadir %{_pgdir}/share/extension
%define _bcdir %{_libdir}/bitcode/dblink_plus
%define _bc_ind_dir %{_libdir}/bitcode

## Set general information
Summary:    PostgreSQL module to connect PostgreSQL/Oracle
Name:       dblink_plus
Version:    1.0.3
Release:    1%{?dist}
License:    BSD
Group:      Applications/Databases
Source0:    %{name}-%{version}.tar.gz
URL:        https://github.com/ossc-db/dblink_plus
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Vendor:     NIPPON TELEGRAPH AND TELEPHONE CORPORATION
#Following is needed to remove auto-discovery of oci library files(not under RPM package management)
AutoReqProv: no

## We use postgresql-devel package
BuildRequires:  postgresql11-devel
Requires:  postgresql11-libs

## Description
%description
dblink_plus is a PostgreSQL module which supports connections to other databases.
It is similar to contrib/dblink except that it can connect to Oracle, MySQL and sqlite3. 

Note that this package is available for only PostgreSQL 11.

%package llvmjit
Requires: postgresql11-server, postgresql11-llvmjit
Requires: dblink_plus = 1.0.3
Summary:  Just-in-time compilation support for dblink_plus

%description llvmjit
Just-in-time compilation support for dblink_plus 1.0.3

## prework
%prep
%setup -q -n %{name}-%{version}

## Set variables for build environment
%build
USE_PGXS=1 make %{?_smp_mflags} MYSQL=0 SQLITE3=0 ORACLE=1

## Set variables for install
%install
rm -rf %{buildroot}

install -d %{buildroot}%{_libdir}
install -m 755 dblink_plus.so %{buildroot}%{_libdir}/dblink_plus.so
install -d %{buildroot}%{_datadir}
install -m 755 dblink_plus.sql %{buildroot}%{_datadir}/dblink_plus.sql
install -m 755 dblink_plus--1.0.3.sql %{buildroot}%{_datadir}/dblink_plus--1.0.3.sql
install -m 755 dblink_plus.control %{buildroot}%{_datadir}/dblink_plus.control
install -m 755 uninstall_dblink_plus.sql %{buildroot}%{_datadir}/uninstall_dblink_plus.sql
install -m 755 COPYRIGHT %{buildroot}%{_datadir}/COPYRIGHT_dblink_plus
install -d %{buildroot}%{_bcdir}
install -m 644 dblink.bc %{buildroot}%{_bcdir}/dblink.bc
install -m 644 dblink_postgres.bc %{buildroot}%{_bcdir}/dblink_postgres.bc
install -m 644 dblink_plus.index.bc %{buildroot}%{_bc_ind_dir}/dblink_plus.index.bc

%clean
#rm -rf %{buildroot}

%files
%defattr(755,root,root)
%{_libdir}/dblink_plus.so
%{_datadir}/dblink_plus.sql
%{_datadir}/dblink_plus--1.0.3.sql
%{_datadir}/dblink_plus.control
%{_datadir}/uninstall_dblink_plus.sql
%{_datadir}/COPYRIGHT_dblink_plus

%files llvmjit
%defattr(0755,root,root)
%{_bcdir}
%defattr(0644,root,root)
%{_bcdir}/dblink.bc
%defattr(0644,root,root)
%{_bcdir}/dblink_postgres.bc
%defattr(0644,root,root)
%{_bc_ind_dir}/dblink_plus.index.bc

# History.
%changelog
* Thu Jan 10 2019 - NTT OSS Center <tatsuro.yamada@lab.ntt.co.jp> 1.0.3-1
Support PG11.
