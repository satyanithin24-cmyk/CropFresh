# CropFresh — AI Agricultural Marketplace

CropFresh connects **Farmers**, **Buyers**, and **Platform Admins** around a fine-tuned **PaliGemma 2 3B PT 224** produce freshness model (`CropFresh_PaliGemma_T4x2/` + `cropfresh_model/inference.py`), transparent demonstration pricing, deterministic buyer matching, 10-step logistics tracking, and manual dispute resolution.

## Architecture Overview
- **Fine-Tuned PaliGemma 2 ML Pipeline (`CropFresh_PaliGemma_T4x2/` & `cropfresh_model/`)**:
  - Base Model: `google/paligemma-2/jax/paligemma2-3b-pt-224` (Google Big Vision JAX/Flax: `gemma2_2b` + `So400m/14`, `224x224` input, prefix `"classify freshness"`, greedy decode `seqlen=64`).
  - Fine-Tuned Weights: `CropFresh_PaliGemma_T4x2/checkpoints/paligemma2_cropfresh_final_trainable.pkl` (~1.47 GB, 368,050,176 float32 `llm/layers/attn/*` parameters, step 500).
  - Tokenizer: `CropFresh_PaliGemma_T4x2/scratch/paligemma_tokenizer.model` (SentencePiece).
  - Held-out Evaluation (`CropFresh_PaliGemma_T4x2/results/final_metrics.json`): Test Accuracy = `91.33%`, Test Macro F1 = `74.34%` across `3,461` test images.
  - Supported 10 CropFresh Classes: `freshapples`, `freshbanana`, `freshcucumber`, `freshokra`, `freshoranges`, `freshpatato`, `freshtamto`, `rottenapples`, `rottenbanana`, `rottencucumber`. Produce outside these 10 classes is routed to manual verification.
  - Legacy `ResidualMLP` + `k-NN` files are archived in `cropfresh_model/backup_legacy_mlp_model/` and removed from the active inference path.
- **GPU JAX Microservice (`cropfresh_model/paligemma2_jax_service.py`)**:
  - Reproduces the exact Google Big Vision JAX/Flax checkpoint restoration (`restore_trainable`), preprocessing, tokenization, and greedy decoding from `CropFresh_PaliGemma_T4x2/notebook_source.ipynb`.
  - Run on a GPU host (>= 12–16 GB VRAM) with `paligemma2-3b-pt-224.b16.npz` and point the main backend to it via `PALIGEMMA_INFERENCE_URL`.
  - When running locally on hardware without the 6.1 GB base checkpoint or sufficient VRAM/RAM, verified held-out evaluation images (`test_manifest.csv` / `validation_manifest.csv`) replay recorded PaliGemma 2 predictions via SHA-256 lookup (`recorded_paligemma2_eval_artifact`), and unseen images return `manual_review_required` (no mock/synthetic predictions).
- **Backend (`backend/`)**: Python FastAPI (`backend/main.py`) exposing `POST /api/ai/quality-check`, `POST /api/ai/quality-check/{id}/manual-verify`, `/api/quality/*`, and Firestore-compatible persistence (`backend/database.py` with local JSON fallback `backend/data/local_firestore.json`).
- **Frontend (`frontend/`)**: Next.js + TypeScript + Tailwind CSS application (`frontend/src/`) plus Windows fallback SPA server (`frontend/public/index.html` + `frontend/dev_server.py`) running on `http://localhost:3000`.

## Quick Start on Windows

### 1. Start the Backend (`http://localhost:8000`)
Double-click `start_backend.bat` or run in PowerShell:
```powershell
cd C:\Users\ASUS\Downloads\Buildathon
uv run --offline --with fastapi --with uvicorn --with pydantic --with python-multipart --with pillow --with numpy python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```
FastAPI interactive docs: http://localhost:8000/docs

### 2. Optional: Start the Remote/GPU Big Vision JAX Service
On a Linux/GPU host with `jax[cuda12]`, `flax`, `tensorflow`, `sentencepiece`, `ml_collections`, `einops==0.7.0`, and `paligemma2-3b-pt-224.b16.npz`:
```bash
export PALIGEMMA_BASE_MODEL_PATH=/path/to/paligemma2-3b-pt-224.b16.npz
uvicorn cropfresh_model.paligemma2_jax_service:app --host 0.0.0.0 --port 8090
```
Then set `PALIGEMMA_INFERENCE_URL=http://<gpu-host>:8090` before starting `backend.main:app`.

### 2. Start the Frontend (`http://localhost:3000`)
Double-click `start_frontend.bat` or run in PowerShell:
```powershell
cd C:\Users\ASUS\Downloads\Buildathon
# If Node.js / npm is installed:
cd frontend && npm install && npm run dev
# Or without Node.js (uses frontend/public/index.html talking to localhost:8000):
uv run python frontend\dev_server.py
```
Open http://localhost:3000 in your browser.

### Demo Accounts (Clearly Marked Demo Mode)
| Role | Email | Password |
|---|---|---|
| Farmer | `farmer@cropfresh.demo` | `demo123` |
| Buyer | `buyer@cropfresh.demo` | `demo123` |
| Admin | `admin@cropfresh.demo` | `demo123` |

## Optional Firebase Setup
1. Create a Firebase project, enable **Firestore Database** and **Email/Password Authentication**.
2. Download the Firebase Admin SDK service account JSON and set `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env` (see `.env.example`).
3. Install `firebase-admin` (listed in `backend/requirements.txt`). Without this file, CropFresh runs locally using `backend/data/local_firestore.json`.

## Google Cloud Run Deployment
```bash
gcloud builds submit --tag gcr.io/<PROJECT_ID>/cropfresh-api
gcloud run deploy cropfresh-api --image gcr.io/<PROJECT_ID>/cropfresh-api --platform managed --region asia-south1 --allow-unauthenticated --set-env-vars GEMINI_API_KEY=<YOUR_KEY>
```
Deploy `frontend/` to Firebase Hosting or Cloud Run with `NEXT_PUBLIC_API_URL` pointing to the deployed `cropfresh-api` URL.

## Run End-to-End Integration Tests
```powershell
uv run --with fastapi --with uvicorn --with pydantic --with python-multipart --with pillow python backend\test_e2e_workflow.py
```
See `API_DOCS.md` and `TEST_RESULTS.md` for full endpoint reference and live E2E verification output.
