variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
  default     = "mongodb://localhost:27017/bookstore"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  default     = "your-jwt-secret-key"
  sensitive   = true
}

variable "frontend_port" {
  description = "Port for frontend container"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Port for backend container"
  type        = number
  default     = 5001
}