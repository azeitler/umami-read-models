# frozen_string_literal: true

module Umami
  module Models
    class Report < Base
      self.table_name = "report"
      self.primary_key = "report_id"
      belongs_to :user, foreign_key: "user_id"
      belongs_to :website, foreign_key: "website_id"
      scope :by_type, ->(type) { where(type: type) }
      scope :by_name, ->(name) { where(name: name) }
      scope :by_user, ->(user_id) { where(user_id: user_id) }
      scope :by_website, ->(website_id) { where(website_id: website_id) }
      scope :recent, -> { order(created_at: :desc) }
      def parsed_parameters
        JSON.parse(parameters)
      rescue JSON::ParserError
        {}
      end
    end
  end
end
