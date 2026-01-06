# MySQL Container Management

## Overview
MySQL has been configured with a Docker Compose profile (`database`) to exclude it from normal docker-compose operations. This ensures that MySQL container and image are never deleted or restarted when you run docker-compose commands for the application services.

## Starting MySQL (First Time Only)

To start MySQL container separately (one-time setup):

```bash
# Start MySQL with the database profile
docker-compose --profile database up -d mysql
```

Or if MySQL is already running, you don't need to do anything.

## Starting Application Services (UI, API, Nginx)

### Option 1: Using Helper Scripts

**Windows:**
```bash
start-apps.bat
```

**Linux/Mac:**
```bash
chmod +x start-apps.sh
./start-apps.sh
```

### Option 2: Using Docker Compose Directly

```bash
# Build and start only UI, API, and Nginx
docker-compose up -d --build budget_tracker_production_ui budget_tracker_production_api nginx

# Or without building (if images already exist)
docker-compose up -d budget_tracker_production_ui budget_tracker_production_api nginx
```

### Option 3: Start All Services (Including MySQL)

If you want to start everything including MySQL:

```bash
docker-compose --profile database up -d --build
```

## Common Operations

### Build Only Application Services
```bash
docker-compose build budget_tracker_production_ui budget_tracker_production_api nginx
```

### Restart Only Application Services
```bash
docker-compose restart budget_tracker_production_ui budget_tracker_production_api nginx
```

### Stop Only Application Services
```bash
docker-compose stop budget_tracker_production_ui budget_tracker_production_api nginx
```

### Stop and Remove Only Application Containers
```bash
docker-compose down budget_tracker_production_ui budget_tracker_production_api nginx
```

**Note:** The above command will NOT affect MySQL container.

### View Status
```bash
docker-compose ps
```

## MySQL Management (Separate Commands)

### Check MySQL Status
```bash
docker ps | grep budget_tracker_mysql
```

### Start MySQL (if stopped)
```bash
docker start budget_tracker_mysql
```

### Stop MySQL
```bash
docker stop budget_tracker_mysql
```

### Restart MySQL
```bash
docker restart budget_tracker_mysql
```

### View MySQL Logs
```bash
docker logs -f budget_tracker_mysql
```

### Access MySQL Container
```bash
docker exec -it budget_tracker_mysql mysql -u appuser -papppass expenes_tracker
```

## Important Notes

1. **MySQL Container Must Be Running**: Before starting the API service, ensure the MySQL container (`budget_tracker_mysql`) is running. The API depends on MySQL for database connections.

2. **Network**: All services (including MySQL) are on the same Docker network (`budget_tracker_network`), so they can communicate with each other even if started separately.

3. **Data Persistence**: MySQL data is stored in a Docker volume (`mysql_data`), so data persists even if the container is stopped.

4. **No Dependencies**: The `depends_on` clause has been removed from the API service to allow it to start independently. However, the API will fail to connect if MySQL is not running.

## Troubleshooting

### API Can't Connect to MySQL

1. Check if MySQL container is running:
   ```bash
   docker ps | grep budget_tracker_mysql
   ```

2. If not running, start it:
   ```bash
   docker start budget_tracker_mysql
   ```

3. Check MySQL logs:
   ```bash
   docker logs budget_tracker_mysql
   ```

4. Verify network connectivity:
   ```bash
   docker network inspect budget_tracker_production_docker_compose_budget_tracker_network
   ```

### MySQL Container Not Found

If you need to create the MySQL container for the first time:
```bash
docker-compose --profile database up -d mysql
```

