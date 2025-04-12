# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require_relative 'seeds/ips'

User.create([{ firstname: 'Paul', lastname: 'Marcel', room: 'A123', email: 'paul.marcel@gmail.com' },
             { firstname: 'Gérard', lastname: 'Dupont', room: 'd145', email: 'xXgerardDUPONTXx@gmail.com' }])

User.first.machines.create({ mac: 'AA:AA:AA:AA:AA:AA', name: 'Powerful-Battery', ip: Ip.first })
User.first.machines.create({ mac: 'AA:AA:AA:AA:AA:AB', name: 'Powerful-Battery-2', ip: Ip.last })
