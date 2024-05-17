# syntax=docker/dockerfile:1
FROM python:3.12-alpine as python-base
LABEL maintainer="You <your@email.com>"

# Some flags from https://bmaingret.github.io/blog/2021-11-15-Docker-and-Poetry
ENV PYTHONDONTWRITEBYTECODE=1
ENV POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VERSION=1.8.2 \
    POETRY_VIRTUALENVS_OPTIONS_NO_PIP=true \
    POETRY_VIRTUALENVS_OPTIONS_NO_SETUPTOOLS=true \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$VENV_PATH/bin:$PATH"

# Grab security updates
WORKDIR $PYSETUP_PATH
COPY ./scripts/docker-base-alpine.sh docker-base-alpine.sh
RUN ./docker-base-alpine.sh

# Dependency installation
FROM python-base as poetry-base
LABEL maintainer="You <your@email.com>"

WORKDIR $PYSETUP_PATH
# hadolint ignore=DL3018
RUN apk add --no-cache poetry

# Install project dependencies
COPY /poetry.lock /pyproject.toml ./
RUN --mount=type=cache,target=/root/.cache \
    poetry install --only main --no-root --no-directory -n

FROM python-base as tns-api
LABEL maintainer="You <your@email.com>"
COPY --from=poetry-base $VENV_PATH $VENV_PATH

WORKDIR /api
COPY ./api .
COPY ./scripts /scripts

ENTRYPOINT ["/scripts/entrypoint.sh"]
