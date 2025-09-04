#!/bin/bash

# DevOps Bookstore Deployment Script
# This script demonstrates DevOps practices for college project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
ACTION="plan"
AUTO_APPROVE=false

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} DevOps Bookstore - Terraform Deployment${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Deployment environment (dev, staging, prod) [default: dev]"
    echo "  -a, --action ACTION      Terraform action (plan, apply, destroy) [default: plan]"
    echo "  -y, --auto-approve       Auto approve terraform apply/destroy"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e dev -a plan                    # Plan deployment for dev environment"
    echo "  $0 -e dev -a apply -y                # Apply deployment for dev environment"
    echo "  $0 -e prod -a apply                  # Apply deployment for prod environment"
    echo "  $0 -e dev -a destroy -y              # Destroy dev environment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -y|--auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    print_error "Invalid action: $ACTION. Must be plan, apply, or destroy."
    exit 1
fi

print_header

print_status "Environment: $ENVIRONMENT"
print_status "Action: $ACTION"
print_status "Auto-approve: $AUTO_APPROVE"

# Change to infra directory
cd "$(dirname "$0")/infra" || {
    print_error "Could not change to infra directory"
    exit 1
}

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Format Terraform files
print_status "Formatting Terraform files..."
terraform fmt

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
terraform validate

# Select workspace based on environment
print_status "Selecting Terraform workspace: $ENVIRONMENT"
terraform workspace select "$ENVIRONMENT" 2>/dev/null || terraform workspace new "$ENVIRONMENT"

# Execute Terraform action
case $ACTION in
    plan)
        print_status "Running Terraform plan for $ENVIRONMENT environment..."
        terraform plan -var-file="${ENVIRONMENT}.tfvars" -detailed-exitcode
        ;;
    apply)
        print_status "Running Terraform apply for $ENVIRONMENT environment..."
        if [ "$AUTO_APPROVE" = true ]; then
            terraform apply -var-file="${ENVIRONMENT}.tfvars" -auto-approve
        else
            terraform apply -var-file="${ENVIRONMENT}.tfvars"
        fi
        
        # Show outputs after successful apply
        if [ $? -eq 0 ]; then
            print_status "Deployment completed successfully!"
            echo ""
            print_status "Application URLs:"
            terraform output frontend_url
            terraform output backend_url
            terraform output backend_health_check
            echo ""
            print_status "Container Information:"
            terraform output container_names
            echo ""
            print_status "Deployment Information:"
            terraform output deployment_info
        fi
        ;;
    destroy)
        print_warning "This will destroy all resources in the $ENVIRONMENT environment!"
        if [ "$AUTO_APPROVE" = false ]; then
            read -p "Are you sure you want to continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Destroy cancelled."
                exit 0
            fi
        fi
        
        print_status "Running Terraform destroy for $ENVIRONMENT environment..."
        if [ "$AUTO_APPROVE" = true ]; then
            terraform destroy -var-file="${ENVIRONMENT}.tfvars" -auto-approve
        else
            terraform destroy -var-file="${ENVIRONMENT}.tfvars"
        fi
        ;;
esac

print_status "Terraform $ACTION completed for $ENVIRONMENT environment."
