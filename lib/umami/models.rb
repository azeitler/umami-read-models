# frozen_string_literal: true

require_relative "models/version"
require "active_record"

module Umami
  # Provides read-only ActiveRecord models for accessing Umami Analytics data
  module Models
    class Error < StandardError; end

    class << self
      attr_accessor :table_prefix, :database

      def configure
        yield self
      end
    end

    self.table_prefix = ""
    self.database = nil

    # Base class for all Umami models with read-only enforcement
    class Base < ActiveRecord::Base
      self.abstract_class = true

      def self.inherited(subclass)
        super
        # Apply the database configuration when a model inherits from Base
        return unless Umami::Models.database

        subclass.connects_to database: Umami::Models.database
      end

      def readonly?
        true
      end

      def self.table_name
        "#{Umami::Models.table_prefix}#{super}"
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
