# frozen_string_literal: true
module Umami
    module Models
      class Website < Base
        self.table_name = "website"
        self.primary_key = "website_id"
        belongs_to :user, foreign_key: "user_id", optional: true
        belongs_to :created_by_user, class_name: "User", foreign_key: "created_by", optional: true
        belongs_to :team, foreign_key: "team_id", optional: true
        has_many :event_data, class_name: "EventData", foreign_key: "website_id"
        has_many :reports, foreign_key: "website_id"
        has_many :session_data, class_name: "SessionData", foreign_key: "website_id"
        scope :active, -> { where(deleted_at: nil) }
        scope :by_user, ->(user_id) { where(user_id: user_id) }
        scope :by_team, ->(team_id) { where(team_id: team_id) }
        scope :public_shares, -> { where.not(share_id: nil) }
        def sessions
          Session.by_website(website_id)
        end
        def website_events
          WebsiteEvent.by_website(website_id)
        end
      end
    end
  end