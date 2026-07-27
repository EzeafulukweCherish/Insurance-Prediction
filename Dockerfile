# ---- Dockerfile for the Insurance Charge Predictor (FastAPI app) ----
FROM python:3.7-slim

WORKDIR /app

# Install OS-level build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for caching)
COPY requirements.txt .

# Install PyCaret 1.0.0 without dependencies (avoid broken pandas-profiling)
RUN pip install --no-cache-dir --no-deps pycaret==1.0.0

# Install all other dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]