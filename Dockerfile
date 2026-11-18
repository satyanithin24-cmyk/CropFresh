# Cloud Run compatible container for CropFresh Backend + Model Inference
FROM python:3.12-slim

WORKDIR /app

COPY backend/requirements.txt ./backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt

COPY CropFresh_PaliGemma_T4x2/model_metadata.json CropFresh_PaliGemma_T4x2/class_mapping.json CropFresh_PaliGemma_T4x2/training_state.json ./CropFresh_PaliGemma_T4x2/
COPY CropFresh_PaliGemma_T4x2/results ./CropFresh_PaliGemma_T4x2/results
COPY CropFresh_PaliGemma_T4x2/test_manifest.csv CropFresh_PaliGemma_T4x2/validation_manifest.csv ./CropFresh_PaliGemma_T4x2/
COPY cropfresh_model ./cropfresh_model
COPY backend ./backend
COPY Train ./Train
COPY Test ./Test

ENV PORT=8080
EXPOSE 8080

CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT}"]
