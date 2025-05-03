#!/bin/bash
set -e

# Start your main application
python /app/app.py &

cron -f