# Budget Tracker Application - Access Guide

## 🚀 Application Status

All Docker containers are running successfully!

## 📍 Access URLs

### **Main Entry Point (Recommended)**
- **URL**: `http://localhost`
- **Description**: Access through Nginx reverse proxy
  - UI: `http://localhost/`
  - API: `http://localhost/api`

### **Direct Service Access**

#### Frontend (React UI)
- **URL**: `http://localhost:3000`
- **Description**: Direct access to the React.js frontend application
- **Status**: ✅ Running

#### Backend API (Spring Boot)
- **URL**: `http://localhost:8081`
- **Description**: Direct access to the Spring Boot REST API
- **Status**: ✅ Running
- **Health Check**: `http://localhost:8081/actuator/health`

#### Database (MySQL)
- **Host**: `localhost`
- **Port**: `3306`
- **Database**: `expenes_tracker`
- **Username**: `appuser`
- **Password**: `apppass`
- **Root Password**: `root123`
- **Status**: ✅ Running

## 🔧 Container Management

### View Container Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f budget_tracker_production_api
docker-compose logs -f budget_tracker_production_ui
docker-compose logs -f mysql
docker-compose logs -f nginx
```

### Stop All Services
```bash
docker-compose down
```

### Restart All Services
```bash
docker-compose restart
```

### Stop and Remove Volumes (Clean Slate)
```bash
docker-compose down -v
```

## 📊 Service Details

### Container Names
- `budget_tracker_mysql` - MySQL Database
- `budget_tracker_api` - Spring Boot API
- `budget_tracker_ui` - React.js Frontend
- `budget_tracker_nginx` - Nginx Reverse Proxy

### Network
- All services are on the `budget_tracker_network` bridge network
- Services can communicate using container names as hostnames

## 🔍 Troubleshooting

### Check if services are running
```bash
docker-compose ps
```

### Check service health
```bash
# API Health
curl http://localhost:8081/actuator/health

# Nginx Health
curl http://localhost/health
```

### View specific service logs
```bash
docker-compose logs [service_name]
```

### Restart a specific service
```bash
docker-compose restart [service_name]
```

### Rebuild and restart
```bash
docker-compose up -d --build
```

## 📝 Notes

- The API is accessible on port **8081** (host) instead of 8080 due to a port conflict
- Internally, the API still runs on port 8080 within the container
- Nginx routes `/api` requests to the Spring Boot API
- All other requests are routed to the React UI
- MySQL data is persisted in a Docker volume (`mysql_data`)

## ✅ Verification

To verify everything is working:

1. **Check UI**: Open `http://localhost:3000` or `http://localhost` in your browser
2. **Check API**: Visit `http://localhost:8081/actuator/health` - should return health status
3. **Check Nginx**: Visit `http://localhost` - should show the React app
4. **Check Database**: Connect using MySQL client with credentials above

---

**Last Updated**: Services are running and accessible!

