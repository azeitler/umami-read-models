# frozen_string_literal: true
module Umami
    module Models
      class WebsiteEvent < Base
        self.table_name = "website_event"
        self.primary_key = "event_id"
        belongs_to :session, foreign_key: "session_id"
        has_many :event_data, class_name: "EventData", foreign_key: "website_event_id"
        scope :recent, -> { order(created_at: :desc) }
        scope :by_website, ->(website_id) { where(website_id: website_id) }
        scope :by_session, ->(session_id) { where(session_id: session_id) }
        scope :by_visit, ->(visit_id) { where(visit_id: visit_id) }
        scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
        scope :page_views, -> { where(event_type: 1) }
        scope :custom_events, -> { where(event_type: 2) }
        scope :by_event_name, ->(name) { where(event_name: name) }
        scope :by_url_path, ->(path) { where(url_path: path) }
        scope :by_hostname, ->(hostname) { where(hostname: hostname) }
        scope :with_utm_source, ->(source) { where(utm_source: source) }
        scope :with_utm_campaign, ->(campaign) { where(utm_campaign: campaign) }
      end
    end
  end