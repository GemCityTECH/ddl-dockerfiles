#!/bin/sh

echo "Environment: $ENV"

# Start the API in the background
if [ "$ENV" == "local" ]; then
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
else
    uvicorn main:app --host 0.0.0.0 --port 8000 &
fi

APP_PID=$!

# Wait for the API to be up and ready.
while [ "$(wget --server-response -O /dev/null http://localhost:8000/ 2>&1 | awk '/^  HTTP/{print $2}')" != "200" ]; do
    sleep 0.3;
done

# Bring the FastAPI process back into the foreground
wait $APP_PID
