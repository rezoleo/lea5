# typed: false
# frozen_string_literal: true

require_relative './seeds/ips'

User.create([{ firstname: 'Paul', lastname: 'Marcel', room: 'A123', email: 'paul.marcel@gmail.com' },
             { firstname: 'Gérard', lastname: 'Dupont', room: 'd145', email: 'xXgerardDUPONTXx@gmail.com' }])

T.must(User.first).machines.create({ mac: 'AA:AA:AA:AA:AA:AA', name: 'Powerful-Battery', ip: Ip.first })
User.first.machines.create({ mac: 'AA:AA:AA:AA:AA:AA', name: 'Powerful-Battery', ip: Ip.first })
T.must(User.first).machines.create({ mac: 'AA:AA:AA:AA:AA:AB', name: 'Powerful-Battery-2', ip: Ip.last })
