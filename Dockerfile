# The builder image, used to build the virtual environment
FROM python:3.11-buster as builder

RUN apt-get update && apt-get install -y git

RUN pip install poetry==1.4.2

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

# A directory to have app data
# WORKDIR /app              #v1.0.0 app -> graph_rag
WORKDIR /graph_rag

COPY pyproject.toml poetry.lock ./


RUN poetry install --without dev --no-root && rm -rf $POETRY_CACHE_DIR


# The runtime image, used to just run the code provided its virtual environment
FROM python:3.11-slim-buster as runtime

# ENV VIRTUAL_ENV=/app/.venv \
#     PATH="/app/.venv/bin:$PATH"

#v1.0.0 app -> graph_rag
ENV VIRTUAL_ENV=/graph_rag/.venv \
    PATH="/graph_rag/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./graph_rag ./graph_rag



CMD ["streamlit", "run", "graph_rag/app.py", "--server.port", "8052"]

