# syntax=docker/dockerfile:1
FROM python:3.12-alpine as python-base
LABEL maintainer="You <your@email.com>"

# Some flags from https://bmaingret.github.io/blog/2021-11-15-Docker-and-Poetry
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VERSION=1.8.2 \
    POETRY_VIRTUALENVS_OPTIONS_NO_PIP=true \
    POETRY_HOME="/opt/poetry" \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Grab security updates
WORKDIR $PYSETUP_PATH
COPY ./scripts/docker-base-alpine.sh docker-base-alpine.sh
RUN chmod +x ./docker-base-alpine.sh && ./docker-base-alpine.sh && rm ./docker-base-alpine.sh

# Dependency installation
FROM python-base as poetry-base
LABEL maintainer="You <your@email.com>"

WORKDIR $PYSETUP_PATH
# hadolint ignore=DL3018
RUN apk add --no-cache poetry

COPY /poetry.lock /pyproject.toml ./
RUN --mount=type=cache,target=/root/.cache \
    poetry install --only main --no-root --no-directory -n


# Runtime
FROM python-base as tns-api
LABEL maintainer="You <your@email.com>"

COPY --from=poetry-base $PYSETUP_PATH $PYSETUP_PATH

WORKDIR /api

# TODO evaluate using non-root user
COPY ./api .
COPY ./scripts /scripts
RUN chmod -R +x /scripts

# 27JUN22 updated from https://pythonspeed.com/articles/gunicorn-in-docker/
ENTRYPOINT ["/scripts/entrypoint.sh"]
