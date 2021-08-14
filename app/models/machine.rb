# frozen_string_literal: true

class Machine < ApplicationRecord
  belongs_to :user
  has_one :ip, dependent: :nullify

  before_validation :set_ip, on: :create

  validates :name, presence: true, allow_blank: false
  VALID_MAC_REGEX = /\A((\h{2}:){5}\h{2}|(\h{2}-){5}\h{2}|(\h{2}){5}\h{2}|(\h{4}.){2}\h{4})\z/i
  validates :mac, presence: true, format: { with: VALID_MAC_REGEX },
                  uniqueness: { unless: ->(machine) { machine.errors.include?(:mac) } }
  validates :ip, presence: true

  private

  def set_ip
    # Rails runs the save in a transaction hence privatizing the ip thanks to lock
    # SKIP LOCKED hides the ip from other requests while in the transaction instead of blocking

    ip = Ip.lock('FOR UPDATE SKIP LOCKED').find_by(machine_id: nil)

    errors.add('base', 'No more IPs available') if ip.nil?

    self.ip = ip
  end
end
