# Scripts

## validate_connection.rb

A validation script to test the umami-read-models gem functionality against a real Umami database.

### Setup

1. Create a `.env` file in the gem root directory:
   ```bash
   DATABASE_URL=postgresql://user:password@host:port/umami_database
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

### Usage

```bash
ruby scripts/validate_connection.rb
```

### What it tests

- Database connectivity
- Model loading
- Basic queries (record counts)
- Associations between models
- Query scopes
- Read-only protection
- Complex analytical queries

The script provides colored output showing pass/fail status for each test.