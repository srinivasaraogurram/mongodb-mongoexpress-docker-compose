FROM mongo:latest

# Install additional tools (optional)
RUN apt-get update && apt-get install -y \
    curl \
    vim

# Set the working directory
WORKDIR /workspace

# Copy initialization script (optional)
COPY ../mongo-init.js /docker-entrypoint-initdb.d/mongo-init.js
