#!/bin/bash
set -e

# Start cron service in the background
cron -f &

# Start your main application
python /app/app.py