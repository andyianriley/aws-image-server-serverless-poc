#!/bin/bash

export AWS_ACCESS_KEY_ID=$(aws --profile default configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws --profile default configure get aws_secret_access_key)

set -e

docker-compose run serverless

docker logs -f serverless
