# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2024-01-26

### Fixed
- Removed non-functional table prefix feature that was documented but didn't work
- Fixed database connection configuration to properly work with Rails multi-database
- Enhanced read-only protection to prevent all write operations (create, update, delete)
- Fixed SQL injection vulnerability in README raw SQL example
- Updated documentation to accurately reflect actual gem functionality

### Changed
- Simplified database configuration to use standard Rails patterns
- Improved error messages for read-only violations
- Database configuration now properly converts simple symbols to Rails multi-db format

### Removed
- Removed broken `table_prefix` configuration option
- Removed misleading "thread-safe connection management" claim

## [0.1.0] - 2024-01-26

### Added
- Initial release of umami-read-models gem
- Read-only ActiveRecord models for all Umami database tables
- Support for PostgreSQL connections
- Rails multi-database support with external configuration
- Comprehensive query scopes for analytics queries
- Full association mappings between models
- Configurable table prefix support
- Thread-safe connection management
- Documentation and usage examples
