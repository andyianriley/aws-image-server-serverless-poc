#!/bin/bash
set -e

rm -rf src/node_modules

docker-compose up --force-recreate -d

docker logs -f aws_lambda_node_6103

rm -f at_image_resize_lambda.zip && cd src && zip -r ../at_image_resize_lambda.zip * && cd ..
