# Budget Tracker Production Docker Compose

This project contains Docker configurations for a production-ready budget tracker application with the following services:

- **budget_tracker_production_ui**: React.js frontend application (cloned from GitHub)
- **budget_tracker_production_api**: Spring Boot backend API service (cloned from GitHub)
- **mysql**: MySQL 8.0 database
- **nginx**: Reverse proxy and load balancer

## Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Git

## Project Structure

```
.
├── budget_tracker_production_ui/
│   ├── Dockerfile
│   └── .dockerignore
├── budget_tracker_production_api/
│   ├── Dockerfile
│   └── .dockerignore
├── mysql/
│   ├── Dockerfile
│   └── init.sql
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── docker-compose.yml
├── .env.example
└── README.md
```

## Getting Started

1. **Clone and navigate to the project directory**

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your production values.

3. **Build and start all services**
   ```bash
   docker-compose up -d --build
   ```

4. **View logs**
   ```bash
   docker-compose logs -f
   ```

5. **Stop all services**
   ```bash
   docker-compose down
   ```

6. **Stop and remove volumes (clean slate)**
   ```bash
   docker-compose down -v
   ```

## Service Ports

- **Nginx**: `http://localhost:80` (main entry point)
- **UI**: `http://localhost:3000` (direct access)
- **API**: `http://localhost:8080` (direct access - Spring Boot)
- **MySQL**: `localhost:3306`

## Environment Variables

The Docker Compose file uses the following default values (can be overridden with `.env` file):

- `MYSQL_ROOT_PASSWORD`: Root password for MySQL (default: `root123`)
- `MYSQL_DATABASE`: Database name (default: `expenes_tracker`)
- `MYSQL_USER`: Database user (default: `appuser`)
- `MYSQL_PASSWORD`: Database user password (default: `apppass`)

The Spring Boot API is configured with:
- Database URL: `jdbc:mysql://mysql:3306/expenes_tracker?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true`
- Database User: `appuser`
- Database Password: `apppass`
- Server Port: `8080`

## Development

### Building individual services

```bash
# Build UI
docker build -t budget_tracker_ui ./budget_tracker_production_ui

# Build API
docker build -t budget_tracker_api ./budget_tracker_production_api

# Build MySQL
docker build -t budget_tracker_mysql ./mysql

# Build Nginx
docker build -t budget_tracker_nginx ./nginx
```

### Running individual services

```bash
# Run MySQL
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=expenes_tracker -e MYSQL_USER=appuser -e MYSQL_PASSWORD=apppass mysql:8.0

# Run API (Spring Boot)
docker run -d --name api --link mysql -p 8080:8080 -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/expenes_tracker?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true" -e SPRING_DATASOURCE_USERNAME=appuser -e SPRING_DATASOURCE_PASSWORD=apppass budget_tracker_api

# Run UI
docker run -d --name ui -p 8080:80 budget_tracker_ui

# Run Nginx
docker run -d --name nginx --link api --link ui -p 80:80 budget_tracker_nginx
```

## Notes

- **UI Repository**: The React UI is automatically cloned from `https://github.com/ManjitSharma963/budget_tracker_production_ui.git` during build
- **API Repository**: The Spring Boot API is automatically cloned from `https://github.com/ManjitSharma963/budget_tracker_production_api.git` during build
- The MySQL data is persisted in a Docker volume (`mysql_data`)
- The Nginx configuration routes `/api` requests to the API service (port 8080) and all other requests to the UI service
- Health checks are configured for MySQL and API services
- All services are on a custom bridge network for isolation
- Spring Boot will automatically create the database schema on first startup

## Troubleshooting

1. **Check service status**
   ```bash
   docker-compose ps
   ```

2. **View service logs**
   ```bash
   docker-compose logs [service_name]
   ```

3. **Restart a specific service**
   ```bash
   docker-compose restart [service_name]
   ```

4. **Rebuild a specific service**
   ```bash
   docker-compose up -d --build [service_name]
   ```

