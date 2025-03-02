#!/bin/bash

echo "🔍 Scanning running Docker containers with their ports..."

# Get list of running containers with port mappings
RUNNING_CONTAINERS=$(docker ps --format "{{.ID}} {{.Image}} {{.Names}} {{.Ports}}")

if [ -z "$RUNNING_CONTAINERS" ]; then
  echo "✅ No running Docker containers found."
  exit 0
fi

echo "🚀 Running Containers:"
echo "---------------------------------------------------------------------------------------------"
printf "%-20s %-30s %-20s %-30s\n" "CONTAINER ID" "IMAGE" "NAME" "PORT(S)"
echo "---------------------------------------------------------------------------------------------"

# Display container details
while read -r CONTAINER_ID IMAGE NAME PORTS; do
  printf "%-20s %-30s %-20s %-30s\n" "$CONTAINER_ID" "$IMAGE" "$NAME" "$PORTS"
done <<< "$RUNNING_CONTAINERS"

echo "---------------------------------------------------------------------------------------------"

# Ask user if they want to shut down containers
read -p "❓ Do you want to gracefully stop all running containers? (y/n): " RESPONSE

if [[ "$RESPONSE" == "y" || "$RESPONSE" == "Y" ]]; then
  echo "🛑 Stopping all running containers gracefully..."
  docker stop $(docker ps -q)
  echo "✅ All containers stopped successfully."
else
  echo "❌ No containers were stopped."
fi
