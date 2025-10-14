# main.tf
resource "aws_kms_key" "aws_infra_terraform_bucket_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
  name          = var.aws_infra_terraform_bucket_kms_key_id
  target_key_id = aws_kms_key.aws_infra_terraform_bucket_kms_key.key_id
}

resource "aws_s3_bucket" "aws_infra_terraform_bucket" {
  bucket = var.aws_infra_terraform_bucket
  tags = var.state_bucket_tags
}

resource "aws_s3_bucket_acl" "aws_infra_terraform_bucket" {
  bucket = aws_s3_bucket.aws_infra_terraform_bucket.bucket
  acl    = "private"
depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}


# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.aws_infra_terraform_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "aws_infra_terraform_bucket" {
  bucket = aws_s3_bucket.aws_infra_terraform_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.aws_infra_terraform_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_versioning" "aws_infra_terraform_bucket" {
  bucket = aws_s3_bucket.aws_infra_terraform_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.aws_infra_terraform_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_infra_terraform_bucket" {
  depends_on = [
    aws_s3_bucket_versioning.aws_infra_terraform_bucket
  ]

  bucket = aws_s3_bucket.aws_infra_terraform_bucket.id

  rule {
    id = "aws-infra-terraform-bucket-versioning"
    
    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "ONEZONE_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "GLACIER"
    }

    status = "Enabled"

  }
}

resource "aws_dynamodb_table" "aws_infra_terraform_dynamodb_table" {
  name           = var.aws_infra_terraform_dynamodb_table
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = var.state_dynamodb_tags
}

resource "aws_appautoscaling_target" "aws_infra_terraform_dynamodb_table_read" {
    max_capacity       = 3
    min_capacity       = 1
    resource_id        = "table/${aws_dynamodb_table.aws_infra_terraform_dynamodb_table.name}"
    scalable_dimension = "dynamodb:table:ReadCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "aws_infra_terraform_dynamodb_table_read" {
    name               = "dynamodb-read-capacity-utilization-${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_read.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_read.resource_id}"
    scalable_dimension = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_read.scalable_dimension}"
    service_namespace  = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_read.service_namespace}"

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "DynamoDBReadCapacityUtilization"
        }
        target_value = 70
    }
}

resource "aws_appautoscaling_target" "aws_infra_terraform_dynamodb_table_write" {
    max_capacity       = 3
    min_capacity       = 1
    resource_id        = "table/${aws_dynamodb_table.aws_infra_terraform_dynamodb_table.name}"
    scalable_dimension = "dynamodb:table:WriteCapacityUnits"
    service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "aws_infra_terraform_dynamodb_table_write" {
    name               = "dynamodb-write-capacity-utilization-${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_write.resource_id}"
    policy_type        = "TargetTrackingScaling"
    resource_id        = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_write.resource_id}"
    scalable_dimension = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_write.scalable_dimension}"
    service_namespace  = "${aws_appautoscaling_target.aws_infra_terraform_dynamodb_table_write.service_namespace}"

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "DynamoDBWriteCapacityUtilization"
        }
        target_value = 70
    }
}