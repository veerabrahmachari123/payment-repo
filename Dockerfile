# ---------- build stage ----------
FROM python:3.12-slim AS build
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---------- runtime stage ----------
FROM python:3.12-slim

ENV PORT=8080 \
    HOST=0.0.0.0 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ARG APP_VERSION=dev
ARG GIT_COMMIT=unknown
ARG BRANCH_NAME=unknown
ARG BUILD_NUMBER=0

ENV APP_VERSION=$APP_VERSION \
    GIT_COMMIT=$GIT_COMMIT \
    BRANCH_NAME=$BRANCH_NAME \
    BUILD_NUMBER=$BUILD_NUMBER

LABEL org.opencontainers.image.version=$APP_VERSION \
      org.opencontainers.image.revision=$GIT_COMMIT \
      ci.branch=$BRANCH_NAME \
      ci.build=$BUILD_NUMBER

RUN useradd --system --uid 10001 --no-create-home appuser

WORKDIR /app
COPY --from=build /install /usr/local
COPY --chown=appuser:appuser . .
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["python", "-c", \
    "import urllib.request as u; u.urlopen('http://127.0.0.1:8080/health', timeout=2)"]

CMD ["python", "app.py"]