# Use latest SLES 15
# gcloud compute images list | grep suse
data "google_compute_image" "sles" {
  project = "suse-cloud"
  family  = "sles-15"
}
