# MySQL Database
FROM mysql:8.0

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=root123
ENV MYSQL_DATABASE=expenses_tracker
ENV MYSQL_USER=appuser
ENV MYSQL_PASSWORD=apppass

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/

# Expose MySQL port
EXPOSE 3306

# Use default MySQL entrypoint

