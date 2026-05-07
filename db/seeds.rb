# frozen_string_literal: true

Rails.logger.debug "🌱 Seeding database..."

admin = User.find_or_create_by!(email: "admin@fartlek.dev") do |u|
  u.first_name = "Admin"
  u.last_name = "Fartlek"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.gender = :male
  u.date_of_birth = Date.new(1990, 6, 15)
  u.time_zone = "Europe/Paris"
  u.admin = true
end

Rails.logger.debug { "  ✅ Admin: #{admin.email} / password123" }

user = User.find_or_create_by!(email: "runner@fartlek.dev") do |u|
  u.first_name = "Marie"
  u.last_name = "Durand"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.gender = :female
  u.date_of_birth = Date.new(1995, 3, 22)
  u.time_zone = "Europe/Paris"
  u.admin = false
end

Rails.logger.debug { "  ✅ User:  #{user.email} / password123" }

Rails.logger.debug "🏁 Done!"
