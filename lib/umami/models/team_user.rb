# frozen_string_literal: true

module Umami
  module Models
    # Represents team membership
    class TeamUser < Base
      self.table_name = "team_user"
      self.primary_key = "team_user_id"
      belongs_to :team, foreign_key: "team_id"
      belongs_to :user, foreign_key: "user_id"
      scope :by_role, ->(role) { where(role: role) }
      scope :admins, -> { where(role: "admin") }
      scope :members, -> { where(role: "member") }
    end
  end
end
