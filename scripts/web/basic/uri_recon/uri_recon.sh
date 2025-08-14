#!/bin/bash
# uri_recon.sh
# Usage:
#   cat urls.txt | ./uri_recon.sh
#   ./uri_recon.sh urls.txt

set -u
set -o pipefail

OUT_DIR="${HOME}/outs"
mkdir -p "${OUT_DIR}"/{dirs,bkups,auth,sessions,apis,idor,xxe,ssti,roots,archives,rce,exposed,buckets}

# ---------------------- Input handling ----------------------------------------
RAW_FILE="$(mktemp)"
if [ $# -ge 1 ] && [ -f "${1:-}" ]; then
  cat "$1" > "$RAW_FILE"
elif [ -t 0 ]; then
  echo "Usage: cat urls.txt | $0  OR  $0 urls.txt" >&2
  exit 1
else
  cat - > "$RAW_FILE"
fi

# Normalize once; keep both RAW and NORM (sometimes normalization drops odd paths)
NORM_FILE="$(mktemp)"
cat "$RAW_FILE" | uro | urldedupe > "$NORM_FILE"

# Combine raw + normalized (unique)
combo() { cat "$RAW_FILE" "$NORM_FILE" | sort -u; }

# ---------------------- Sensitive Directories ---------------------------------
combo | grep -P -i '(/admin/|/dashboard/|/panel/|/phpmyadmin/|/wp-admin/|/confluence/|/secureadmin/|/sitemanager/|/drupal/|/config/|/myadmin/|/sqladmin/|/grafana/|/kibana/|/metrics/|/backup/|/zabbix/|/prometheus/|/splunk/|/database/|/phppgadmin/|/ghost/|/joomla/|/cockpit/|/manager/|/login/|/controlpanel/|/webadmin/|/admindashboard/|/sysadmin/|/serveradmin/|/adminlogin/|/superadmin/|/sysconfig/|/panelcontrol/|/adminconsole/|/vncadmin/|/securelogin/|/rootpanel/|/webmanager/)' \
  | anew "${OUT_DIR}/dirs/paths.txt" \
  | notify -silent -id sensitive -d 4 -bulk

# ---------------------- Sensitive Files / Backups / Configs -------------------
# Matches anywhere (no end anchor). Kept your full original list + fixed escapes.
combo | grep -P -i '(\.git|\.svn|\.env|\.bak|\.old|\.log|\.npmrc|\.conf|\.config|config\.json|\.oradata|swagger\.json|\.arc|\.env\.prod|openapi\.json|user_data\.json|webpack\.config\.json|\.rdb|oauth\.json|private\.xml|docker-compose\.json|kubernetes\.json|settings\.json|\.ini|\.sql|\.dump|xmlrpc\.php|_fragment|env\.js|\.gitlab-ci\.yml|\.cfg|\.war|\.ear|\.sqlitedb|\.sqlite3|\.properties|\.pem|\.key|\.crt|\.csr|\.p12|\.pfx|\.der|\.db|\.mdb|\.sqlite|\.accdb|\.dbf|\.tmp|\.temp|\.orig|\.save|\.yaml|\.yml|\.cfg|\.secret|\.token|\.py|\.sh|\.pl|\.rb|\.ps1|\.plist|\.dmp|\.core|\.log\.1|appsettins\.json|\.yarnrc|\.bash_history|\.zsh_history|\.bashrc|\.zshrc|\.terraformrc|\.dockerignore|\.gitignore|composer\.json|composer\.lock|thumbs\.db)' \
  | anew "${OUT_DIR}/bkups/sensitive_files.txt" \
  | notify -silent -id extensions -d 4 -bulk

# ---------------------- Dependency Confusion ---------------------------------
combo | grep -P -i '(^|/)(packages\.json|package\.json)(?=($|[/?#]))' \
  | anew packages.txt \
  | HexDox -c=10 \
  | notify -silent -id "recon-${NOTIFY_ID:-depconf}" -bulk -d 2

# ---------------------- Auth / Session endpoints ------------------------------
combo | grep -P -i '(/login|/logout|/signin|/signup|/register|/forgot(?:-password)?|/reset(?:-password)?|/change-password|/session)(?=($|[/?#]))' \
  | anew "${OUT_DIR}/auth/authentication.txt" \
  | notify -silent -id auth -d 4 -bulk

# ---------------------- Session params (JWT/CSRF/etc.) ------------------------
combo | grep -P -i '\?(token|auth|session|sid|csrf|xsrf|ey[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)' \
  | anew "${OUT_DIR}/sessions/session_management.txt" \
  | notify -silent -id sessions -d 4 -bulk

# ---------------------- API Enumeration --------------------------------------
combo | grep -P -i '(/api/v[1-3]/[a-z]+/[0-9]+|/api/[0-9]+/[a-z]+/[0-9]+|/v[0-9]+/[a-z]+/[0-9]+|/rest/|/graphql|/swagger/|/internal/)' \
  | anew "${OUT_DIR}/apis/api_enum.txt" \
  | notify -silent -id apis -d 4 -bulk

# ---------------------- Root Dirs (first 5 segments) --------------------------
# Use normalized list for correctness of scheme/host.
cat "$NORM_FILE" \
  | grep -oP '^https?://(?:[^/]*/){5}' \
  | sort -u \
  | grep -P -vi 'www|forum|docs|assets|about' \
  | anew "${OUT_DIR}/roots/roots.txt" \
  | httpx -random-agent -mc 200 -threads 300 \
  | notify -silent -id roots -d 4 -bulk

# ---------------------- Archives ---------------------------------------------
combo \
  | grep -P -i '\.(zip|tar|tar\.gz|tgz|gz|bz2|xz|7z|rar|zst|lz|lzma|cab|apk|deb|rpm|pkg|cpio|ar|sqsh|sfs|bin)(?=($|[/?#]))' \
  | grep -P -vi 'dropbox|googledrive|onedrive|box\.com|mediafire|mega\.nz|wetransfer|downloads|updates|release|releases|installers|setup|mirror|cdn|pypi|npm|rubygems|cpan|cran|maven|nuget|apt|yum|dnf|backup|backups|old|temp|tmp|cache|github|gitlab|bitbucket|sourceforge|apache\.org' \
  | anew "${OUT_DIR}/archives/archive_files.txt" \
  | httpx -mc 200 -random-agent -threads 300 \
  | notify -silent -id archives -d 4 -bulk

# ---------------------- S3 Buckets -------------------------------------------
combo | grep -P -i '(s3[.-]amazonaws\.com|\.s3\.amazonaws\.com|s3\.eu|s3\.us|\.s3\.[a-z0-9-]+\.amazonaws\.com)' \
  | anew "${OUT_DIR}/buckets/s3_buckets.txt" \
  | notify -silent -id s3buckets -d 4 -bulk

# ---------------------- Internal / Localhost ---------------------------------
combo | grep -P -i '(localhost|127\.0\.0\.1|::1|0\.0\.0\.0|internal)' \
  | anew "${OUT_DIR}/exposed/internal.txt" \
  | notify -silent -id internal -d 4 -bulk

# ---------------------- IDOR candidates --------------------------------------
# Common object-id-ish params (digits or simple tokens). Heuristic, not definitive.
combo | grep -P -i '(\?|&)(id|user_id|userid|account_id|accountId|customerId|orderId|invoiceId|projectId|ticketId|uid|doc_id|file_id|object_id|resource_id)=(?:[0-9]{1,10}|[A-Za-z0-9_-]{6,})' \
  | anew "${OUT_DIR}/idor/idor_candidates.txt" \
  | notify -silent -id idor -d 4 -bulk

# ---------------------- XXE candidates ---------------------------------------
# URL-based indicators for XML/SOAP/WSDL/XSD/DTD endpoints and XML content.
# 1) File extensions likely parsed as XML
combo | grep -P -i '(\.xml|\.wsdl|\.xsd|\.dtd|\.plist|\.svg)(?=($|[/?#]))' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

# 2) Paths that suggest XML or SOAP usage
combo | grep -P -i '(/xml/|/api/xml|/rest/xml|/xmlrpc|/soap|/services\?wsdl|[?&]wsdl(=|$))' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

# 3) Query hints for XML response/content-type (raw or URL-encoded)
combo | grep -P -i '([?&](format|type|accept|contenttype)=(xml|text%2Fxml|application%2Fxml))' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

# 4) OPTIONAL live probe: confirm XML-ish content-types
#    Comment out if you prefer offline only.
cat "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | sort -u \
  | httpx -silent -random-agent -mc 200 -content-type \
  | grep -i '\[.*xml' \
  | anew "${OUT_DIR}/xxe/xxe_candidates_live.txt" \
  | notify -silent -id xxe -d 4 -bulk

# ---------------------- SSTI candidates --------------------------------------
combo | grep -P -i '(\{\{.*\}\}|\{\%.*\%\}|%7B%7B|%7D%7D|%7B%25|%25%7D)' \
  | anew "${OUT_DIR}/ssti/ssti_candidates.txt" \
  | notify -silent -id ssti -d 4 -bulk

# ---------------------- RCE-ish parameters -----------------------------------
combo | grep -P -i '(\?|&)(cmd|exec|execute|shell|command|daemon|run|proc|process)=' \
  | anew "${OUT_DIR}/rce/rce_candidates.txt" \
  | notify -silent -id rce -d 4 -bulk

# ---------------------- Cleanup ----------------------------------------------
rm -f "$RAW_FILE" "$NORM_FILE"
