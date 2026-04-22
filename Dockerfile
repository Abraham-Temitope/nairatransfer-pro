# ============================ Build stage ============================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# ============================  Runtime stage ============================
FROM python:3.12-slim

WORKDIR /app

# copy only the necessary files/packages from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

# copy the application code
COPY app/ app/

# Created a non-root user for security
RUN useradd -u 1001 -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Health check for ECS
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1


CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
