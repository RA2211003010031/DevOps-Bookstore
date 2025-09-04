# Development Environment Configuration
environment   = "dev"
app_version   = "v1.0.0-dev"
frontend_port = 3000
backend_port  = 5001

# Database Configuration (use local MongoDB for dev)
mongo_uri = "mongodb://localhost:27017/bookstore-dev"

# Security (weaker for development)
jwt_secret = "dev-jwt-secret-key"

# Project
project_name = "devops-bookstore"
