provider "aws" {
  region     = "${var.aws_region}"
}

data "aws_caller_identity" "current" { }

data "aws_iam_policy_document" "s3-access-po" {
    statement {
        actions = [
            "s3:PutObject",
        ]
        resources = [
            "arn:aws:s3:::${var.s3_bucket_name}/*",
        ]
    }
}

resource "aws_iam_policy" "s3-access-po" {
    name = "s3-access-po"
    path = "/"
    policy = "${data.aws_iam_policy_document.s3-access-po.json}"
}

data "aws_iam_policy_document" "logs-role-put" {
    statement {
        actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        ]
        resources = [
            "arn:aws:logs:*:*:*",
        ]
    }
}
resource "aws_iam_policy" "logs-role-put" {
    name = "logs-role-put"
    path = "/"
    policy = "${data.aws_iam_policy_document.logs-role-put.json}"
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3-access-po" {
    role       = "${aws_iam_role.iam_role_for_lambda.name}"
    policy_arn = "${aws_iam_policy.s3-access-po.arn}"
}

resource "aws_iam_role_policy_attachment" "logs-role-put" {
    role       = "${aws_iam_role.iam_role_for_lambda.name}"
    policy_arn = "${aws_iam_policy.logs-role-put.arn}"
}

# image resize function
module "lambda" {
  source  = "./lambda"
  name    = "at_image_resize_lambda"
  runtime = "nodejs6.10"
  role    = "${aws_iam_role.iam_role_for_lambda.arn}"
  environment = {
      BUCKET = "${var.s3_bucket_name}"
      URL = "http://${var.s3_bucket_name}.s3-website.${var.aws_region}.amazonaws.com"
  }
}

# Now, we need an API to expose those functions publicly
resource "aws_api_gateway_rest_api" "at_image_api" {
  name = "AT Image Resizer API"
}

# The endpoint created here is: /hello
resource "aws_api_gateway_resource" "at_image_api_res_resize" {
  rest_api_id = "${aws_api_gateway_rest_api.at_image_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.at_image_api.root_resource_id}"
  path_part   = "resize"
}

# Create method GET /resize, that will link to the resize lambda
module "resize_get" {
  source      = "./api_method"
  rest_api_id = "${aws_api_gateway_rest_api.at_image_api.id}"
  resource_id = "${aws_api_gateway_resource.at_image_api_res_resize.id}"
  method      = "ANY"
  path        = "${aws_api_gateway_resource.at_image_api_res_resize.path}"
  lambda      = "${module.lambda.name}"
  region      = "${var.aws_region}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}

# We can deploy the API
resource "aws_api_gateway_deployment" "at_image_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.at_image_api.id}"
  stage_name  = "production"
  description = "Deploy methods: ${module.resize_get.http_method}"
}

# Create S3 bucket if not found
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket_name}"
  acl = "public-read"

  website {
  index_document = "index.html"
  error_document = "error.html"

  routing_rules = <<EOF
[{
  "Condition": {
      "KeyPrefixEquals": "",
      "HttpErrorCodeReturnedEquals":"404"
  },
  "Redirect": {
      "Protocol":"https",
      "HostName":"${aws_api_gateway_rest_api.at_image_api.id}.execute-api.${var.aws_region}.amazonaws.com",
      "ReplaceKeyPrefixWith": "production/resize?key=",
      "HttpRedirectCode":"307"
  }
}]
EOF
}
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = "${aws_s3_bucket.bucket.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "ANON-RO-POLICY",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource":"arn:aws:s3:::${var.s3_bucket_name}/*"
    }
  ]
}
POLICY
}
