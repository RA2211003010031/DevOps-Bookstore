terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Backend Docker Image
resource "docker_image" "backend" {
  name = "bookstore-backend:latest"
  build {
    context    = "${path.root}/../backend"
    dockerfile = "Dockerfile"
  }
}

# Frontend Docker Image  
resource "docker_image" "frontend" {
  name = "bookstore-frontend:latest"
  build {
    context    = "${path.root}/.."
    dockerfile = "Dockerfile"
  }
}

# Backend Container
resource "docker_container" "backend" {
  name  = "bookstore-backend"
  image = docker_image.backend.name

  ports {
    internal = 5000
    external = var.backend_port
  }

  env = [
    "PORT=5000",
    "MONGO_URI=${var.mongo_uri}",
    "JWT_SECRET=${var.jwt_secret}"
  ]
}

# Frontend Container
resource "docker_container" "frontend" {
  name  = "bookstore-frontend"
  image = docker_image.frontend.name

  ports {
    internal = 80
    external = var.frontend_port
  }

  depends_on = [docker_container.backend]
}
