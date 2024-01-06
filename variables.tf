# Input variable definitions

variable "datasource_name" {
    description = "the name of the ddb table"
    type        = string
}

variable "env" {
    description = "Env name"
    type        = string 
}

variable "appsync_id" {
    description = "Appsync id"
    type        = string 
}