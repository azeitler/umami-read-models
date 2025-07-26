# frozen_string_literal: true

module Umami
  module Models
    class EventData < Base
      self.table_name = "event_data"
      self.primary_key = "event_data_id"
      belongs_to :website, foreign_key: "website_id"
      belongs_to :website_event, foreign_key: "website_event_id"
      scope :by_website, ->(website_id) { where(website_id: website_id) }
      scope :by_key, ->(key) { where(data_key: key) }
      scope :string_type, -> { where(data_type: 1) }
      scope :number_type, -> { where(data_type: 2) }
      scope :date_type, -> { where(data_type: 3) }
      scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
      def value
        case data_type
        when 1 then string_value
        when 2 then number_value
        when 3 then date_value
        end
      end
    end
  end
end
