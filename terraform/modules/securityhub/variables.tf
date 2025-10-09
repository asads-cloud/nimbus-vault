variable "env" { type = string }

variable "enable_fsbp"  { 
    type = bool
    default = true 
}

variable "enable_cis"   { 
    type = bool  
    default = true 
}

variable "cis_version"  { 
    type = string 
    default = "1.4.0" 
}
