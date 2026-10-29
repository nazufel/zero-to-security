#!/usr/bin/env bash
# simulate-attack.sh: stage the Module 9 incident in YOUR OWN lab account.
#
#   ./simulate-attack.sh setup    create a legacy "ci-deploy" user with a long-lived key (the mistake)
#   ./simulate-attack.sh attack   use that key the way an attacker who found it would
#   ./simulate-attack.sh cleanup  delete the user, its key, and the "attacker" profile
#
# Run it only against your own account. Read every line before you run it.
set -euo pipefail

USER_NAME="ci-deploy"
PROFILE="attacker"
REGION="${AWS_REGION:-us-east-1}"

setup() {
  local account table
  account=$(aws sts get-caller-identity --query Account --output text)
  table="arn:aws:dynamodb:${REGION}:${account}:table/notes-notes"

  echo "Creating ${USER_NAME}, the kind of pipeline user Module 7 warned about..."
  aws iam create-user --user-name "$USER_NAME" > /dev/null
  aws iam put-user-policy --user-name "$USER_NAME" --policy-name legacy-deploy --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {\"Effect\": \"Allow\", \"Action\": [\"s3:ListAllMyBuckets\", \"ssm:DescribeParameters\"], \"Resource\": \"*\"},
      {\"Effect\": \"Allow\", \"Action\": [\"dynamodb:Scan\", \"dynamodb:DescribeTable\"], \"Resource\": \"${table}\"}
    ]
  }"

  echo "Creating a long-lived access key, and 'leaking' it into a local profile..."
  read -r key secret < <(aws iam create-access-key --user-name "$USER_NAME" \
    --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
  aws configure set aws_access_key_id "$key" --profile "$PROFILE"
  aws configure set aws_secret_access_key "$secret" --profile "$PROFILE"
  aws configure set region "$REGION" --profile "$PROFILE"
  echo "Done. Wait about 15 seconds for the key to work, then run: $0 attack"
}

attack() {
  echo "Attacker: who am I, and what can this key do?"
  local a="--profile $PROFILE"
  aws sts get-caller-identity $a --query Arn --output text || true
  aws iam list-users $a > /dev/null 2>&1 || echo "  iam list-users: denied"
  aws iam list-roles $a > /dev/null 2>&1 || echo "  iam list-roles: denied"
  aws secretsmanager list-secrets $a > /dev/null 2>&1 || echo "  secretsmanager list-secrets: denied"
  aws ec2 describe-instances $a > /dev/null 2>&1 || echo "  ec2 describe-instances: denied"
  aws lambda list-functions $a > /dev/null 2>&1 || echo "  lambda list-functions: denied"
  aws dynamodb list-tables $a > /dev/null 2>&1 || echo "  dynamodb list-tables: denied"
  aws s3api list-buckets $a --query 'Buckets[].Name' --output text && echo "  s3 list-buckets: ALLOWED"
  aws ssm describe-parameters $a > /dev/null 2>&1 && echo "  ssm describe-parameters: ALLOWED"
  echo "Attacker: guessing the table name from the bucket names..."
  aws dynamodb scan --table-name notes-notes $a --query 'Count' --output text && echo "  dynamodb scan notes-notes: ALLOWED. Every note copied."
  aws iam create-user --user-name backdoor $a > /dev/null 2>&1 || echo "  iam create-user backdoor: denied"
  echo "Attack finished. Now detect it, without looking at this script."
}

# Delete one [section] from an AWS config file, leaving the others
remove_section() {
  local file="$1" header="$2"
  [ -f "$file" ] || return 0
  awk -v h="$header" '$0 == h {skip = 1; next} /^\[/ {skip = 0} !skip' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

cleanup() {
  echo "Removing ${USER_NAME}, its keys, and the ${PROFILE} profile..."
  for key in $(aws iam list-access-keys --user-name "$USER_NAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    aws iam delete-access-key --user-name "$USER_NAME" --access-key-id "$key"
  done
  aws iam delete-user-policy --user-name "$USER_NAME" --policy-name legacy-deploy || true
  aws iam delete-user --user-name "$USER_NAME"
  remove_section ~/.aws/credentials "[${PROFILE}]"
  remove_section ~/.aws/config "[profile ${PROFILE}]"
  echo "Done."
}

case "${1:-}" in
  setup) setup ;;
  attack) attack ;;
  cleanup) cleanup ;;
  *) echo "Usage: $0 setup|attack|cleanup" >&2; exit 1 ;;
esac
