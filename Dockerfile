# --- Stage 1: Builder ---
# This stage is used to install dependencies and build the application.
FROM python:3.9-slim-buster as builder

# Set the working directory inside the builder container
WORKDIR /app

# Copy only the requirements file first to leverage Docker's layer caching.
# If requirements.txt doesn't change, this layer won't be rebuilt.
COPY ./Microservices/requirements.txt .

# Install application dependencies.
# Ensure Flask and Werkzeug versions in requirements.txt are compatible to avoid ImportErrors.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the builder container.
COPY ./Microservices .

# --- Stage 2: Runner ---
# This stage creates the final, lean image for running the application.
# only the necessary artifacts from the 'builder' stage.
FROM python:3.9-alpine as runner

# Set the working directory in the runner container
WORKDIR /app

# Copy the installed Python packages from the builder stage.
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy the application code from the builder stage.
COPY --from=builder /app /app

EXPOSE 5000

# Define the FLASK_APP environment variable, which Flask uses to locate the app.
ENV FLASK_APP=run.py

CMD ["python", "run.py"]