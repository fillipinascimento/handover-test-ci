resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"
  policy      = file("./templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix}-task-exec-role"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_iam_role" "handover_iam_role" {
  name               = "${local.prefix}-task"
  assume_role_policy = file("./templates/ecs/assume-role-policy.json")

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-logs"

  tags = local.common_tags
}

data "template_file" "handover_container_definitions" {
  template = file("templates/ecs/container-definitions.json.tpl")

  vars = {
    app_image        = var.ecr_image_test
    log_group_name   = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region = data.aws_region.current.name
  }
}

resource "aws_ecs_task_definition" "handover_task" {
  family                   = "${local.prefix}-task" # Naming our first task
  container_definitions    = data.template_file.handover_container_definitions.rendered
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  cpu                      = 256         # Specifying the memory our container require
  memory                   = 512         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.handover_iam_role.arn
  volume {
    name = "static"
  }

  tags = local.common_tags
}

resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = "vpc-60f1ed08"

  egress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "api" {
  name            = "${local.prefix}-service"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.handover_task.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-8f9195e7",
    ]
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
}
