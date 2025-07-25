FROM python:3.9-slim-buster

#Set the working directory in the container
WORKDIR /app

COPY ./Microservices/requirements.txt .

#Install packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

#Copy the application code into the container at /app
COPY ./Microservices .


EXPOSE 5000

ENV FLASK_APP=run.py

CMD ["python", "run.py"]