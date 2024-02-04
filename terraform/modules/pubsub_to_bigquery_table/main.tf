
variable "table_name" {
  type = string
}

variable "location" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "dead_letter_topic" {
  type = string
}

resource "google_pubsub_topic" "table_topic" {
  name = "${var.table_name}_topic"
}

resource "google_bigquery_table" "table" {
  dataset_id = var.dataset_id
  table_id   = var.table_name

  schema = file("${path.root}/../tables/${var.table_name}.json")

  time_partitioning {
    type = "DAY"
    field = "receive_timestamp"
  }

#  require_partition_filter = true
  deletion_protection = false
}

#// necessary IAM for push sub
#data google_project "project" {
#}
#resource "google_project_iam_member" "viewer" {
#  project = data.google_project.project.project_id
#  role   = "roles/bigquery.metadataViewer"
#  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
#}
#
#resource "google_project_iam_member" "editor" {
#  project = data.google_project.project.project_id
#  role   = "roles/bigquery.dataEditor"
#  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
#}
#
#resource "google_project_iam_member" "publish" {
#  project = data.google_project.project.project_id
#  role   = "roles/pubsub.publisher"
#  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
#}
#
#resource "google_project_iam_member" "subscribe" {
#  project = data.google_project.project.project_id
#  role   = "roles/pubsub.subscriber"
#  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
#}

resource "google_pubsub_subscription" "push_to_bigquery_sub" {
  name  = "${var.table_name}_subscription"
  topic = google_pubsub_topic.table_topic.name

  bigquery_config {
    table = "${var.project_id}.${var.dataset_id}.${var.table_name}"
    use_table_schema = true
    drop_unknown_fields = true
  }

  dead_letter_policy {
#    dead_letter_topic = "projects/${data.google_project.project.project_id}/topics/${var.dead_letter_topic}"
    dead_letter_topic = "projects/${var.project_id}/topics/${var.dead_letter_topic}"
    max_delivery_attempts = 5
  }

  depends_on = [
    google_bigquery_table.table,
    google_pubsub_topic.table_topic,
#    google_project_iam_member.viewer,
#    google_project_iam_member.editor
  ]

}

## ADD DEAD LETTERING
  ## TOPIC and
  ## SUB

## new Iam to publish




















