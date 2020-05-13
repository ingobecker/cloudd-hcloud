variable "api_token" {
  type        = string
  description = "API token."
}

variable "name" {
  type        = string
  description = "An unique identifier for the image."
}

variable "context" {
  type        = string
  description = "Path to the install containers build context."
}

variable "user" {
  type        = string
  description = "Primary user, mainly for debugging."
  default     = ""
}

variable "password" {
  type        = string
  description = "Primary user, mainly for debugging."
  default     = ""
}

variable "ssh_key" {
  type        = string
  description = "SSH-Key for primary user, mainly for debugging."
  default     = ""
}
