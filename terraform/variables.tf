variable "project_id" {
  type = string
}
variable "location" {
  type = string
}
variable "static_schema_dataset" {
  type = string
}

variable "dead_letter_topic" {
  type = string
}

variable "table_list" {
  type = list(string)
}