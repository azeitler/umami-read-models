# frozen_string_literal: true
module Umami
    module Models
      class SessionData < Base
        self.table_name = "session_data"
        self.primary_key = "session_data_id"
        belongs_to :website, foreign_key: "website_id"
        belongs_to :session, foreign_key: "session_id"
        scope :by_website, ->(website_id) { where(website_id: website_id) }
        scope :by_session, ->(session_id) { where(session_id: session_id) }
        scope :by_key, ->(key) { where(data_key: key) }
        scope :by_distinct_id, ->(distinct_id) { where(distinct_id: distinct_id) }
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
end