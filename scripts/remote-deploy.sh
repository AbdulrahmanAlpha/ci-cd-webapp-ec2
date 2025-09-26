#!/usr/bin/env bash
set -euo pipefail

# Usage: remote-deploy.sh <image> <health_url> <app_port>
# Example: ./remote-deploy.sh 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:sha256-1234 http://localhost:3000/health 3000

IMAGE="$1"
HEALTHURL="$2"
APP_PORT="${3:-3000}"
APP_NAME="ci-cd-webapp"

log() { echo "[$(date -u +"%F %T")] $*"; }

# create a directory to persist previous image tag
STATE_DIR="/home/ubuntu/deploy_state"
mkdir -p "$STATE_DIR"

PREV_FILE="$STATE_DIR/prev_image"
PREV_IMAGE=""
if [ -f "$PREV_FILE" ]; then
  PREV_IMAGE=$(cat "$PREV_FILE")
fi

log "Pulling new image: $IMAGE"
docker pull "$IMAGE"

# run new container temporarily
TMP_NAME="${APP_NAME}-new"
OLD_NAME="${APP_NAME}-old"
RUN_ARGS=(--detach --restart unless-stopped --name "$TMP_NAME" -p "127.0.0.1:${APP_PORT}:${APP_PORT}" "$IMAGE")

# stop and rename existing container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
  log "Stopping existing container ${APP_NAME}"
  docker rename "$APP_NAME" "$OLD_NAME" || true
  docker stop "$OLD_NAME" || true
fi

# start new container
log "Starting new container ${TMP_NAME}"
docker run "${RUN_ARGS[@]}"

# wait for healthcheck (max 30s)
log "Waiting for healthcheck at $HEALTHURL"
SUCCESS=1
for i in $(seq 1 30); do
  if curl -fsS "$HEALTHURL" >/dev/null 2>&1; then
    SUCCESS=0
    break
  fi
  sleep 1
done

if [ "$SUCCESS" -eq 0 ]; then
  log "New container healthy. Finalizing swap..."
  # remove old container and rename new to app name
  docker rm -f "${OLD_NAME}" >/dev/null 2>&1 || true
  docker rename "$TMP_NAME" "$APP_NAME" || true
  echo "$IMAGE" > "$PREV_FILE"
  log "Deployment successful: $IMAGE"
  exit 0
else
  log "Healthcheck failed. Rolling back..."
  # stop and remove new container
  docker rm -f "$TMP_NAME" >/dev/null 2>&1 || true
  # restore old container (if exists)
  if [ -n "$PREV_IMAGE" ]; then
    log "Pulling previous image $PREV_IMAGE and restoring..."
    docker pull "$PREV_IMAGE" || true
    docker run --detach --restart unless-stopped --name "$APP_NAME" -p "127.0.0.1:${APP_PORT}:${APP_PORT}" "$PREV_IMAGE" || true
  fi
  log "Rollback complete."
  exit 2
fi
