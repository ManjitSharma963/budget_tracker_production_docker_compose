# Nginx Reverse Proxy
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Remove default nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Expose ports
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

