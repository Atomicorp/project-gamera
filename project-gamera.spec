%{?dist: %{expand: %%define %dist 1}}

Summary:        Project Gamera is a suite to create an application layer email firewall.
Name:           project-gamera
Version:        1.0
Release:        12
Epoch:		1
URL:            http://www.atomicrocketturtle.com/
Packager:	Scott R. Shinn <scott@atomicrocketturtle.com>
Source0:        project-gamera.README
Source1:	project-gamera-gpg
Source2: 	pg-master.sh
Source3: 	pg-client.sh
Source4: 	pg-clients
Source5: 	project-gamera-client.cron
Source6: 	project-gamera-master.cron
License:        GNU GPL
Group:          Applications/System
BuildRoot:      %{_tmppath}/%{name}-root
BuildArch:      noarch
Requires: perl, qmail >= 1.03-21, daemontools, tnef, unzip, perl(Time::HiRes), perl(DB_File), perl(Sys::Syslog), maildrop, spamassassin, perl-suidperl
Requires: qmail-scanner, ucspi-tcp, clamd
Requires: razor-agents, dcc, pyzor
Conflicts: psa, psa-qmail
# Obsoletes causes issues with yum update, it will install qmail/PG on a box from normal update event
#Conflicts: sendmail


%description
Project Gamera is a anti-spam/anti-virus firewall


%prep

%build

%install
%{__rm} -rf %{buildroot}
%{__mkdir_p} -m 755 %{buildroot}%{_datadir}/%{name}/
%{__mkdir_p} -m 755 %{buildroot}%{_datadir}/%{name}/data/
%{__mkdir_p} -m 755 %{buildroot}%{_datadir}/%{name}/archive/

%{__install} -m 644 %{SOURCE0}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 644 %{SOURCE1}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 755 %{SOURCE2}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 755 %{SOURCE3}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 644 %{SOURCE4}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 644 %{SOURCE5}  %{buildroot}%{_datadir}/%{name}/
%{__install} -m 644 %{SOURCE6}  %{buildroot}%{_datadir}/%{name}/



%triggerin -- spamassassin
chkconfig --add spamassassin
service spamassassin restart >/dev/null 2>&1 || :

%triggerin -- clamd
chkconfig --add clamd
service clamd restart >/dev/null 2>&1 || :


# this is problematic
#%post 
# Create GPG keys for Project Gamera Client/Server modules
#if [ ! -f /usr/share/project-gamera/pg.key ]; then
#  # Generate GPG key
#  chmod 700 /usr/share/project-gamera
#  gpg --homedir /usr/share/project-gamera/ --batch --gen-key /usr/share/project-gamera/project-gamera-gpg >/dev/null 2>&1
#  sleep 5
#  # Export public key
#  gpg --homedir /usr/share/project-gamera/ --export --keyring pg.pub -a Project > /usr/share/project-gamera/pg.key >/dev/null 2>&1
#fi



%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root)
%{_datadir}/%{name}
%config(noreplace) %{_datadir}/%{name}/pg-clients



%changelog
* Sat May 26 2007 Scott R. Shinn <scott@atomicrocketturtle.com> 1.0-10
- added PG client/server modules 
- added routine to generate a PG gpg key for use with the client/server module

* Wed Feb 21 2007 Scott R. Shinn <scott@atomicrocketturtle.com> 1.0-9
- added spamassassin trigger

* Thu Feb 9 2006 Scott R. Shinn <scott@atomicrocketturtle.com> 1.0-6
- minor tweaks to the package

* Sun May 22 2005 Scott R. Shinn <scott@atomicrocketturtle.com> 1.0-1
- initial build of the project-gamera package

