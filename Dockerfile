# ---- Dockerfile for the Insurance Charge Predictor (FastAPI app) ----
#
# MLOps note for beginners: a Dockerfile is a recipe for building a
# "container image" - a self-contained snapshot of an OS + Python +
# your dependencies + your code. Anyone who runs this image gets the
# EXACT same environment you tested in, which is why Docker is the
# standard way to ship ML apps: it eliminates "works on my machine"
# problems caused by mismatched Python/library versions (a very common
# issue with older ML libraries like pycaret==1.0.0).

# 1. Base image: pycaret==1.0.0 only supports Python 3.6/3.7, and the
#    saved model file was pickled under that same old version - so we
#    must match it exactly, not use a newer Python.
FROM python:3.7-slim

# 2. Set the working directory inside the container. Every command below
#    (COPY, RUN, CMD) now runs relative to /app inside the container's
#    filesystem - it does not touch your real machine.
WORKDIR /app

# 3. Install OS-level build tools needed to compile some ML/scientific
#    Python packages (e.g. numpy/scipy/pycaret) from source if no
#    pre-built wheel is available for this platform.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy ONLY the requirements file first, then install dependencies.
#    Why not copy everything at once? Docker caches each instruction as a
#    "layer". As long as requirements.txt doesn't change, Docker reuses
#    the cached "pip install" layer on future builds instead of
#    re-downloading every package - this makes rebuilds much faster
#    whenever you only change app.py.
COPY requirements.txt .

# 4a. Install pycaret==1.0.0 with --no-deps first. Its normal dependency
#     list pins pandas-profiling==2.3.0, which has been removed from
#     PyPI entirely - any normal "pip install pycaret==1.0.0" will always
#     fail now, forever, regardless of Python version. --no-deps installs
#     PyCaret's own code without pulling that dead dependency.
RUN pip install --no-cache-dir --no-deps pycaret==1.0.0

# 4b. Now install everything the app (and PyCaret's load_model/
#     predict_model functions) actually need, at versions compatible
#     with Python 3.7. This list intentionally excludes pandas-profiling.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Now copy the rest of the application code (this layer changes often,
#    so it's placed after the slow dependency-install layer).
COPY . .

# 6. Document which port the app listens on. This doesn't actually
#    publish the port - it's metadata for humans/tools; the real
#    port mapping happens with `docker run -p` or the hosting platform.
EXPOSE 8000

# 7. The command that runs when the container starts.
#    --host 0.0.0.0 is required so the server accepts connections from
#    outside the container, not just from inside it (127.0.0.1 would be
#    invisible to the outside world).
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]