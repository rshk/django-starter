# Django Starter

Sample project to quick-start a django project with common
configuration tweaks and configuration for tools.

**Note:** of course, this is as I like to set things up, and it's
biased towards tools and services I normally use. Others might have
different preferences and use cases.

## Base concepts

- Python 3 (3.5, but 3.4+ should do)
- Django (latest, 1.10 at time of writing)
- PostgreSQL (9.5 at time of writing)
- Docker / docker-compose configuration
- Configuration via environment -> heroku ready

## Steps

**Create and enter some directory**

    mkdir ~/Projects/django-starter
    cd ~/Projects/django-starter

**Create a requirements.txt file**

    django >= 1.10, < 1.11
    dj-database-url
    psycopg2

**Create a .gitignore file**

    *~
    __pycache__
    *.py[cod]
    .env
    .venv*

**Initialize git repo and commit**

    git init
    git add -A
    git commit -m 'Initial commit'

**Create a virtualenv**

    virtualenv --python=/usr/bin/python3.5 --no-site-packages .venv3.5
    source ./.venv3.5/bin/activate

**Install the requirements**

    pip install -r requirements.txt

**Create a project**

    django-admin startproject djstart .

Note: replace ``djstart`` with wathever name you like.

You should now have a directory structure like this:

    .
    ├── djstart
    │   ├── __init__.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── manage.py
    ├── README.md
    └── requirements.txt

**Tweak settings**

```python
# Load database from DATABASE_URL env
import dj_database_url
DATABASES = {
    'default': dj_database_url.config(conn_max_age=600),
}

# MUST be set in the environment, or start will fail
SECRET_KEY = os.environ['SECRET_KEY']
```

**Configure Docker**

A ``Dockerfile`` like this would do to create the base image we need:

```dockerfile
FROM python:3.5.2
ENV PYTHONUNBUFFERED 1
RUN mkdir /tmp/setup/
COPY requirements.txt /tmp/setup/requirements.txt
RUN pip install --upgrade pip
RUN pip install -r /tmp/setup/requirements.txt
RUN rm -rf /tmp/setup
```

And a ``docker-compose.yml`` to launch the app / database containers:

```yaml
version: '2'
services:

  web:
    build: .
    ports:
      - "127.0.0.1:8000:8000"
    volumes:
      - .:/code
    depends_on:
      - postgresdb

    command: "python manage.py runserver 0.0.0.0:8000"
    env_file: .env
    environment:
      DATABASE_URL: postgres://postgres:@postgresdb/djstart
    working_dir: /code

  # WARNING: DO NOT name this just "postgres" or it will cause things
  # to break, for some reason.
  postgresdb:
    image: postgres:9.5
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ''
      POSTGRES_DB: 'djstart'
    volumes:
      - postgresdb-pgdata:/var/lib/postgresql/data

volumes:
  postgresdb-pgdata:
```

**Create .env file**

    echo SECRET_KEY="$( pwgen -y 40 1 )" > .env

**Build docker images**

    docker-compose build

This will take some time if you don't already have the base images
cached in your local docker.

**Start server processes**

    docker-compose up

**Apply migrations**

From another shell, while the database server is running:

    docker-compose run --rm web python manage.py migrate

**Don't forget to commit**

    git add -A
    git commit -m 'Project skeleton'
