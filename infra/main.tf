# ====================== VPC ==================================================
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

##===================== Internet Gateway ==================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
    Environment = var.environment
  }
}

##===================== Public Subnet (2 Availability Zones) ==================================================
resource "aws_subnet" "main" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

#===================== Route Table ==================================================
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

    tags = {
        Name = "${var.project_name}-route-table"
        Environment = var.environment
    }
}

#===================== Route Table Association ==================================================
resource "aws_route_table_association" "main" {
  count = 2
  subnet_id = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

#===================== Security Group ==================================================
resource "aws_security_group" "main" {
  name = "${var.project_name}-sg"
  description = "Allow inbound traffic for NairaTransfer Pro application"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}  

# ===================================== ECS Task Security Group ========================================
resource "aws_security_group" "ecs_task" {
    name = "${var.project_name}-ecs-task-sg"
    description = "Security group for ECS tasks"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# ===================================== RDS Security Group ========================================
resource "aws_security_group" "rds" {
    name        = "${var.project_name}-rds-sg"
    description = "Security group for RDS"
    vpc_id     = aws_vpc.main.id

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "RDS Security Group"
    }
}

# ===================================== ECR ========================================
resource "aws_ecr_repository" "main" {
    name = "${var.project_name}-repo"
    force_delete = true
    image_scanning_configuration {
        scan_on_push = true
    }
}

# ===================================== CLOUDWATCH ========================================
resource "aws_cloudwatch_log_group" "main" {
    name = "/ecs${var.project_name}"
    retention_in_days = 7
}

# =================================== IAM ROLES ========================================
# eXECUTION ROLE FOR ECS TASKS
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "${var.project_name}-ecs-task-execution-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Effect = "Allow"
                Sid = ""
            }
        ]
    })
}
# Task Role for ECS Tasks
resource "aws_iam_role" "ecs_task_role" {
    name = "${var.project_name}-ecs-task-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Effect = "Allow"
                Sid = ""
            }
        ]
    })
}

# =============ECS CLUSTER $ TASK DEFINITION (task definition describes how a container should run)============
resource "aws_ecs_cluster" "main" {
    name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "app" {
    family = "${var.project_name}-task"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "256" # 0.25 vCPU
    memory = "512" # 0.5 GB

    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name = "app"
            image = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
            essential = true
            portMappings = [
                {
                    containerPort = 8000
                    hostPort = 8000
                    protocol = "tcp"
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group"         = aws_cloudwatch_log_group.main.name
                    "awslogs-region"        = var.region
                    "awslogs-stream-prefix"= "ecs"
                }
            }
            healthCheck = {
                command = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
                interval = 30
                timeout = 5
                retries = 3
                startPeriod = 60
            }
        }
    ])
}
# ======================= ALB (Application Load Balancer) ========================================
resource "aws_lb" "alb" {
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = aws_subnet.public[*].id
}

resource "aws_alb_target_group" "app" {
    name = "${var.project_name}-tg"
    port = 8000
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"


    health_check {
        path = "/health"
        interval = 30
        timeout = 5
        healthy_threshold = 3
        unhealthy_threshold = 3
        matcher = "200"
    }
  
}

resource "aws_alb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.app.arn
    }
}

# ======================= ECS Service (runs the task definition) ========================================
resource "aws_ecs_service" "app" {
    name = "${var.project_name}-service"
    cluster = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        subnets = aws_subnet.public[*].id
        security_groups = [aws_security_group.ecs_task.id]
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.app.arn
        container_name = "app"
        container_port = 8000
    }

    depends_on = [aws_alb_listener.http]
}

# ======================= RDS (Relational Database Service) PostgreSQL ========================================
resource "aws_db_subnet_group" "main" {
    name = "${var.project_name}-db-subnet"
    subnet_ids = aws_subnet.public[*].id
}
resource "aws_db_instance" "main" {
    identifier = "${var.project_name}-db"
    engine = "postgres"
    engine_version = "16"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    db_name = "nairatransfer"
    username = "admin"
    password = "passme1234"
    vpc_security_group_ids = [aws_security_group.rds.id]
    skip_final_snapshot = true
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.main.name
    multi_az = false # left it in false for cost control but will i need to change it to true for production

    tags = {
        Name = "${var.project_name}-db"
        Environment = var.environment
    }

  
}