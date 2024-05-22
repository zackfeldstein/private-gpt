FROM python:3.11.6-slim-bookworm as base

# Install poetry
RUN pip install pipx
RUN python3 -m pipx ensurepath
RUN pipx install poetry
ENV PATH="/root/.local/bin:$PATH"
ENV PATH=".venv/bin/:$PATH"
ENV PGPT_PROFILES=ollama

# https://python-poetry.org/docs/configuration/#virtualenvsin-project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

RUN addgroup --gid 1000 worker && adduser --uid 1000 --ingroup worker --disabled-password --gecos "" worker


FROM base as dependencies
WORKDIR /home/worker/app
COPY pyproject.toml poetry.lock ./


RUN apt-get update && apt-get install -y \
  make \ 
  libopenblas-dev \
  ninja-build \
  build-essential \
  pkg-config \
  wget \
  g++ \
  cmake
#RUN poetry install --extras "ui vector-stores-qdrant llms-ollama embeddings-ollama llms-llama-cpp"
RUN poetry lock --no-update
RUN poetry install --extras "ui llms-ollama embeddings-ollama vector-stores-qdrant sqlalchemy psycopg2-binary asyncpg vector-stores-postgres llms-llama-cpp "

FROM base as app



ENV PYTHONUNBUFFERED=1
ENV PORT=8001
EXPOSE 8001

# Prepare a non-root user
#RUN adduser --system worker
WORKDIR /home/worker/app

RUN mkdir local_data; chown worker local_data
RUN mkdir models; chown worker models
COPY --chown=worker --from=dependencies /home/worker/app/.venv/ .venv
COPY --chown=worker private_gpt/ private_gpt
COPY --chown=worker fern/ fern
COPY --chown=worker *.yaml *.md ./
COPY --chown=worker scripts/ scripts

ENV PYTHONPATH="$PYTHONPATH:/private_gpt/"

USER root
ENTRYPOINT python -m private_gpt

