FROM python:3.9-alpine3.13
LABEL maintainer="ashuachua.com"

ENV PYTHONUNBUFFERED 1 


COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000


ARG DEV=false
RUN python -m venv /py && \
    #upgrade pip
    /py/bin/pip install --upgrade pip && \
    # Install postgresql client, its an adapter for psycopg2 to connect to postgresql
    apk add --update --no-cache postgresql-client && \
    # this set a virtual dependecies packages
    apk add --update --no-cache --virtual .tmp-build-deps \
    # the packages needed are listed below
        build-base postgresql-dev musl-dev && \
    #install dependencies from requirements.txt
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    #remove tmp directory, to remove all dependencies once created, to save space
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    #call add user to create user, so dat we dont use the root user
    adduser \ 
        #we dont want people to use a password to use our container
        --disabled-password \
        --no-create-home \
        #to create a name for the user
        django-user

#define path of our variable, so we dont need to specify py/bin
ENV PATH="/py/bin:$PATH"

#set user
USER django-user