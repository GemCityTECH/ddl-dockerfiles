# DDL Dockerfiles

This repository is for support of a talk at Momentum DevCon 2024 about writing Dockerfiles to optimize for velocity.

## Prerequisites

Python 3.12, Poetry, and Docker

## How to run

### From the command line

```bash
poetry shell
poetry install
cd api
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Using Docker

```bash
docker build -f Dockerfile_0 -t image_0 .
docker run -p 8000:8000 image_0
```

### Using Docker Compose

Edit `compose.yaml` to point to the Dockerfile you wish to target.

```bash
docker-compose up --build
```
