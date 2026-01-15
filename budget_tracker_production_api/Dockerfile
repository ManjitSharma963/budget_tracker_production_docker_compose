# Multi-stage build for Spring Boot API
FROM maven:3.8.7-eclipse-temurin-17 AS builder

# Install git for cloning
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Remove any existing files to ensure fresh clone
RUN rm -rf /app/* /app/.[!.]* /app/..?* 2>/dev/null || true

# Clone the Spring Boot API repository (fresh clone)
RUN git clone https://github.com/ManjitSharma963/budget_tracker_production_api.git .

# Clean and build the Spring Boot application (removes old JARs)
RUN mvn clean package -DskipTests

# Production stage
FROM eclipse-temurin:17-jre-alpine

# Install wget for health checks
RUN apk add --no-cache wget

WORKDIR /app

# Remove any existing JAR files to ensure fresh copy
RUN rm -f app.jar *.jar 2>/dev/null || true

# Copy the built JAR file from builder (only the latest built JAR)
COPY --from=builder /app/target/*.jar app.jar

# Create non-root user
RUN addgroup -g 1001 -S springboot && \
    adduser -S springboot -u 1001

USER springboot

# Expose port (Spring Boot default is 8080)
EXPOSE 8080

# Health check (using wget or curl if available)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health 2>/dev/null || wget --no-verbose --tries=1 --spider http://localhost:8080/health 2>/dev/null || exit 1

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]

