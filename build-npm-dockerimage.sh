#!/bin/bash
set -e

docker build -t aws_lambda_node_6103 .
docker tag aws_lambda_node_6103:latest eu.gcr.io/k8-discovery-185615/aws_lambda_node_6103:latest
docker push eu.gcr.io/k8-discovery-185615/aws_lambda_node_6103:latest
