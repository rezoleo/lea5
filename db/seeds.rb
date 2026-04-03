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
require_relative 'seeds/rooms'

paul = User.find_or_initialize_by(email: 'paul.marcel@gmail.com')
paul.update!(firstname: 'Paul', lastname: 'Marcel', username: 'paulmarcel')
Room.find_by(number: 'A109A')&.update!(user: paul)

gerard = User.find_or_initialize_by(email: 'xXgerardDUPONTXx@gmail.com')
gerard.update!(firstname: 'Gérard', lastname: 'Dupont', username: 'gerarddupont')
Room.find_by(number: 'A201')&.update!(user: gerard)

paul.machines.find_or_create_by!(mac: 'AA:AA:AA:AA:AA:AA') do |machine|
  machine.name = 'Powerful-Battery'
  machine.ip = Ip.first
end
paul.machines.find_or_create_by!(mac: 'AA:AA:AA:AA:AA:AB') do |machine|
  machine.name = 'Powerful-Battery-2'
  machine.ip = Ip.last
end
