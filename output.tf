output "users" {
  description = "Created Users"
  value       = var.users
}

output "address" {
  description = "The created address"
  value       = google_compute_address.default
}