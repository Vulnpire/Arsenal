#!/bin/bash

mkdir -p ~/outs/dirs
mkdir -p ~/outs/bkups
mkdir -p ~/outs/auth
mkdir -p ~/outs/sessions
mkdir -p ~/outs/apis
mkdir -p ~/outs/idor
mkdir -p ~/outs/xxe
mkdir -p ~/outs/ssti
mkdir -p ~/outs/roots
mkdir -p ~/outs/archives
mkdir -p ~/outs/rce
mkdir -p ~/outs/exposed
mkdir -p ~/outs/buckets

# Sensitive Files and Directories
uro | urldedupe | grep -Ei "/admin/|/dashboard/|/panel/|/phpmyadmin/|/wp-admin/|/confluence/|/secureadmin/|/sitemanager/|/drupal/|/config/|/myadmin/|/sqladmin/|/grafana/|/kibana/|/metrics/|/backup/|/zabbix/|/prometheus/|/splunk/|/database/|/phppgadmin/|/ghost/|/joomla/|/cockpit/|/manager/|/login/|/controlpanel/|/webadmin/|/admindashboard/|/sysadmin/|/serveradmin/|/adminlogin/|/superadmin/|/sysconfig/|/panelcontrol/|/adminconsole/|/vncadmin/|/securelogin/|/rootpanel/|/webmanager/" |
  anew ~/outs/dirs/paths.txt | notify -id sensitive -d 4 -bulk

# Common backup, logs, and configuration files, vulnerable endpoints
grep -Ei "(\.git|\.svn|\.env|\.bak|\.old|\.log|\.npmrc|\.conf|\.config|config\.json|\.oradata|swagger\.json|\.arc|\.env\.prod|openapi\.json|user_data\.json|webpack\.config\.json|\.rdb|oauth\.json|private\.xml|docker-compose\.json|kubernetes\.json|settings\.json|\.ini|\.sql|\.dump|xmlrpc\.php|_fragment|env.js|\.gitlab-ci\.yml|\.cfg|\.war|\.ear|\.sqlitedb|\.sqlite3|\.properties|\.pem|\.key|\.crt|\.csr|\.p12|\.pfx|\.der|\.db|\.mdb|\.sqlite|\.accdb|\.dbf|\.tmp|\.temp|\.orig|\.save|\.yaml|\.yml|\.cfg|\.secret|\.token|\.py|\.sh|\.pl|\.rb|\.ps1|\.plist|\.dmp|\.core|\.log\.1|appsettins\.json|\.yarnrc|\.bash_history|\.zsh_history|\.bashrc|\.zshrc|\.terraformrc|\.dockerignore|\.gitignore|composer\.json|composer\.lock|thumbs\.db)$" |
  anew ~/outs/bkups/sensitive_files.txt | notify -id extensions -d 4 -bulk

# Dependency Confusion
grep -Ei "(/|^)packages\.json|(/|^)package\.json" |
  anew packages.txt | HexDox -c=10 | notify -id recon-${NOTIFY_ID} -bulk -d 2

# Auth/session endpoints
uro | urldedupe | grep -Ei "^/(login|logout|signin|signup|register|forgot(?:-password)?|reset(?:-password)?|change-password|session)$" |
  anew ~/outs/auth/authentication.txt | notify -id auth -d 4 -bulk

# Session management params
uro | urldedupe | grep -Ei "\?(token|auth|session|sid|csrf|xsrf|ey[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)" |
  anew ~/outs/sessions/session_management.txt | notify -id sessions -d 4 -bulk

# API Enumeration
uro | urldedupe | grep -Ei "/api/v[1-3]/[a-z]+/[0-9]+|/api/[0-9]+/[a-z]+/[0-9]+|/v[0-9]+/[a-z]+/[0-9]+|/rest/|/graphql|/swagger/|/internal/" |
  anew ~/outs/apis/api_enum.txt | notify -id apis -bulk -d 4

# Root Dirs
uro | urldedupe | grep -ioP "^https?://(?:[^/]*/){5}" | sort -u |
  grep -Evi "www|forum|docs|assets|about" |
  anew ~/outs/roots/roots.txt | httpx -random-agent -mc 200 -threads 300 |
  notify -id roots -d 4 -bulk

# Archive files
uro | urldedupe | grep -Ei "\.(zip|tar|tar\.gz|tgz|gz|bz2|xz|7z|rar|zst|lz|lzma|cab|apk|deb|rpm|pkg|cpio|ar|sqsh|sfs|bin)$" |
  grep -Evi "dropbox|googledrive|onedrive|box.com|mediafire|mega.nz|wetransfer|downloads|updates|release|releases|installers|setup|mirror|cdn|pypi|npm|rubygems|cpan|cran|maven|nuget|apt|yum|dnf|backup|backups|old|temp|tmp|cache|github|gitlab|bitbucket|sourceforge|apache.org" |
  anew ~/outs/archives/archive_files.txt | httpx -mc 200 -random-agent -threads 300 |
  notify -id archives -d 4 -bulk

# New Check: S3 Buckets
uro | urldedupe | grep -Ei "s3[.-]amazonaws.com|\.s3\.amazonaws\.com|s3\.eu|s3\.us|\.s3\.([a-z0-9-]+)\.amazonaws\.com" |
  anew ~/outs/buckets/s3_buckets.txt | notify -id s3buckets -d 4 -bulk

# New Check: Localhost/exposed dev services
uro | urldedupe | grep -Ei "localhost|127\.0\.0\.1|::1|0\.0\.0\.0|internal" |
  anew ~/outs/exposed/internal.txt | notify -id internal -d 4 -bulk
