# The lab server's identity: a role, delivered through an instance profile
resource "aws_iam_role" "lab" {
  name = "${var.name}-lab-server"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lab" {
  name = "read-files-bucket"
  role = aws_iam_role.lab.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.files.arn
      },
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.files.arn}/*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "lab" {
  name = "${var.name}-lab-server"
  role = aws_iam_role.lab.name
}
