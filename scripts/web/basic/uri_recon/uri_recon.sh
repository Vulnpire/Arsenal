#!/bin/bash
# uri_recon.sh - Enhanced version
# Usage:
#   cat urls.txt | ./uri_recon.sh
#   ./uri_recon.sh urls.txt

set -u
set -o pipefail

OUT_DIR="${HOME}/outs"
mkdir -p "${OUT_DIR}"/{dirs,bkups,auth,sessions,apis,idor,xxe,ssti,roots,archives,rce,exposed,buckets,sqli,lfi,redirect,cors,upload,debug,secrets}

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

# Normalize once; keep both RAW and NORM
NORM_FILE="$(mktemp)"
cat "$RAW_FILE" | uro | urldedupe > "$NORM_FILE"

# Combine raw + normalized (unique)
combo() { cat "$RAW_FILE" "$NORM_FILE" | sort -u; }

# ---------------------- Sensitive Directories ---------------------------------
combo | grep -P -i '(/admin|/dashboard|/panel|/phpmyadmin|/wp-admin|/confluence|/secureadmin|/sitemanager|/drupal|/config|/myadmin|/sqladmin|/grafana|/kibana|/metrics|/backup|/zabbix|/prometheus|/splunk|/database|/phppgadmin|/ghost|/joomla|/cockpit|/manager|/login|/controlpanel|/webadmin|/admindashboard|/sysadmin|/serveradmin|/adminlogin|/superadmin|/sysconfig|/panelcontrol|/adminconsole|/vncadmin|/securelogin|/rootpanel|/webmanager|/cpanel|/plesk|/directadmin|/webmin|/portainer|/jenkins|/gitlab|/sonarqube|/nexus|/artifactory|/phpinfo|/info\.php|/test|/dev|/staging|/uat|/qa|/demo|/sandbox)(/|$|\?)' \
  | anew "${OUT_DIR}/dirs/paths.txt" \
  | notify -silent -id sensitive -d 4 -bulk

# ---------------------- Sensitive Files / Backups / Configs -------------------
combo | grep -P -i '(\.git|\.svn|\.hg|\.bzr|\.env|\.env\.|\.bak|\.backup|\.old|\.log|\.npmrc|\.conf|\.config|config\.json|\.oradata|swagger\.json|\.arc|\.env\.prod|openapi\.json|user_data\.json|webpack\.config|\.rdb|oauth\.json|private\.xml|docker-compose|kubernetes|settings\.json|\.ini|\.sql|\.dump|\.tar|xmlrpc\.php|_fragment|env\.js|\.gitlab-ci\.yml|\.cfg|\.war|\.ear|\.jar|\.sqlitedb|\.sqlite3|\.properties|\.pem|\.key|\.crt|\.csr|\.p12|\.pfx|\.der|\.jks|\.keystore|\.db|\.mdb|\.sqlite|\.accdb|\.dbf|\.tmp|\.temp|\.orig|\.save|\.swp|\.swo|~|\.yaml|\.yml|\.secret|\.token|\.credentials|\.py|\.sh|\.pl|\.rb|\.ps1|\.plist|\.dmp|\.core|\.log\.[0-9]|appsettings\.json|\.yarnrc|\.bash_history|\.zsh_history|\.bashrc|\.zshrc|\.profile|\.viminfo|\.mysql_history|\.psql_history|\.terraformrc|\.terraform|\.dockerignore|\.gitignore|\.htaccess|\.htpasswd|web\.config|\.well-known|\.aws/credentials|\.azure|\.kube|composer\.json|composer\.lock|package-lock\.json|yarn\.lock|Gemfile\.lock|Pipfile\.lock|poetry\.lock|thumbs\.db|\.DS_Store|WEB-INF|META-INF|crossdomain\.xml|clientaccesspolicy\.xml|\.idea|\.vscode|\.vs|id_rsa|id_dsa|\.pub)' \
  | anew "${OUT_DIR}/bkups/sensitive_files.txt" \
  | notify -silent -id extensions -d 4 -bulk

# ---------------------- Dependency Confusion ---------------------------------
combo | grep -P -i '(^|/)(packages?\.json|package-lock\.json|composer\.json|Gemfile|requirements\.txt|go\.mod|pom\.xml|build\.gradle)(?=($|[/?#]))' \
  | anew packages.txt \
  | HexDox -c=10 2>/dev/null \
  | notify -silent -id depconf -bulk -d 2

# ---------------------- Auth / Session endpoints ------------------------------
combo | grep -P -i '(/login|/logout|/signin|/signout|/signup|/register|/auth|/oauth|/sso|/saml|/forgot|/reset|/change-password|/password|/session|/authenticate|/token|/refresh|/verify|/mfa|/2fa)(/|$|\?)' \
  | anew "${OUT_DIR}/auth/authentication.txt" \
  | notify -silent -id auth -d 4 -bulk

# ---------------------- Session params (JWT/CSRF/etc.) ------------------------
combo | grep -P -i '(\?|&)(token|auth|authorization|bearer|session|sessid|sid|csrf|xsrf|_csrf|authenticity_token|state|nonce|access_token|refresh_token|id_token|api_key|apikey|key|secret|ey[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)=' \
  | anew "${OUT_DIR}/sessions/session_management.txt" \
  | notify -silent -id sessions -d 4 -bulk

# ---------------------- API Enumeration --------------------------------------
combo | grep -P -i '(/api(/v[0-9]+)?/|/rest/|/graphql|/gql|/swagger|/openapi|/internal/|/private/|/v[0-9]+/|/ws/|/webhooks?/|/rpc|/jsonrpc)' \
  | anew "${OUT_DIR}/apis/api_enum.txt" \
  | notify -silent -id apis -d 4 -bulk

# API with numeric IDs or UUIDs
combo | grep -P -i '/api(/v[0-9]+)?/[a-z_-]+/([0-9]+|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})' \
  | anew "${OUT_DIR}/apis/api_with_ids.txt" \
  | notify -silent -id apis -d 4 -bulk

# ---------------------- Root Dirs (first 5 segments) --------------------------
cat "$NORM_FILE" \
  | grep -oP '^https?://(?:[^/]*/){1,5}' \
  | sort -u \
  | grep -P -vi 'www\.|forum|docs|assets|about|blog|news|help|support|cdn\.|static\.' \
  | anew "${OUT_DIR}/roots/roots.txt" \
  | httpx -random-agent -mc 200,201,204,301,302,307,401,403 -threads 300 -silent 2>/dev/null \
  | notify -silent -id roots -d 4 -bulk

# ---------------------- Archives ---------------------------------------------
combo \
  | grep -P -i '\.(zip|tar|tar\.gz|tgz|gz|bz2|xz|7z|rar|zst|lz|lzma|cab|apk|ipa|deb|rpm|pkg|dmg|iso|img|vhd|vmdk|ova|cpio|ar|sqsh|sfs|bin|exe|msi|dll)(?=($|[/?#]))' \
  | grep -P -vi 'dropbox|googledrive|onedrive|box\.com|mediafire|mega\.nz|wetransfer|downloads|updates|release|releases|installers|setup|mirror|cdn\.|pypi|npm|rubygems|cpan|cran|maven|nuget|apt|yum|dnf|backup|backups|old|temp|tmp|cache|github|gitlab|bitbucket|sourceforge|apache\.org' \
  | anew "${OUT_DIR}/archives/archive_files.txt" \
  | httpx -mc 200 -random-agent -threads 300 -silent 2>/dev/null \
  | notify -silent -id archives -d 4 -bulk

# ---------------------- Cloud Storage Buckets ---------------------------------
# S3 buckets
combo | grep -P -i '(s3[.-]|\.s3[.-]|\.s3\.)(amazonaws\.com|amazonaws\.com\.[a-z]{2}|eu|us|ap|sa|ca)' \
  | anew "${OUT_DIR}/buckets/s3_buckets.txt" \
  | notify -silent -id s3buckets -d 4 -bulk

# Azure Blob Storage
combo | grep -P -i '\.blob\.core\.windows\.net' \
  | anew "${OUT_DIR}/buckets/azure_blobs.txt" \
  | notify -silent -id azureblobs -d 4 -bulk

# Google Cloud Storage
combo | grep -P -i '(storage\.googleapis\.com|\.storage\.googleapis\.com|storage\.cloud\.google\.com)' \
  | anew "${OUT_DIR}/buckets/gcs_buckets.txt" \
  | notify -silent -id gcsbuckets -d 4 -bulk

# ---------------------- Internal / Localhost ---------------------------------
combo | grep -P -i '(localhost|127\.0\.0\.|::1|0\.0\.0\.0|10\.[0-9]{1,3}\.[0-9]{1,3}\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|internal|\.local|\.internal)' \
  | anew "${OUT_DIR}/exposed/internal.txt" \
  | notify -silent -id internal -d 4 -bulk

# ---------------------- IDOR candidates --------------------------------------
combo | grep -P -i '(\?|&)(id|user_?id|account_?id|customer_?id|order_?id|invoice_?id|project_?id|ticket_?id|uid|doc_?id|file_?id|object_?id|resource_?id|profile_?id|post_?id|comment_?id|message_?id|transaction_?id|payment_?id|uuid|guid)=([0-9]{1,10}|[A-Za-z0-9_-]{6,})' \
  | anew "${OUT_DIR}/idor/idor_candidates.txt" \
  | notify -silent -id idor -d 4 -bulk

# ---------------------- SQL Injection candidates ------------------------------
# Common SQL-injectable parameters
combo | grep -P -i '(\?|&)(id|user|username|email|search|query|keyword|q|s|filter|sort|order|category|cat|page|limit|offset|year|month|day|date|product|item|article|post|comment|name|type|status|role|group|lang|language|country|region|city)=' \
  | anew "${OUT_DIR}/sqli/sqli_candidates.txt" \
  | notify -silent -id sqli -d 4 -bulk

# SQL error indicators in URLs (for testing responses)
combo | grep -P -i "(sql|mysql|mssql|postgres|oracle|sqlite|syntax|error|warning|exception)" \
  | anew "${OUT_DIR}/sqli/sqli_error_hints.txt"

# ---------------------- LFI/Path Traversal candidates -------------------------
combo | grep -P -i '(\?|&)(file|document|folder|root|path|pg|style|template|php_path|doc|page|name|cat|dir|action|board|date|detail|download|prefix|include|inc|locate|show|site|type|view|content|layout|mod|conf)=' \
  | anew "${OUT_DIR}/lfi/lfi_candidates.txt" \
  | notify -silent -id lfi -d 4 -bulk

# Obvious path traversal patterns
combo | grep -P -i '(\.\.\/|\.\.\\|%2e%2e%2f|%2e%2e%5c|\.\.%252f|\.\.%255c)' \
  | anew "${OUT_DIR}/lfi/path_traversal.txt" \
  | notify -silent -id lfi -d 4 -bulk

# ---------------------- Open Redirect candidates ------------------------------
combo | grep -P -i '(\?|&)(redirect|url|uri|return|returnTo|return_to|returnurl|redirect_uri|redirect_url|next|continue|dest|destination|goto|target|rurl|link|location|out|view|to|file|val|validate|domain|callback|r|page)=' \
  | anew "${OUT_DIR}/redirect/redirect_candidates.txt" \
  | notify -silent -id redirect -d 4 -bulk

# ---------------------- CORS/Origin-related -----------------------------------
combo | grep -P -i '(\?|&)(origin|callback|jsonp|cors)=' \
  | anew "${OUT_DIR}/cors/cors_candidates.txt" \
  | notify -silent -id cors -d 4 -bulk

# ---------------------- File Upload endpoints ---------------------------------
combo | grep -P -i '(/upload|/uploads|/file|/files|/media|/attachment|/attachments|/avatar|/photo|/image|/images|/picture|/document|/documents)(/|$|\?)' \
  | anew "${OUT_DIR}/upload/upload_endpoints.txt" \
  | notify -silent -id upload -d 4 -bulk

combo | grep -P -i '(\?|&)(upload|file|attachment|avatar|photo|image|document|media)=' \
  | anew "${OUT_DIR}/upload/upload_params.txt" \
  | notify -silent -id upload -d 4 -bulk

# ---------------------- Debug/Development endpoints ---------------------------
combo | grep -P -i '(/debug|/trace|/console|/test|/dev|/development|/staging|/phpinfo|/info|/health|/status|/metrics|/actuator|/jolokia|/env|/dump|/heapdump|/threaddump|/trace|/loggers|/auditevents|/httptrace)(/|$|\?)' \
  | anew "${OUT_DIR}/debug/debug_endpoints.txt" \
  | notify -silent -id debug -d 4 -bulk

# Debug parameters
combo | grep -P -i '(\?|&)(debug|test|dev|trace|verbose|_debug|__debug)=(1|true|yes|on)' \
  | anew "${OUT_DIR}/debug/debug_params.txt" \
  | notify -silent -id debug -d 4 -bulk

# ---------------------- Secrets in URLs ---------------------------------------
# API keys, tokens, passwords in URLs
combo | grep -P -i '(\?|&)(api_?key|apikey|key|secret|password|passwd|pwd|token|auth|access_?token|client_?secret|private_?key)=[^&]{6,}' \
  | anew "${OUT_DIR}/secrets/secrets_in_urls.txt" \
  | notify -silent -id secrets -d 4 -bulk

# Potential JWT tokens in URLs
combo | grep -P 'ey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' \
  | anew "${OUT_DIR}/secrets/jwt_tokens.txt" \
  | notify -silent -id jwttokens -d 4 -bulk

# ---------------------- XXE candidates ---------------------------------------
combo | grep -P -i '(\.xml|\.wsdl|\.xsd|\.dtd|\.plist|\.svg|\.rss|\.atom|\.xhtml|\.xsl|\.xslt)(?=($|[/?#]))' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

combo | grep -P -i '(/xml|/api/xml|/rest/xml|/xmlrpc|/soap|/services|/ws)(/|$|\?|wsdl)' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

combo | grep -P -i '(\?|&)(format|type|accept|contenttype|content-type)=(xml|text%2Fxml|application%2Fxml)' \
  | anew "${OUT_DIR}/xxe/xxe_candidates.txt" \
  | notify -silent -id xxe -d 4 -bulk

# Live probe for XML content-types
if command -v httpx &> /dev/null; then
  cat "${OUT_DIR}/xxe/xxe_candidates.txt" 2>/dev/null \
    | sort -u \
    | httpx -silent -random-agent -mc 200 -content-type -threads 100 2>/dev/null \
    | grep -i '\[.*xml' \
    | anew "${OUT_DIR}/xxe/xxe_candidates_live.txt" \
    | notify -silent -id xxe -d 4 -bulk
fi

# ---------------------- SSTI candidates --------------------------------------
combo | grep -P -i '(\{\{.*\}\}|\{\%.*\%\}|%7B%7B|%7D%7D|%7B%25|%25%7D|\$\{.*\})' \
  | anew "${OUT_DIR}/ssti/ssti_candidates.txt" \
  | notify -silent -id ssti -d 4 -bulk

# Template-related parameters
combo | grep -P -i '(\?|&)(template|tmpl|view|layout|theme|skin|page|content)=' \
  | anew "${OUT_DIR}/ssti/ssti_param_candidates.txt" \
  | notify -silent -id ssti -d 4 -bulk

# ---------------------- RCE-ish parameters -----------------------------------
combo | grep -P -i '(\?|&)(cmd|exec|execute|command|shell|daemon|run|ping|host|ip|addr|system|proc|process|function|func|method|code|eval|assert|call)=' \
  | anew "${OUT_DIR}/rce/rce_candidates.txt" \
  | notify -silent -id rce -d 4 -bulk

# ---------------------- GraphQL endpoints ------------------------------------
combo | grep -P -i '(/graphql|/graphiql|/gql|/api/graphql|/v[0-9]+/graphql|/query|/api/query)(/|$|\?)' \
  | anew "${OUT_DIR}/apis/graphql_endpoints.txt" \
  | notify -silent -id graphql -d 4 -bulk

# ---------------------- Interesting extensions --------------------------------
combo | grep -P -i '\.(jsp|jsf|asp|aspx|php|php[3-8]|cfm|cgi|pl|py|rb|do|action|jspx)(?=($|[/?#]))' \
  | anew "${OUT_DIR}/bkups/interesting_extensions.txt" \
  | notify -silent -id extensions -d 4 -bulk

# ---------------------- Status summary ----------------------------------------
echo "[+] Reconnaissance complete. Results saved to: ${OUT_DIR}"
echo "[+] Run 'find ${OUT_DIR} -type f -exec wc -l {} +' to see counts"

# ---------------------- Cleanup ----------------------------------------------
rm -f "$RAW_FILE" "$NORM_FILE"
