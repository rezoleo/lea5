# frozen_string_literal: true

require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    super
    @room = rooms(:room_a105a)
  end

  test 'room is valid' do
    assert_predicate @room, :valid?
  end

  test 'number must be present' do
    @room.number = nil
    assert_not_predicate @room, :valid?
  end

  test 'number must be unique' do
    duplicate = @room.dup
    assert_not_predicate duplicate, :valid?
  end

  test 'number must be at most 6 characters' do
    @room.number = 'A123456'
    assert_not_predicate @room, :valid?
  end

  test 'number must be uppercase alphanumeric' do
    @room.number = 'a105a'
    assert_not_predicate @room, :valid?

    @room.number = 'A1-5'
    assert_not_predicate @room, :valid?
  end

  test 'group must be present' do
    @room.group = nil
    assert_not_predicate @room, :valid?
  end

  test 'group must be at most 6 characters' do
    @room.group = 'A123456'
    assert_not_predicate @room, :valid?
  end

  test 'group must be uppercase alphanumeric' do
    @room.group = 'a105'
    assert_not_predicate @room, :valid?
  end

  test 'building must be between A and F' do
    ('A'..'F').each do |b|
      @room.building = b
      assert_predicate @room, :valid?, "Building #{b} should be valid"
    end

    @room.building = 'G'
    assert_not_predicate @room, :valid?

    @room.building = nil
    assert_not_predicate @room, :valid?
  end

  test 'floor must be between 0 and 3' do
    (0..3).each do |f|
      @room.floor = f
      assert_predicate @room, :valid?, "Floor #{f} should be valid"
    end

    @room.floor = 4
    assert_not_predicate @room, :valid?

    @room.floor = -1
    assert_not_predicate @room, :valid?

    @room.floor = nil
    assert_not_predicate @room, :valid?
  end

  test 'belongs_to user association' do
    room = rooms(:room_a109a)
    assert_equal users(:ironman), room.user
  end

  test 'user_id must be unique when not nil' do
    room = rooms(:room_b231)
    room.user = users(:ironman)
    assert_not_predicate room, :valid?
    assert_includes room.errors[:user_id], 'has already been taken'
  end

  test 'multiple rooms can have nil user' do
    room1 = rooms(:room_a105a)
    room2 = rooms(:room_b231)
    assert_nil room1.user
    assert_nil room2.user
    assert_predicate room1, :valid?
    assert_predicate room2, :valid?
  end

  test 'room without user can be destroyed' do
    room = rooms(:room_a105a)
    assert room.destroy
  end

  test 'room with user can be destroyed and nullifies user association' do
    room = rooms(:room_a109a)
    user = room.user
    assert room.destroy
    user.reload
    assert_nil user.room
  end

  test 'available_for returns rooms not occupied by other users' do
    user = users(:ironman)
    available = Room.available_for(user)

    # Should include the user's own room
    assert_includes available.map(&:number), user.room.number

    # Should not include other users' rooms
    assert_not_includes available.map(&:number), users(:pepper).room.number

    # Should include unoccupied rooms
    assert_includes available.map(&:number), rooms(:room_a105a).number
  end

  test 'changing user_id enqueues room sync job for new user' do
    room = rooms(:room_a105a)
    user = users(:spiderman)

    assert_enqueued_with(job: SyncRoomToSsoJob, args: [user.id]) do
      room.update!(user: user)
    end
  end

  test 'changing user_id enqueues room sync job for previous user' do
    room = rooms(:room_a109a)
    room.user
    new_user = users(:spiderman)
    assert_enqueued_jobs(2, only: SyncRoomToSsoJob) do
      room.update!(user: new_user)
    end
  end

  test 'removing user_id enqueues room sync job for previous user' do
    room = rooms(:room_a109a)
    old_user = room.user

    assert_enqueued_with(job: SyncRoomToSsoJob, args: [old_user.id]) do
      room.update!(user: nil)
    end
  end
end
