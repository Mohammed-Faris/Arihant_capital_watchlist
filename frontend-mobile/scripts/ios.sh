#!/bin/bash

flavor=$1
appSub=`echo $flavor| tr [a-z] [A-Z]`
RELEASE_NOTES=$2
AppNameIos=$4
DISTRIBUTION_GROUP="3e289891-d1a9-417e-b63e-4a418909f53b" # QA Team Destination
NOTIFY=$3
echo "notifiying to user $3" ;
AUTH="X-API-Token: 6941f1ad0281c85b114f9f623fcd463ff1fe498d"
file_name=acml.ipa
CONTENT_TYPE="application/octet-stream"
APPCENTER_OUTPUT_DIRECTORY="."
UPLOAD_DOMAIN="https://file.appcenter.ms/upload"
API_URL="https://api.appcenter.ms/v0.1/apps/Arihant-Cap/$AppNameIos"
ACCEPT_JSON="Accept: application/json"
APP_PACKAGE=$1
# Body - Step 1/7
request_url="$API_URL/uploads/releases"
upload_json=$(curl -s -X POST -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" "$request_url")
releases_id=$(echo $upload_json | jq -r '.id')
package_asset_id=$(echo $upload_json | jq -r '.package_asset_id')
url_encoded_token=$(echo $upload_json | jq -r '.url_encoded_token')
RELEASE_FILE_LOCATION="$5/acml.ipa"
echo $RELEASE_FILE_LOCATION
file_size=$(wc -c $RELEASE_FILE_LOCATION | awk '{print $1}')
echo $file_size
for filename in *.ipa; do
    test -d "$filename" && app_files=1
done
# Step 2/7
metadata_url="$UPLOAD_DOMAIN/set_metadata/$package_asset_id?file_name=$file_name&file_size=$file_size&token=$url_encoded_token&content_type=$CONTENT_TYPE"
meta_response=$(curl -s -d POST -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" "$metadata_url")
printf "I ${RED}$meta_response\n${NC}"

chunk_size=$(echo $meta_response | jq -r '.chunk_size')


split_dir=$APPCENTER_OUTPUT_DIRECTORY/split-dir
mkdir -p $split_dir
eval split -b $chunk_size $RELEASE_FILE_LOCATION $split_dir/split

echo uploading
# Step 3/7
binary_upload_url="$UPLOAD_DOMAIN/upload_chunk/$package_asset_id?token=$url_encoded_token"

block_number=1
for i in $split_dir/*
do
    url="$binary_upload_url&block_number=$block_number"
    size=$(wc -c $i | awk '{print $1}')
    curl -X POST $url --data-binary "@$i" -H "Content-Length: $size" -H "Content-Type: $CONTENT_TYPE"
    block_number=$(($block_number + 1))
done

# Step 4/7
finish_url="$UPLOAD_DOMAIN/finished/$package_asset_id?token=$url_encoded_token"
curl -d POST -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" "$finish_url"

# Step 5/7
commit_url="$API_URL/uploads/releases/$releases_id"
curl -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" \
  --data '{"upload_status": "uploadFinished","id": "$releases_id"}' \
  -X PATCH \
  $commit_url

# Step 6/7
release_id=null
counter=0
max_poll_attempts=15

while [[ $release_id == null && ($counter -lt $max_poll_attempts)]]
do
    poll_result=$(curl -s -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" $commit_url)
    release_id=$(echo $poll_result | jq -r '.release_distinct_id')
    counter=$((counter + 1))
    sleep 3
done

if [[ $release_id == null ]];
then
    echo "Failed to find release ios $flavor from appcenter"
    exit 1
fi

# Step 7/7
distribute_url="$API_URL/releases/$release_id"
curl -H "Content-Type: application/json" -H "$ACCEPT_JSON" -H "$AUTH" \
  --data '{"destinations": [{ "id": "'"$DISTRIBUTION_GROUP"'"}], "notify_testers": '"$NOTIFY"', "release_notes": "'"$RELEASE_NOTES"'" }' \
  -X PATCH \
  $distribute_url
echo " $flavor IOS released to  appcenter"
