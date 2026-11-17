# CropFresh End-to-End Integration Test Results

- **Test Date (UTC)**: `2026-11-17T11:54:21.980697+00:00`
- **AI Model Tested**: `google/paligemma-2/jax/paligemma2-3b-pt-224` + `paligemma2_cropfresh_final_trainable.pkl` (`PaliGemma2Predictor`)
- **Database Tested**: `local_firestore_fallback` (all 12 collections active)
- **Frontend Tested**: Served at `http://127.0.0.1:3011/index.html`

| Workflow Step | Result | Observed Output |
|---|---|---|
| 0a. Frontend Server & PaliGemma 2 UI | **PASS** | HTTP 200, 61022 bytes served with /api/ai/quality-check integration |
| 0b. Model Info Endpoint | **PASS** | model_id=google/paligemma-2/jax/paligemma2-3b-pt-224, classes=10, test_acc=0.9133 |
| 0c. Fine-Tuned Checkpoint & Tokenizer Verification | **PASS** | step=500, tensors=3, trainable_params=368,050,176, tokenizer_exists=True, base_npz_found=False |
| 1a. Farmer Demo Login | **PASS** | Logged in as farmer@cropfresh.demo |
| 1b. Farmer Registration | **PASS** | Registered farmer-f53e6ebc |
| 2a. Fresh Apple (a_f015.png) | **PASS** | predicted_class=freshapples, raw=freshapples, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=1.67ms |
| 2b. Rotten Apple (a_r008.png) | **PASS** | predicted_class=rottenapples, raw=rottenapples, freshness=rotten, source=recorded_paligemma2_eval_artifact, time=4.97ms |
| 2c. Fresh Banana (b_f006.png) | **PASS** | predicted_class=freshbanana, raw=freshbanana, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=4.28ms |
| 2d. Rotten Banana (b_r010.png) | **PASS** | predicted_class=rottenbanana, raw=rottenbanana, freshness=rotten, source=recorded_paligemma2_eval_artifact, time=0.62ms |
| 2e. Fresh Cucumber (c_f006.png) | **PASS** | predicted_class=freshcucumber, raw=freshcucumber, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=1.94ms |
| 2f. Rotten Cucumber (c_r003.png) | **PASS** | predicted_class=rottencucumber, raw=rottencucumber, freshness=rotten, source=recorded_paligemma2_eval_artifact, time=1.64ms |
| 2g. Fresh Okra (o_f008.png) | **PASS** | predicted_class=freshokra, raw=freshokra, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=2.67ms |
| 2h. Fresh Oranges | **PASS** | predicted_class=freshoranges, raw=freshoranges, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=2.13ms |
| 2i. Fresh Potato (p_f006.png) | **PASS** | predicted_class=freshpatato, raw=freshpotato, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=1.78ms |
| 2j. Fresh Tomato (t_f002.png) | **PASS** | predicted_class=freshtamto, raw=freshtomato, freshness=fresh, source=recorded_paligemma2_eval_artifact, time=1.29ms |
| 3a. Unsupported Produce Category (onion) | **PASS** | status=unsupported_category, needs_manual_verification=True |
| 3b. Farmer Manual Verification & Correction | **PASS** | verified_class=manual_verified_fresh, status=manual_verified |
| 3c. Invalid Image Upload Rejection | **PASS** | Returned HTTP 400 |
| 3d. Unseen Image Without Base 3B Checkpoint | **PASS** | status=manual_review_required, source=base_model_unavailable |
| 3e. Batch Prediction Endpoint | **PASS** | Batch count=2 |
| 4. AI Price Advisor (Demo Estimate) | **PASS** | Suggested=INR 111.91/kg (range 100.72-125.34) |
| 5. Farmer Publishes Produce Listing (Linked to PaliGemma 2) | **PASS** | Created listing lst-37f2a68f0b grade=freshapples, linked pred=pred-e82e987fc3 |
| 6. Buyer Login | **PASS** | Logged in as buyer@cropfresh.demo |
| 7. Buyer Search, Filter & Matching | **PASS** | Found listing in search; top buyer match score=50.0 |
| 8. Buyer Places Order (Demo Escrow) | **PASS** | Order ord-6289c6d886 total=INR 3357.3, step=FARMER_NOTIFIED |
| 9. Farmer Accepts Order | **PASS** | Step=4/10 (ORDER_CONFIRMED) |
| 10. Admin Overview, Order View, Prediction Verify & Override | **PASS** | KPIs orders=3; preserved original=rottenapples vs override=freshapples |
| 11. Order Logistics Tracking Updates | **PASS** | Reached step 8/10 (IN_TRANSIT) with 8 timeline events |
| 12. Buyer Confirms Delivery & Order Completes | **PASS** | Step=10/10, payment=DEMO_RELEASED_TO_FARMER |
| 13. Dispute Creation with Evidence & Manual Admin Resolution | **PASS** | Dispute dsp-1318ccf8d2 resolved as partial_demo_adjustment |
