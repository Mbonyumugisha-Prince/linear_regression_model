# Insurance Charge Prediction Model

## Mission and Problem
In Rwanda and across Africa, health insurance schemes such as Mutuelle de Santé struggle to set fair and sustainable premiums because they lack data-driven tools to estimate individual medical costs. This project builds a machine learning regression model that predicts individual medical insurance charges using personal and lifestyle attributes such as age, BMI, smoking status and region — helping African health insurers set fairer premiums and improve financial sustainability of public health coverage.

## Dataset
- **Name:** Medical Cost Personal Dataset
- **Source:** [Kaggle — mirichoi0218/insurance](https://www.kaggle.com/datasets/mirichoi0218/insurance)
- **Description:** 1,338 records of individuals with 7 columns: age, sex, bmi, children, smoker, region and charges. The target variable `charges` represents the individual medical insurance cost billed by the insurer. The dataset is rich in both volume and variety, covering a wide range of personal and lifestyle attributes ideal for regression analysis.

## Public API
- **Base URL:** `https://insurance-predictor-3ai0.onrender.com`
- **Swagger UI (tests will be assessed here):** `https://insurance-predictor-3ai0.onrender.com/docs`
- **Predict endpoint:** `POST /predict`
- **Retrain endpoint:** `POST /retrain`

## Video Demo
- **YouTube:** `https://youtu.be/your-video-link` ← add after recording

## How to Run the Mobile App

### Prerequisites
- Flutter installed — verify with `flutter --version`
- Python 3.x installed

### Step 1 — Clone the repository
```bash
git clone https://github.com/your-username/linear_regression_model.git
cd linear_regression_model
```

### Step 2 — Start the API locally
```bash
cd summative/API
pip install -r requirements.txt
uvicorn prediction:app --host 0.0.0.0 --port 8000
```

### Step 3 — Configure the API URL in the Flutter app
Open `summative/FlutterApp/insurance_predictor/lib/services/api_service.dart` and set the correct URL:

| Device | URL |
|--------|-----|
| iOS Simulator | `http://127.0.0.1:8000` |
| Android Emulator | `http://10.0.2.2:8000` |
| Physical device | `http://YOUR_MACHINE_LOCAL_IP:8000` |
| After Render deployment | `https://insurance-predictor-3ai0.onrender.com` |

### Step 4 — Run the Flutter app
```bash
cd summative/FlutterApp/insurance_predictor
flutter pub get
flutter run
```

## Project Structure
```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   └── multivariate.ipynb       ← model training notebook
│   ├── API/
│   │   ├── prediction.py            ← FastAPI app
│   │   ├── requirements.txt         ← API dependencies
│   │   ├── best_model.pkl           ← trained Random Forest model
│   │   └── scaler.pkl               ← fitted StandardScaler
│   └── FlutterApp/
│       └── insurance_predictor/     ← Flutter mobile app
│
└── README.md
```

## Model Performance

| Model | Test RMSE | Test MAE | Test R² |
|-------|-----------|----------|---------|
| Linear Regression | $4,590.58 | $2,890.63 | 0.8853 |
| Decision Tree | $4,471.10 | $2,684.19 | 0.8912 |
| **Random Forest** | **$4,272.50** | **$2,435.03** | **0.9007** |

**Best Model: Random Forest Regressor**
- Explains **90%** of the variance in insurance charges (R² = 0.9007)
- Saved as `best_model.pkl` alongside `scaler.pkl`
