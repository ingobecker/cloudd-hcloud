#!/bin/sh
set -e

eval "$(jq -r '@sh "API_TOKEN=\(.api_token) SERVER_ID=\(.server_id) SNAP_NAME=\(.snap_name)"')"

function server_off(){

  local api_token=$1
  local server_id=$2

  curl -s -H "Authorization: Bearer $api_token" \
	  "https://api.hetzner.cloud/v1/servers/$server_id" \
	  | grep -q \"status\"\:\ \"off\",
  return $?
}

function create_snapshot(){

  local api_token=$1
  local server_id=$2
  local snap_name=$3

  curl -s -X POST -H "Content-Type: application/json" \
       -H "Authorization: Bearer $api_token" \
       -d "{\"description\": \"${snap_name}\", \"type\": \"snapshot\", \"labels\":{\"image_name\":\"${snap_name}\"}}" \
       "https://api.hetzner.cloud/v1/servers/${server_id}/actions/create_image" \
       | jq '.image.id'
}

function get_snapshot(){

  local api_token=$1
  local snap_name=$2

  curl -H "Authorization: Bearer $api_token" \
       "https://api.hetzner.cloud/v1/images?type=snapshot&label_selector=image_name=$snap_name"
}

SNAPSHOTS=$(get_snapshot $API_TOKEN $SNAP_NAME)
SNAPSHOT_COUNT=$(echo $SNAPSHOTS | jq '.images | length')

if [ "$SNAPSHOT_COUNT" -lt "1" ]
then

  until server_off $API_TOKEN $SERVER_ID
  do
    sleep 10s
  done

  IMAGE_ID=$(create_snapshot $API_TOKEN $SERVER_ID $SNAP_NAME)
else
  IMAGE_ID=$(echo $SNAPSHOTS | jq '.images[0].id')
fi

jq -n --arg image_id "$IMAGE_ID" '{"image_id":$image_id}'
