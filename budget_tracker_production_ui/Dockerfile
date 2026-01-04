# Multi-stage build for production UI
FROM node:18-alpine AS builder

# Install git for cloning
RUN apk add --no-cache git

WORKDIR /app

# Clone the React UI repository
RUN git clone https://github.com/ManjitSharma963/budget_tracker_production_ui.git .

# Install all dependencies
RUN npm install

# Build the React application
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

