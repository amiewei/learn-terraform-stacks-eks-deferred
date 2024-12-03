# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "region" {
  type = string
}

variable "identity_token" {
  type      = string
  ephemeral = true
}

variable "default_tags" {
  description = "A map of default tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}

variable "role_arn" {
  description = "AWS OIDC role"
  type      = string
  role_arn  = "arn:aws:iam::303952242443:oidc-provider/app.terraform.io"
}