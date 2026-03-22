import os
import io
import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "best_model.pkl")
SCALER_PATH= os.path.join(BASE_DIR, "scaler.pkl")


model  = joblib.load(MODEL_PATH)
scaler = joblib.load(SCALER_PATH)

# App 
app = FastAPI(
    title       = "Insurance Charge Prediction API",
    description = (
        "Predicts medical insurance charges based on patient details. "
        "Built with Random Forest + feature engineering. "
        "Also exposes a /retrain endpoint for continuous learning."
    ),
    version     = "1.0.0",
)

# CORS Middleware 
# Allowing all origins so the Flutter app (and Swagger UI) can reach the API
# from any domain. In production you would restrict origins to your app's URL.
app.add_middleware(
    CORSMiddleware,
    allow_origins     = [
        "http://localhost",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "https://insurance-predictor-3ai0.onrender.com",
    ],
    allow_credentials = True,
    allow_methods     = ["GET", "POST"],
    allow_headers     = ["Content-Type", "Authorization"],
)

# Input schema 
class PatientData(BaseModel):
    age     : int   = Field(..., ge=18,  le=64,   description="Age of patient (18–64)")
    sex     : str   = Field(...,          description="Sex: 'male' or 'female'")
    bmi     : float = Field(..., ge=10.0, le=60.0, description="Body Mass Index (10–60)")
    children: int   = Field(..., ge=0,   le=5,    description="Number of dependents (0–5)")
    smoker  : str   = Field(...,          description="Smoker: 'yes' or 'no'")
    region  : str   = Field(...,          description="Region: 'northeast','northwest','southeast','southwest'")

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "age"     : 35,
                    "sex"     : "male",
                    "bmi"     : 28.5,
                    "children": 2,
                    "smoker"  : "no",
                    "region"  : "southwest"
                }
            ]
        }
    }


# Helper: build feature vector 
def build_features(data: PatientData) -> pd.DataFrame:
    sex_enc    = 1 if data.sex.lower()    == "male" else 0
    smoker_enc = 1 if data.smoker.lower() == "yes"  else 0

    region_nw  = 1 if data.region.lower() == "northwest"  else 0
    region_se  = 1 if data.region.lower() == "southeast"  else 0
    region_sw  = 1 if data.region.lower() == "southwest"  else 0

    smoker_bmi  = smoker_enc * data.bmi
    smoker_age  = smoker_enc * data.age
    age_squared = data.age ** 2

    return pd.DataFrame([{
        "age"              : data.age,
        "sex"              : sex_enc,
        "bmi"              : data.bmi,
        "children"         : data.children,
        "smoker"           : smoker_enc,
        "region_northwest" : region_nw,
        "region_southeast" : region_se,
        "region_southwest" : region_sw,
        "smoker_bmi"       : smoker_bmi,
        "smoker_age"       : smoker_age,
        "age_squared"      : age_squared,
    }])


# Routes 
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "Insurance Charge Prediction API is running"}


@app.post("/predict", tags=["Prediction"])
def predict(patient: PatientData):

    # Validate categorical fields
    if patient.sex.lower() not in ("male", "female"):
        raise HTTPException(status_code=422, detail="sex must be 'male' or 'female'")
    if patient.smoker.lower() not in ("yes", "no"):
        raise HTTPException(status_code=422, detail="smoker must be 'yes' or 'no'")
    if patient.region.lower() not in ("northeast", "northwest", "southeast", "southwest"):
        raise HTTPException(status_code=422, detail="region must be one of: northeast, northwest, southeast, southwest")

    features       = build_features(patient)
    features_scaled= scaler.transform(features)
    prediction     = model.predict(features_scaled)[0]

    return {
        "predicted_charge_usd": round(float(prediction), 2),
        "predicted_charge"    : f"${round(float(prediction), 2):,.2f}",
        "input"               : patient.model_dump(),
    }


@app.post("/retrain", tags=["Retraining"])
async def retrain(file: UploadFile = File(...)):
   
    global model, scaler

    # Read uploaded file
    contents = await file.read()
    try:
        df = pd.read_csv(io.StringIO(contents.decode("utf-8")))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not parse CSV: {e}")

    required = {"age", "sex", "bmi", "children", "smoker", "region", "charges"}
    missing  = required - set(df.columns)
    if missing:
        raise HTTPException(status_code=400, detail=f"Missing columns: {missing}")

    # Drop duplicates & nulls
    df = df.drop_duplicates().dropna()

    # Encode
    df["sex"]    = df["sex"].map({"female": 0, "male": 1})
    df["smoker"] = df["smoker"].map({"no": 0, "yes": 1})
    df = pd.get_dummies(df, columns=["region"], drop_first=True)
    df = df.astype({c: int for c in df.select_dtypes(bool).columns})

    # Make sure all region dummies exist
    for col in ("region_northwest", "region_southeast", "region_southwest"):
        if col not in df.columns:
            df[col] = 0

    # Feature engineering
    df["smoker_bmi"]  = df["smoker"] * df["bmi"]
    df["smoker_age"]  = df["smoker"] * df["age"]
    df["age_squared"] = df["age"] ** 2

    feature_cols = [
        "age", "sex", "bmi", "children", "smoker",
        "region_northwest", "region_southeast", "region_southwest",
        "smoker_bmi", "smoker_age", "age_squared",
    ]
    X = df[feature_cols]
    y = df["charges"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    new_scaler = StandardScaler()
    X_train_sc = new_scaler.fit_transform(X_train)
    X_test_sc  = new_scaler.transform(X_test)

    # Hyperparameter tuning
    param_dist = {
        "n_estimators"     : [100, 200, 300],
        "max_depth"        : [6, 8, 10, None],
        "min_samples_split": [2, 5, 10],
        "min_samples_leaf" : [1, 2, 4],
        "max_features"     : ["sqrt", "log2"],
    }
    search = RandomizedSearchCV(
        RandomForestRegressor(random_state=42, n_jobs=-1),
        param_dist, n_iter=20, cv=5,
        scoring="neg_root_mean_squared_error",
        random_state=42, n_jobs=-1,
    )
    search.fit(X_train_sc, y_train)
    new_model = search.best_estimator_

    # Evaluate
    y_pred    = new_model.predict(X_test_sc)
    rmse      = float(np.sqrt(mean_squared_error(y_test, y_pred)))
    mae       = float(mean_absolute_error(y_test, y_pred))
    r2        = float(r2_score(y_test, y_pred))

    # Persist
    joblib.dump(new_model,  MODEL_PATH)
    joblib.dump(new_scaler, SCALER_PATH)

    # Hot-swap in memory
    model  = new_model
    scaler = new_scaler

    return {
        "message"     : "Model retrained and updated successfully",
        "best_params" : search.best_params_,
        "metrics"     : {"test_rmse": round(rmse, 2), "test_mae": round(mae, 2), "test_r2": round(r2, 4)},
        "rows_used"   : len(df),
    }
