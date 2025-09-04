output "frontend_url" {
  description = "URL to access the frontend application"
  value       = "http://localhost:${var.frontend_port}"
}

output "backend_url" {
  description = "URL to access the backend API"
  value       = "http://localhost:${var.backend_port}"
}

output "backend_health_check" {
  description = "Backend health check endpoint"
  value       = "http://localhost:${var.backend_port}/health"
}

output "container_names" {
  description = "Names of the deployed containers"
  value = {
    frontend = docker_container.frontend.name
    backend  = docker_container.backend.name
  }
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.bookstore_network.name
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment = var.environment
    app_version = var.app_version
    project     = var.project_name
    timestamp   = timestamp()
  }
}
