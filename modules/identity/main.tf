variable "company_domain" {
  description = "Internal company domain"
  type        = string
  default     = "company.local"
}

locals {
  groups = {
    employees = {
      description = "Standard company employees"
    }

    it-administrators = {
      description = "IT administrators with elevated administrative access"
    }

    application-services = {
      description = "Non-human application service accounts"
    }
  }

  users = {
    alice = {
      description = "Standard employee account"
      groups      = ["employees"]
    }

    bob = {
      description = "IT administrator account"
      groups      = ["employees", "it-administrators"]
    }

    app_service = {
      description = "Application service account"
      groups      = ["application-services"]
    }
  }

  access_rules = {
    employees = {
      network_access = [
        "application"
      ]

      administrative_access = false
    }

    it-administrators = {
      network_access = [
        "public",
        "application",
        "database"
      ]

      administrative_access = true
    }

    application-services = {
      network_access = [
        "application",
        "database"
      ]

      administrative_access = false
    }
  }
}
