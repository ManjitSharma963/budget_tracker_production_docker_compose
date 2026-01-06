# Quick Start Guide

## First Time Setup

1. **Start MySQL (one-time setup)**
   ```bash
   docker-compose --profile database up -d mysql
   ```

2. **Start Application Services**
   ```bash
   # Windows
   start-apps.bat
   
   # Linux/Mac
   ./start-apps.sh
   ```

## Daily Operations

### Start Application Services
```bash
docker-compose up -d budget_tracker_production_ui budget_tracker_production_api nginx
```

### Rebuild and Start Application Services
```bash
docker-compose up -d --build budget_tracker_production_ui budget_tracker_production_api nginx
```

### Restart Application Services
```bash
docker-compose restart budget_tracker_production_ui budget_tracker_production_api nginx
```

### Stop Application Services
```bash
docker-compose stop budget_tracker_production_ui budget_tracker_production_api nginx
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f budget_tracker_production_api
```

### Check Status
```bash
docker-compose ps
```

## Important Notes

- ✅ **MySQL is protected**: Running `docker-compose up/down/restart` will NOT affect MySQL
- ✅ **MySQL must be running**: Ensure MySQL container is running before starting the API
- ✅ **Data persists**: MySQL data is stored in a Docker volume and persists across container restarts

## Troubleshooting

**API can't connect to MySQL?**
```bash
# Check if MySQL is running
docker ps | grep budget_tracker_mysql

# Start MySQL if stopped
docker start budget_tracker_mysql
```

For more details, see [MYSQL_MANAGEMENT.md](MYSQL_MANAGEMENT.md)

