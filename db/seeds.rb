# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Chat.destroy_all

TennisPlayer.destroy_all

TennisPlayer.create!([
                       { full_name: "John Isner", date_of_birth: "1985-04-26", height: 208, handedness: "right", backhand: "two-handed" },
                       { full_name: "Ivo Karlovic", date_of_birth: "1979-02-28", height: 211, handedness: "right", backhand: "one-handed" },
                       { full_name: "Roger Federer", date_of_birth: "1981-08-08", height: 185, handedness: "right", backhand: "one-handed" },
                       { full_name: "Rafael Nadal", date_of_birth: "1986-06-03", height: 185, handedness: "left", backhand: "two-handed" },
                       { full_name: "Novak Djokovic", date_of_birth: "1987-05-22", height: 188, handedness: "right", backhand: "two-handed" },
                       { full_name: "Gael Monfils", date_of_birth: "1986-09-01", height: 193, handedness: "right", backhand: "two-handed" },
                       { full_name: "Diego Schwartzman", date_of_birth: "1992-08-16", height: 170, handedness: "right", backhand: "two-handed" }
                     ])

puts "Seeded #{TennisPlayer.count} tennis players!"
