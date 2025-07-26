# frozen_string_literal: true

module Umami
  module Models
    class Session < Base
      self.table_name = "session"
      self.primary_key = "session_id"

      has_many :website_events, class_name: "WebsiteEvent", foreign_key: "session_id"
      has_many :session_data, class_name: "SessionData", foreign_key: "session_id"

      scope :recent, -> { order(created_at: :desc) }
      scope :by_website, ->(website_id) { where(website_id: website_id) }
      scope :by_browser, ->(browser) { where(browser: browser) }
      scope :by_os, ->(os) { where(os: os) }
      scope :by_device, ->(device) { where(device: device) }
      scope :by_country, ->(country) { where(country: country) }
      scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
    end
  end
end
