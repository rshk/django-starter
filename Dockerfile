FROM python:3.5.2
ENV PYTHONUNBUFFERED 1
RUN mkdir /tmp/setup/
COPY requirements.txt /tmp/setup/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /tmp/setup/requirements.txt
RUN rm -rf /tmp/setup
