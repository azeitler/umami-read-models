#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to validate umami-read-models gem functionality
# Usage: ruby scripts/validate_connection.rb
# Requires: DATABASE_URL environment variable

require "bundler/setup"
require "umami/models"
require "active_record"
require "dotenv/load"
require "uri"

# Colors for output
class String
  def green = "\e[32m#{self}\e[0m"
  def red = "\e[31m#{self}\e[0m"
  def yellow = "\e[33m#{self}\e[0m"
  def blue = "\e[34m#{self}\e[0m"
end

puts "Umami Read Models - Connection Validation".blue
puts "=" * 50

# Check for DATABASE_URL
unless ENV["DATABASE_URL"]
  puts "ERROR: DATABASE_URL not found in environment".red
  puts "Please create a .env file with:"
  puts "DATABASE_URL=postgresql://user:password@host:port/database"
  exit 1
end

puts "✓ DATABASE_URL found".green

# Since we're using DATABASE_URL directly, we don't need Rails database config
# Just use the default connection
ActiveRecord::Base.establish_connection(ENV.fetch("DATABASE_URL", nil))

# Test configuration - skip this since we're not in a Rails app with named databases
puts "\n1. Testing database connection...".yellow
begin
  ActiveRecord::Base.connection.execute("SELECT 1")
  puts "✓ Database connection working".green
rescue StandardError => e
  puts "✗ Database connection failed: #{e.message}".red
  exit 1
end

# Test Rails-style configuration (for use in Rails apps)
puts "\n2. Testing Rails-style database configuration...".yellow
begin
  # Parse the DATABASE_URL to get connection parameters
  uri = URI.parse(ENV.fetch("DATABASE_URL", nil))
  db_config_hash = {
    adapter: uri.scheme == "postgres" ? "postgresql" : uri.scheme,
    host: uri.host,
    port: uri.port || 5432,
    database: uri.path[1..], # Remove leading slash
    username: uri.user,
    password: uri.password
  }

  # Add any query parameters (like sslmode, channel_binding, etc.)
  if uri.query
    URI.decode_www_form(uri.query).each do |key, value|
      db_config_hash[key.to_sym] = value
    end
  end

  # Create the configuration using the current environment
  current_env = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call
  db_config = ActiveRecord::DatabaseConfigurations::HashConfig.new(
    current_env,
    "umami",
    db_config_hash
  )

  # Register this configuration
  ActiveRecord::Base.configurations = {
    current_env => { "umami" => db_config.configuration_hash }
  }

  # Now test the gem's configuration
  Umami::Models.configure do |config|
    config.database = :umami
  end

  # Verify it works by testing a query
  Umami::Models::Website.connection.execute("SELECT 1")
  puts "✓ Rails-style configuration working".green
  puts "  (In a Rails app, use: config.database = :umami)".green

  # Also test multi-database configuration
  Umami::Models.configure do |config|
    config.database = { writing: :umami, reading: :umami }
  end
  Umami::Models::Website.connection.execute("SELECT 1")
  puts "✓ Multi-database configuration also works".green
  puts "  (For read replicas: { writing: :umami, reading: :umami_replica })".green
rescue StandardError => e
  puts "✗ Rails-style configuration failed: #{e.message}".red
  puts "  Note: This is optional - direct DATABASE_URL connection still works".yellow
end

# Test model loading
puts "\n3. Testing model loading...".yellow
models = [
  Umami::Models::User,
  Umami::Models::Website,
  Umami::Models::Session,
  Umami::Models::WebsiteEvent,
  Umami::Models::EventData,
  Umami::Models::SessionData,
  Umami::Models::Team,
  Umami::Models::TeamUser,
  Umami::Models::Report
]

models.each do |model|
  puts "   ✓ #{model.name} loaded".green
end

# Test basic queries
puts "\n4. Testing basic queries...".yellow
begin
  # Count records
  puts "   Users: #{Umami::Models::User.count}"
  puts "   Websites: #{Umami::Models::Website.count}"
  puts "   Sessions: #{Umami::Models::Session.count}"
  puts "   Events: #{Umami::Models::WebsiteEvent.count}"
  puts "✓ Basic queries working".green
rescue StandardError => e
  puts "✗ Query failed: #{e.message}".red
  puts "  Make sure the Umami database schema is set up correctly".yellow
end

# Test associations
puts "\n4. Testing associations...".yellow
begin
  if (website = Umami::Models::Website.first)
    puts "   Testing website: #{website.name || "Unnamed"}"
    puts "   - Sessions count: #{website.sessions.count}"
    puts "   - Events count: #{website.website_events.count}"
    puts "   - Has user: #{website.user ? "Yes" : "No"}"
    puts "✓ Associations working".green
  else
    puts "   No websites found to test associations".yellow
  end
rescue StandardError => e
  puts "✗ Association test failed: #{e.message}".red
end

# Test scopes
puts "\n5. Testing scopes...".yellow
begin
  # Test various scopes
  puts "   Active websites: #{Umami::Models::Website.active.count}"
  puts "   Recent sessions: #{Umami::Models::Session.recent.limit(5).count}"
  puts "   Page views: #{Umami::Models::WebsiteEvent.page_views.count}"
  puts "✓ Scopes working".green
rescue StandardError => e
  puts "✗ Scope test failed: #{e.message}".red
end

# Test read-only protection
puts "\n6. Testing read-only protection...".yellow
begin
  # Test create
  begin
    user = Umami::Models::User.new(username: "test")
    user.save!
    puts "✗ ERROR: Create should have been blocked!".red
  rescue ActiveRecord::ReadOnlyRecord => e
    puts "   ✓ Create blocked: #{e.message}".green
  end

  # Test update
  if (user = Umami::Models::User.first)
    begin
      user.update!(username: "changed")
      puts "✗ ERROR: Update should have been blocked!".red
    rescue ActiveRecord::ReadOnlyRecord => e
      puts "   ✓ Update blocked: #{e.message}".green
    end

    # Test delete
    begin
      user.destroy!
      puts "✗ ERROR: Delete should have been blocked!".red
    rescue ActiveRecord::ReadOnlyRecord => e
      puts "   ✓ Delete blocked: #{e.message}".green
    end
  else
    puts "   No users found to test update/delete protection".yellow
  end
rescue StandardError => e
  puts "✗ Read-only test failed: #{e.message}".red
end

# Test complex queries
puts "\n7. Testing complex queries...".yellow
begin
  # Get top pages for the last 30 days
  if (website = Umami::Models::Website.first)
    top_pages = Umami::Models::WebsiteEvent
                .by_website(website.website_id)
                .page_views
                .by_date_range(30.days.ago, Time.current)
                .group(:url_path)
                .order("count_all DESC")
                .limit(5)
                .count

    puts "   Top 5 pages (last 30 days):"
    top_pages.each do |path, count|
      puts "   - #{path}: #{count} views"
    end
    puts "✓ Complex queries working".green if top_pages.any?
    puts "   No page views in the last 30 days".yellow if top_pages.empty?
  else
    puts "   No websites found for complex query test".yellow
  end
rescue StandardError => e
  puts "✗ Complex query failed: #{e.message}".red
end

puts "\n#{"=" * 50}"
puts "Test completed!".blue
