# ---------- build stage: install dependencies ----------
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

# Non-root user
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