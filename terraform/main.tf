provider "google" {
  credentials = file("../credentials.json")
#   project = "idyllic-web-401116"
  project = var.project_id
  region = "europe-west2"
}

locals {
  tables = var.table_list
}

// necessary IAM for push sub
data google_project "project" {
}

resource "google_project_iam_member" "viewer" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.metadataViewer"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "editor" {
  project = data.google_project.project.project_id
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "publish" {
  project = data.google_project.project.project_id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "subscribe" {
  project = data.google_project.project.project_id
  role   = "roles/pubsub.subscriber"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}


resource "google_bigquery_dataset" "static_schema_dataset" {
  dataset_id = var.static_schema_dataset
  location = var.location
}

#resource "google_bigquery_table" "bq_tables" {
#  dataset_id = google_bigquery_dataset.static_schema_dataset.dataset_id
#  table_id   = file("../tables/*.json")
#
##  schema = file("${path.module}/schema.json")
#  schema = file("src/${table}.json")
#}
resource "google_pubsub_topic" "dead_letter_topic" {
  name = "dead_letter_topic"
}

resource "google_pubsub_subscription" "dead_letter_sub" {
  name  = "dead_letter_sub"
  topic = google_pubsub_topic.dead_letter_topic.name
}

module "respective_pipelines" {
  for_each = toset(local.tables)

  source = "./modules/pubsub_to_bigquery_table"

  dataset_id = google_bigquery_dataset.static_schema_dataset.dataset_id
  location   = var.location
  table_name = each.value
  project_id = var.project_id
  dead_letter_topic = var.dead_letter_topic

  depends_on = [
    google_project_iam_member.viewer,
    google_project_iam_member.editor,
    google_project_iam_member.publish,
    google_project_iam_member.subscribe
  ]
}













