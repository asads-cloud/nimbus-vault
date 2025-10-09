variable "env" { 
    type = string 
}

variable "delivery_bucket_name" { 
    type = string 
}

variable "delivery_bucket_kms_alias" { 
    type = string 
}

variable "delivery_prefix" { 
    type = string
    default = "config" 
}
