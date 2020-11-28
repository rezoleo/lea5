# frozen_string_literal: true

User.create([{ firstname: 'Paul', lastname: 'Marcel', room: 'A123', email: 'paul.marcel@gmail.com' },
             { firstname: 'Gérard', lastname: 'Dupont', room: 'd145', email: 'xXgerardDUPONTXx@gmail.com' }])

require_relative './seeds/ips'
