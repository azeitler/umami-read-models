# Umami::Models

A Ruby gem that provides read-only ActiveRecord models for accessing Umami Analytics data directly from Rails applications. This gem allows you to query Umami's database directly for analytics data, reports, and user information.

## Features

- Read-only ActiveRecord models for all Umami database tables
- Support for PostgreSQL connections
- Built-in query scopes for common analytics queries
- Association mappings between models
- Configurable table prefix support
- Thread-safe connection management

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'umami-read-models'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install umami-read-models

## Configuration

### Setup with Rails Multi-Database Support

This gem is designed to work with Rails 6+ multiple database support. Configure your database in `config/database.yml`:

```yaml
# config/database.yml
production:
  primary:
    # Your main Rails database configuration
  umami:
    adapter: postgresql
    host: <%= ENV['UMAMI_DB_HOST'] %>
    port: <%= ENV['UMAMI_DB_PORT'] || 5432 %>
    database: <%= ENV['UMAMI_DB_NAME'] %>
    username: <%= ENV['UMAMI_DB_USER'] %>
    password: <%= ENV['UMAMI_DB_PASSWORD'] %>
```

Then configure the gem in an initializer (e.g., `config/initializers/umami_read_models.rb`):

```ruby
Umami::Models.configure do |config|
  # Specify which database configuration to use
  config.database = :umami
  
  # Optional: Set a table prefix if your Umami tables use one
  config.table_prefix = "umami_"
end
```

### Advanced Multi-Database Configuration

For read replicas:

```ruby
Umami::Models.configure do |config|
  config.database = { writing: :umami, reading: :umami_replica }
end
```

This uses Rails' built-in database roles where:
- `:writing` - Used for write operations (INSERT, UPDATE, DELETE)
- `:reading` - Used for read operations (SELECT)

## Usage

### Available Models

- `Umami::Models::User` - Umami users
- `Umami::Models::Website` - Tracked websites
- `Umami::Models::Session` - Visitor sessions
- `Umami::Models::WebsiteEvent` - Page views and custom events
- `Umami::Models::EventData` - Custom event data
- `Umami::Models::SessionData` - Session metadata
- `Umami::Models::Team` - Teams
- `Umami::Models::TeamUser` - Team memberships
- `Umami::Models::Report` - Saved reports

### Basic Queries

```ruby
# Get all websites
websites = Umami::Models::Website.all

# Get active websites for a user
user_websites = Umami::Models::Website
  .active
  .by_user(user_id)

# Get recent sessions for a website
recent_sessions = Umami::Models::Session
  .by_website(website_id)
  .recent
  .limit(100)

# Get page views for the last 7 days
page_views = Umami::Models::WebsiteEvent
  .by_website(website_id)
  .page_views
  .by_date_range(7.days.ago, Time.current)
```

### Working with Sessions

```ruby
# Get sessions by browser
chrome_sessions = Umami::Models::Session
  .by_website(website_id)
  .by_browser('Chrome')
  .by_date_range(start_date, end_date)

# Get sessions by country
us_sessions = Umami::Models::Session
  .by_website(website_id)
  .by_country('US')

# Get session with events
session = Umami::Models::Session.find(session_id)
events = session.website_events.page_views
```

### Working with Events

```ruby
# Get custom events
custom_events = Umami::Models::WebsiteEvent
  .by_website(website_id)
  .custom_events
  .by_event_name('button_click')

# Get events with UTM parameters
campaign_events = Umami::Models::WebsiteEvent
  .by_website(website_id)
  .with_utm_campaign('summer_sale')

# Get event data
event = Umami::Models::WebsiteEvent.find(event_id)
event_data = event.event_data
```

### Analytics Queries

```ruby
# Get unique visitors (sessions) by day
daily_visitors = Umami::Models::Session
  .by_website(website_id)
  .group("DATE(created_at)")
  .count

# Get top pages
top_pages = Umami::Models::WebsiteEvent
  .by_website(website_id)
  .page_views
  .group(:url_path)
  .order('count_all DESC')
  .limit(10)
  .count

# Get referrer domains
referrers = Umami::Models::WebsiteEvent
  .by_website(website_id)
  .where.not(referrer_domain: nil)
  .group(:referrer_domain)
  .order('count_all DESC')
  .count

# Get browser statistics
browser_stats = Umami::Models::Session
  .by_website(website_id)
  .group(:browser)
  .count
```

### Working with Reports

```ruby
# Get user reports
user_reports = Umami::Models::Report
  .by_user(user_id)
  .recent

# Get report with parsed parameters
report = Umami::Models::Report.find(report_id)
params = report.parsed_parameters
```

## Read-Only Protection

All models are read-only by default. Any attempt to create, update, or delete records will fail:

```ruby
# This will raise an error
website = Umami::Models::Website.new(name: "Test")
website.save # => raises ActiveRecord::ReadOnlyRecord

# This will also raise an error
Umami::Models::Website.find(id).update(name: "New Name")
```

## Advanced Usage

### Custom Queries

You can use all ActiveRecord query methods:

```ruby
# Complex query example
Umami::Models::WebsiteEvent
  .joins(:session)
  .where(website_id: website_id)
  .where(sessions: { country: 'US' })
  .where(created_at: 30.days.ago..Time.current)
  .group(:url_path)
  .having('COUNT(*) > ?', 100)
  .pluck(:url_path, 'COUNT(*)')
```

### Raw SQL

For complex analytics queries, you can use raw SQL:

```ruby
results = Umami::Models::Base.connection.execute(<<-SQL)
  SELECT 
    DATE(created_at) as date,
    COUNT(DISTINCT session_id) as visitors,
    COUNT(*) as page_views
  FROM website_event
  WHERE website_id = '#{website_id}'
    AND created_at >= '#{30.days.ago}'
  GROUP BY DATE(created_at)
  ORDER BY date DESC
SQL
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/azeitler/umami-read-models.