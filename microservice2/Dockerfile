FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
RUN chmod +x /app/entrypoint.sh

# Install cron
RUN apt-get update && apt-get install -y cron

# Create a cron job file every minute
RUN echo "* * * * * python /app/app.py" > /etc/cron.d/sqs_backup
RUN chmod 0644 /etc/cron.d/sqs_backup

# Apply cron job
RUN crontab /etc/cron.d/sqs_backup

# Start the entrypoint script
CMD ["/app/entrypoint.sh"]
