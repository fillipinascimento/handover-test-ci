[
    {
        "name": "handover_fargate_teste",
        "image": "962371430049.dkr.ecr.us-east-2.amazonaws.com/handover-teste:handover-teste",
        "essential": true,
        "memoryReservation": 256,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${log_group_region}",
                "awslogs-stream-prefix": "test"
            }
        },
        "portMappings": [
            {
                "containerPort": 3000,
                "hostPort": 3000
            }
        ]
    }
]
