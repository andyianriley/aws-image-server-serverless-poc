resource "aws_lambda_function" "lambda" {
  filename      = "${var.name}.zip"
  source_code_hash = "${base64sha256(file("${var.name}.zip"))}"
  function_name = "${var.name}_${var.handler}"
  role          = "${var.role}"
  handler       = "index.${var.handler}"
  runtime       = "${var.runtime}"
  environment = {
    variables = "${var.environment}"
  }
  timeout       = "${var.timeout}"
}
