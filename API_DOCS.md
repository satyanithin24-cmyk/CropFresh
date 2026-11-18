# CropFresh API & Database Documentation

Base URL (Local): `http://localhost:8000` (Interactive OpenAPI Docs at `http://localhost:8000/docs`)

## Firestore Collections (`backend/database.py`)
When `FIREBASE_SERVICE_ACCOUNT_PATH` is configured, documents are persisted in live Firebase Firestore; otherwise they persist in `backend/data/local_firestore.json`:
1. `users` — Registered Farmer, Buyer, and Admin accounts (`id`, `role`, `account_status`, `is_demo_account`, preferences).
2. `farmers` — Farmer farm profiles & contact records.
3. `buyers` — Buyer company profiles, preferred produce/grades, max budget per kg.
4. `produce_listings` — Active & completed listings linked to AI `prediction_id` and `price_recommendation_id`.
5. `produce_images` — Uploaded image metadata and storage paths.
6. `quality_predictions` — Prototype AI quality outputs, `original_prediction` snapshot, `needs_manual_verification` flag, and separate `admin_override` record.
7. `price_recommendations` — Demonstration baseline price suggestions using model `price_multiplier`.
8. `orders` — Order details, quantities, unit price, total amount, and current logistics step.
9. `order_tracking` — Timestamped 10-step logistics lifecycle audit log.
10. `disputes` — Buyer-raised quality/quantity/damage/delivery disputes with image evidence and manual admin resolution.
11. `payments` — Clearly labeled Demo Escrow payment records (`is_demo_payment: true`).
12. `notifications` — Role-targeted alerts for orders, logistics updates, AI overrides, and disputes.

## REST Endpoints

### Authentication & Profiles
- `POST /api/auth/register` — Register Farmer, Buyer, or Admin account.
- `POST /api/auth/login` — Email/password login returning bearer token.
- `POST /api/auth/demo-login` — One-click demo account login (`role`: `farmer | buyer | admin`).
- `GET /api/auth/me` & `PUT /api/auth/profile` — Get or update user profile.

### AI Quality Assessment (Fine-Tuned PaliGemma 2 3B PT 224)
- `GET /api/quality/model-info` — PaliGemma 2 3B model configuration, 10 supported classes, checkpoint/tokenizer/base-model status, and `results/final_metrics.json`.
- `POST /api/ai/quality-check` — Multipart single-image upload (`file` or `image`, optional `produce_category`, `user_id`, `listing_id`, `compute_confidence`). Returns `predicted_class`, `produce_category`, `freshness_status`, `confidence` (`null` for greedy decode unless candidate log-prob scoring is enabled), `processing_time_ms`, `model_id`, `inference_source`, and `needs_manual_verification`.
- `POST /api/ai/quality-check/{prediction_id}/manual-verify` — Farmer/Admin manually verifies or corrects quality class (`verified_class`, `produce_category`, `freshness_status`, `notes`, optional `listing_id`) and saves it against the produce listing.
- `POST /api/quality/predict` — Multipart single-image upload (compatible wrapper routed to `PaliGemma2Predictor`).
- `POST /api/quality/predict-batch` — Multipart multi-image upload.
- `POST /api/quality/predict-dataset-sample` — Run `PaliGemma2Predictor` directly on a `Train/` or `Test/` sample image.
- `GET /api/quality/predictions` — List prediction history (role-scoped).
- `POST /api/quality/predictions/{id}/verify` — Admin confirms AI prediction.
- `POST /api/quality/predictions/{id}/override` — Admin overrides class with mandatory reason while preserving `original_prediction`.

### AI Price Advisor & Buyer Matching
- `POST /api/price/recommend` — Returns demonstration baseline price, range, `price_multiplier`, and explanation.
- `GET /api/matching/listing/{listing_id}` — Ranks compatible buyers for a farmer's listing.
- `GET /api/matching/buyer/{buyer_id}` — Ranks active listings for a buyer.

### Listings, 10-Step Orders, Disputes & Admin
- `GET /api/listings` (filters: `search`, `quality_grade`, `min_price`, `max_price`, `location`, `min_quantity`), `GET /api/listings/{id}`, `POST /api/listings`, `PUT /api/listings/{id}`, `DELETE /api/listings/{id}`
- `POST /api/orders`, `GET /api/orders`, `GET /api/orders/{id}`
- `POST /api/orders/{id}/respond` (`accept` / `reject`)
- `POST /api/orders/{id}/advance-status` (`PRODUCE_PREPARED`, `PICKUP_SCHEDULED`, `ORDER_DISPATCHED`, `IN_TRANSIT`, etc.)
- `POST /api/orders/{id}/confirm-delivery`
- `POST /api/disputes/upload-evidence`, `POST /api/disputes`, `GET /api/disputes`, `POST /api/disputes/{id}/resolve`
- `GET /api/notifications`, `POST /api/notifications/{id}/read`
- `GET /api/admin/overview`, `GET /api/admin/users`, `PUT /api/admin/users/{id}/status`
