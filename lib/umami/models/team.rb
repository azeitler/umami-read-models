# frozen_string_literal: true

module Umami
  module Models
    class Team < Base
      self.table_name = "team"
      self.primary_key = "team_id"
      has_many :websites, foreign_key: "team_id"
      has_many :team_users, class_name: "TeamUser", foreign_key: "team_id"
      has_many :users, through: :team_users
      scope :active, -> { where(deleted_at: nil) }
      scope :by_access_code, ->(code) { where(access_code: code) }
    end
  end
end
