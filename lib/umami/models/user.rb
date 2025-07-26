# frozen_string_literal: true

module Umami
  module Models
      class User < Base
        self.table_name = "user"
        self.primary_key = "user_id"

        has_many :owned_websites, class_name: "Website", foreign_key: "user_id"
        has_many :created_websites, class_name: "Website", foreign_key: "created_by"
        has_many :team_users, class_name: "TeamUser", foreign_key: "user_id"
        has_many :teams, through: :team_users
        has_many :reports, foreign_key: "user_id"

        scope :active, -> { where(deleted_at: nil) }
        scope :with_role, ->(role) { where(role: role) }
    end
  end
end