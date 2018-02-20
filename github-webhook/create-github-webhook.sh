#!/usr/bin/env bash
# this creates a github webhook that gets all events to a repository, useful with Jenkins Blue Ocean

auth_token=""
service_url=""
organisation=""
repository=""

for i in "$@"
do
case ${i} in
    -auth_token=*|--auth_token=*)
    auth_token="${i#*=}"
    ;;
    -organisation=*|--organisation=*)
    organisation="${i#*=}"
    ;;
    -service_url=*|--service_url=*)
    service_url="${i#*=}"
    ;;
    -repository=*|--repository=*)
    repository="${i#*=}"
    ;;
esac
done

git_url="https://api.github.com/repos/${organisation}/${repository}/hooks"
echo $git_url

generate_post_data()
{
  cat <<EOF
{
  "name": "web",
  "active": true,
  "events": ["*"],
  "config": {
    "url": "${service_url}/github-webhook/",
    "content_type": "application/x-www-form-urlencoded"
  }
}
EOF
}

curl -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization: token ${auth_token}" \
    --data "$(generate_post_data)" \
    ${git_url}