# Insurance Charge Predictor

Small FastAPI application that predicts medical insurance charges using a
pre-trained PyCaret regression model. Includes a simple web form UI,
JSON API, and a Dockerfile for containerized deployment.

## Contents

- `app.py` — FastAPI application and routes
- `requirements.txt` — Python dependencies
- `Dockerfile` — Docker image recipe
- `templates/home.html` — Web UI for form-based predictions
- `static/style.css` — Styles for the web UI
- `Insurance - Model Training Notebook.ipynb` — Jupyter notebook used to train the model

## Requirements

- Python 3.9+ (recommended)
- Docker (optional, for container builds)

Install dependencies locally:

```bash
python -m pip install -r requirements.txt
```

## Running locally

Start the FastAPI app for development:

```bash
python app.py
# or
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

Open `http://localhost:8000/` to use the web form.

## API

- `POST /predict` — HTML form submission (returns rendered page)
- `POST /predict_api` — JSON API. Example payload:

```json
{
  "age": 30,
  "sex": "male",
  "bmi": 25.3,
  "children": 1,
  "smoker": "no",
  "region": "northwest"
}
```

Response:

```json
{ "prediction": 12345.67 }
```

- `GET /health` — health check and model-loaded indicator

## Docker

Build the image:

```bash
docker build -t insurance-predictor .
```

Run the container:

```bash
docker run -p 8000:8000 insurance-predictor
```

## Model artifact

The app expects a PyCaret serialized model named `deployment_28042020` to
exist in the working directory. Place the trained model file next to
`app.py` before starting the service.

## Troubleshooting

- If `pip install` fails during Docker builds, ensure the base Python
  image matches dependency requirements (the project targets Python 3.9+)
  and that OS build tools are available.
- If the model fails to load, verify the model file name and that it was
  exported using the same PyCaret version used at runtime.

## License & Credits

This repository is a learning/demo project adapted from PyCaret examples.
See the original tutorial referenced in the project files for details.
