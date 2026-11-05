# frozen_string_literal: true

module UsersHelper
  # Room number, followed by its occupant when it is someone other than `user`
  def room_option_label(room, user)
    room.user && room.user != user ? "#{room.number} (#{room.user.display_name})" : room.number
  end
end
