terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "frontend" {
  name = "devops-bookstore-frontend:latest"

  build {
    context    = "/Users/adarshraj/Desktop/DevOps-Bookstore"
  }
}

resource "docker_container" "frontend" {
  name  = "devops-frontend"
  image = docker_image.frontend.name

  ports {
    internal = 80
    external = 3000
  }

  restart = "always"
}

resource "docker_image" "backend" {
  name = "devops-bookstore-backend:latest"

  build {
    context    = "/Users/adarshraj/Desktop/DevOps-Bookstore/backend"
  }
}

resource "docker_container" "backend" {
  name  = "devops-backend"
  image = docker_image.backend.name

  ports {
    internal = 5000
    external = 5001
  }

  env = [
    "PORT=5000",
    "MONGO_URI=${var.mongo_uri}",
    "JWT_SECRET=${var.jwt_secret}"
  ]

  restart = "always"
}
