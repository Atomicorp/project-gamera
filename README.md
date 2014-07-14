This project is an offshoot of the original PSA qmail-scanner integration project. The intent is to create a clusterable mail server gateway that can act as a smarthost for multiple other servers, allowing you to offload the load involved in Anti-Spam or Anti-virus mail processing. This also allows you to expand Anti-Spam/Anti-Virus capabilities to other MTAs that wouldnt otherwise support it (MS Exchange, Lotus, etc).

In implementation, this is very similar to the way I did it with the original qmail-scanner project for PSA, the main difference is that I'm using a completely different implementation of qmail based on the qmail RPM created by Bruce Guenter. Project Gamera consists of an MTA (qmail for now), a secondary mail-queue using qmail-scanner, tcpserver to handle connections, spamassassin and razor to handle spam detection, clamav to handle anti-virus

Features
* Clusterable, you can create as many Gamera servers as you want, load balancing is done with MX records
* Anti-Spam protection using Spamassassin
* Anti-Spam protection using Razor (Cloudmark)
* Anti-Virus protection using ClamAV
* Per-User configurations of Spamassassin rules using an external mysql server, and a web frontend (squirrelmail)
* Per-domain configurations
* Can act as a backup mailhost
Installation
Presently only installs on a clean RH9 server have been tested. Im sure this would probably drop right in on a clean RH7.3, or Fedora 1 server (and maybe even Mandrake and SuSE).
Step 1) Install yum
And configure it to use the [gamera] channel. Make sure you disable the [atomic-psa], and [atomic-psa-unstable] channels.
Step 2) Make sure you disable the [atomic-psa], and [atomic-psa-unstable] channels. (Yes I know I said that twice)
Step 3) type: yum install qmail
Step 4) type: yum install clamav spamassassin qmail-scanner
note: dont try to combine steps 3 and 4 into one command, bugs will ensue.
Step 5) type: init q

Configuration
Basic configuration of a Gamera server is done from only 2 files
/var/qmail/control/rcpthosts - this file tells the server what domains to recieve mail for. The file lists one domain per line, example:
atomicrocketturtle.com

/var/qmail/control/smtproutes - this file tells the gamera server where to send mail it recieves for a domain. The file lists one domain, followed by a colon, followed by the hostname or IP address to send the mail for that domain to. Example:
atomicrocketturtle.com:10.10.12.1

Once those files have been configured, all you need to do is update your DNS MX records for those domains to point to your Gamera server(s). Adding multiple MX records for the domain allows you to cluster as many gamera servers as you want, and in addition in the event that the Gamera servers are not available fail over to the real mail server. Example:
atomicrocketturtle.com. IN MX 10 gamera-1.atomicrocketturtle.com.
atomicrocketturtle.com. IN MX 10 gamera-2.atomicrocketturtle.com.
atomicrocketturtle.com. IN MX 100 mail.atomicrocketturtle.com.

Advanced configuration, this is directly from the qmail-scanner documentation:

#/etc/tcpserver/smtp.rules
#
# No Qmail-Scanner at all for mail from 127.0.0.1
127.:allow,RELAYCLIENT="",RBLSMTPD="",QMAILQUEUE="/var/qmail/bin/qmail-queue"
# Use Qmail-Scanner without SpamAssassin on any mail from the local network
# [it triggers SpamAssassin via the presence of the RELAYCLIENT var]
10.:allow,RELAYCLIENT="",RBLSMTPD="",QMAILQUEUE="/var/qmail/bin/qmail-scanner-queue.pl"
#
# Use Qmail-Scanner with SpamAssassin on any mail from the rest of the world
:allow,QMAILQUEUE="/var/qmail/bin/qmail-scanner-queue.pl"

The above example means from now on all SMTP mail will be scanned, but with different characteristics. Mail from the LAN (10. network) will be scanned by the supported virus scanners, whereas mail from the Internet will be scanned for virii AND tagged by SpamAssassin. This finer control allows you a lot of versatility, e.g. virus scanning only performed on mail coming from your Exchange server, and not from your Unix servers.

By default the system is configured to scan for virii, and spam on all domains.

Per-User configurations, at present this is only available with spamassassin, first you'll need a mysql server, which can run anywhere on your network, I dont recommend running it on the gamera server itself unless you're not handling a lot of mail.
Step 1) change /etc/sysconfig/spamassassin to this:
SPAMDOPTIONS="-d -u qmailq -q -x -c -a -m30"
Step 2) change /etc/mail/spamassassin/local.cf to include these lines

user_scores_dsn                        DBI:mysql:<DATABASE>:<HOSTNAME>
user_scores_sql_username    <USERNAME>
user_scores_sql_table              <TABLENAME>
user_scores_sql_password     <PASSWORD>

Step 3) restart spamd
Now you can tie in any 3rd party front end you want to use to configure those settings, I created a squirrelmail rpm with a spamassassin plugin based on perlboy's rpm. That rpm is configured to work with a PSA server, so unless your Gamera server is pointing to your PSA server's horde database its not going to work without tweaking. 


Project Gamera Client/Server modules Installation
#################################################

pg-client.sh is intended to be dropped off on Plesk or other Project Gamera servers to allow the synchronization of data from the client(s) to the PG system automatically. This faciliates clustering, and general reduction of maintenance overhead.


Step 1) On the PG system, enter each client node in /usr/share/project-gamera/pg-clients

Step 2) On the PG system, set the nightly cron job: 
  cp /usr/share/project-gamera/project-gamera-master.cron /etc/cron.daily/

Step 3) Copy /usr/share/project-gamera/pg-client.sh to each client system to:
  /usr/share/project-gamera/pg-client.sh

Step 4) Copy /usr/share/project-gamera/project-gamera-client.cron to each client system to:
  /etc/cron.daily/

Step 5) Copy /usr/share/project-gamera/pg.key  to each client system

Step 6) Run /usr/share/project-gamera/pg-client.sh  and enter the path to the pg.key


