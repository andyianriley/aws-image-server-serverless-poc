AWS Image Server POC
====================

This project is an example of a JS (AWS)
[Lambda](https://aws.amazon.com/lambda/) exposed with [API
Gateway](https://aws.amazon.com/api-gateway/), configured with
[Serverless](https://serverless.com/).


## Introduction

This demo project creates an S3 bucket. If a requested image size isn't available then the
404 is caught and redirected (307) to a `/resize` endpoint supporting any methods in AWS.
These are bound to a JS project containing an handler (a.k.a. lambda functions).
This is defined by a `handler`parameter. The code the lambda function is written in JavaScript.
The function transforms an image into another file type or size and saves the new image in the S3 bucket.
Finally the request is redirected to back to the S3 bucket to return the new image to the user.

![overview](./overview.png)

## Getting started

You must have an [AWS account](http://aws.amazon.com/), create a user for the serverless to use [see AWS Credentials] (https://serverless.com/framework/docs/providers/aws/guide/credentials/).

Clone this repository, update the config/default.json to set the bucket name and aws region, then run:

```
    # to setup your AWS login details
    aws configure

    # AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are now available for serverless to use in the docker container
    ./build.sh

```
Upload an image into the root of the S3 bucket.
You will be able to access a resized image at http://<BUCKET_NAME>.s3-website-eu-west-1.amazonaws.com/250x300/image.jpg


You can destroy all the components by running:

    $ serverless remove

For more information, please read [the Serverless
documentation](https://serverless.com/framework/docs/).
