#!/bin/bash
# Start only UI, API, and Nginx services (excludes MySQL)
# MySQL container should already be running separately

echo "Starting application services (UI, API, Nginx)..."
docker-compose up -d --build budget_tracker_production_ui budget_tracker_production_api nginx

echo ""
echo "Services started. MySQL container should be running separately."
echo "To check status: docker-compose ps"

