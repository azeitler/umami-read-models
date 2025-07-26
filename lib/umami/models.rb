# frozen_string_literal: true

require_relative "models/version"
require "active_record"

module Umami
  # Provides read-only ActiveRecord models for accessing Umami Analytics data
  module Models
    class Error < StandardError; end

    class << self
      attr_accessor :database

      def configure
        yield self
        apply_configuration! if database
      end

      def apply_configuration!
        return unless database

        # Apply to Base and all its descendants
        if database.is_a?(Hash)
          Base.connects_to database: database
        else
          Base.connects_to database: { writing: database, reading: database }
        end
      end
    end

    self.database = nil

    # Base class for all Umami models with read-only enforcement
    class Base < ActiveRecord::Base
      self.abstract_class = true

      def readonly?
        true
      end

      # Prevent any write operations
      before_save :prevent_writes
      before_destroy :prevent_writes

      private

      def prevent_writes
        raise ActiveRecord::ReadOnlyRecord, "Umami models are read-only"
      end
    end
  end
end

require_relative "models/user"
require_relative "models/session"
require_relative "models/website"
require_relative "models/website_event"
require_relative "models/event_data"
require_relative "models/session_data"
require_relative "models/team"
require_relative "models/team_user"
require_relative "models/report"
