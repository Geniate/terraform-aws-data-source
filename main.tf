terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "barshopen"
}

resource "aws_dynamodb_table" "data_soruce_table" {
  name           = var.datasource_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.datasource_name}"
    Environment = "barshopen"
  }
}

# add conditional addition for this. 
resource "aws_dynamodb_table_item" "demo_item" {
  table_name = aws_dynamodb_table.data_soruce_table.name
  hash_key   = aws_dynamodb_table.data_soruce_table.hash_key

  item = <<EOF
  {
    "id": {
      "S": "h123"
    },
    "createdBy": {
      "S": "unclebob"
    },
    "email": {
      "S": "yo@yoyo.com"
    },
    "firstName": {
      "S": "bob"
    },
    "lastName": {
      "S": "uncle"
    }
  }
  EOF
}


resource "aws_appsync_datasource" "data_source" { # datasource of dynamodb
  api_id           = var.appsync_id
  name             = "${var.datasource_name}_data_source"
  service_role_arn = aws_iam_role.data_source_iam_role.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.data_soruce_table.name
  }
}

data "aws_iam_policy_document" "data_source_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "data_source_iam_role" {
  name               = "${var.datasource_name}_data_source_role"
  assume_role_policy = data.aws_iam_policy_document.data_source_assume_role.json
}

data "aws_iam_policy_document" "data_source_aws_iam_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = [aws_dynamodb_table.data_soruce_table.arn] # need to be changed when new data sources are added
  }
}
resource "aws_iam_role_policy" "data_source_iam_role_policy" {
  name   = "${var.datasource_name}_data_source_role_policy"
  role   = aws_iam_role.data_source_iam_role.id
  policy = data.aws_iam_policy_document.data_source_aws_iam_policy_document.json
}