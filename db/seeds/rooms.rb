# frozen_string_literal: true

# Seed rooms for the residence.
# Rooms follow the pattern: Building (A-F) + Floor (0-3) + Number + optional letter (for shared apartments)
# Special rooms: DF1-DF4, CLAP, ALUMNI

rooms = [
  # Building A - Floor 0
  { number: 'A001', group: 'A001', building: 'A', floor: 0 },
  { number: 'A002', group: 'A002', building: 'A', floor: 0 },
  { number: 'A003', group: 'A003', building: 'A', floor: 0 },
  # Building A - Floor 1 (with doubles)
  { number: 'A100', group: 'A100', building: 'A', floor: 1 },
  { number: 'A101', group: 'A101', building: 'A', floor: 1 },
  { number: 'A105A', group: 'A105', building: 'A', floor: 1 },
  { number: 'A105B', group: 'A105', building: 'A', floor: 1 },
  { number: 'A108A', group: 'A108', building: 'A', floor: 1 },
  { number: 'A108B', group: 'A108', building: 'A', floor: 1 },
  { number: 'A123', group: 'A123', building: 'A', floor: 1 },
  # Building A - Floor 2
  { number: 'A200', group: 'A200', building: 'A', floor: 2 },
  { number: 'A201', group: 'A201', building: 'A', floor: 2 },
  { number: 'A205A', group: 'A205', building: 'A', floor: 2 },
  { number: 'A205B', group: 'A205', building: 'A', floor: 2 },
  # Building A - Floor 3
  { number: 'A300', group: 'A300', building: 'A', floor: 3 },
  { number: 'A313', group: 'A313', building: 'A', floor: 3 },

  # Building B - Floor 1
  { number: 'B100', group: 'B100', building: 'B', floor: 1 },
  { number: 'B134A', group: 'B134', building: 'B', floor: 1 },
  { number: 'B134B', group: 'B134', building: 'B', floor: 1 },
  # Building B - Floor 2
  { number: 'B231', group: 'B231', building: 'B', floor: 2 },

  # Building C - Floor 0
  { number: 'C001A', group: 'C001', building: 'C', floor: 0 },
  { number: 'C001B', group: 'C001', building: 'C', floor: 0 },

  # Building D - Floor 1
  { number: 'D111A', group: 'D111', building: 'D', floor: 1 },
  { number: 'D111B', group: 'D111', building: 'D', floor: 1 },
  { number: 'D145', group: 'D145', building: 'D', floor: 1 },
  # Building D - Floor 3
  { number: 'D314', group: 'D314', building: 'D', floor: 3 },

  # Building E - Floor 1
  { number: 'E124', group: 'E124', building: 'E', floor: 1 },
  { number: 'E231A', group: 'E231', building: 'E', floor: 2 },

  # Building F - Floor 3
  { number: 'F313', group: 'F313', building: 'F', floor: 3 },

  # Special rooms
  { number: 'DF1', group: 'DF', building: 'D', floor: 0 },
  { number: 'DF2', group: 'DF', building: 'D', floor: 0 },
  { number: 'DF3', group: 'DF', building: 'D', floor: 0 },
  { number: 'DF4', group: 'DF', building: 'D', floor: 0 },
  { number: 'CLAP', group: 'ASSO', building: 'D', floor: 0 },
  { number: 'ALUMN', group: 'ASSO', building: 'D', floor: 0 }
]

rooms.each do |room_attrs|
  Room.find_or_create_by!(number: room_attrs[:number]) do |room|
    room.group = room_attrs[:group]
    room.building = room_attrs[:building]
    room.floor = room_attrs[:floor]
  end
end
