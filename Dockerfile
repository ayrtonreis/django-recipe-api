FROM python:3.9-alpine3.13
LABEL maintainer="ayrton"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# it creates a new image layer for every command that we run!
RUN python -m venv /py && \
        /py/bin/pip install --upgrade pip && \
        apk add --update --no-cache postgresql-client && \
        apk add --update --no-cache --virtual .tmp-build-deps \
          build-base postgresql-dev musl-dev && \
        /py/bin/pip install -r /tmp/requirements.txt && \
        if [ $DEV = "true" ]; \
          then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
        fi && \
        rm -rf /tmp && \
        apk del .tmp-build-deps && \
        adduser \
            --disabled-password \
            --no-create-home \
            django-user

# contains the directories where executables can be run
ENV PATH="/py/bin:$PATH"

# Up to this point, everything was ran using the root user
USER django-user
