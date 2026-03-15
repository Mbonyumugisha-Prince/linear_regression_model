# Insurance Charge Prediction Model

## Mission and Problem
In Rwanda and across Africa, health insurance schemes such as Mutuelle 
de Santé struggle to set fair and sustainable premiums because they lack 
data-driven tools to estimate individual medical costs based on personal 
and lifestyle attributes. The problem is that without an accurate 
prediction model, low-risk members are overcharged while high-risk 
members are undercharged leading to financial instability in the health 
insurance system and reduced trust from citizens. This project builds a 
machine learning regression model that predicts individual medical 
insurance charges using features such as age, BMI, smoking status and 
region, providing a data-driven solution that can help Rwandan and 
African health insurers set fairer premiums and improve the financial 
sustainability of public health coverage.

## Dataset
- **Name:** Medical Cost Personal Dataset
- **Source:** [Kaggle](https://www.kaggle.com/datasets/mirichoi0218/insurance)
- **Description:** The dataset contains 1,338 records of individuals 
in the USA with 7 columns: age, sex, bmi, children, smoker, region 
and charges. The target variable is charges which represents the 
individual medical insurance cost billed by the insurer. The dataset 
covers a wide variety of personal and lifestyle attributes making it 
rich in both volume and variety for regression analysis.

## Project Structure
```
Insuarence_price_prediction_model_assignment/
│
├── summative/
│   ├── linear_regression/
│   │   └── multivariate.ipynb
│   ├── API/
│   └── FlutterApp/
│
|
└── README.md
```

## Models Used
- Linear Regression (Ordinary Least Squares)
- Decision Tree Regressor
- Random Forest Regressor ← Best Model

## Model Performance

| Model             | Test MSE      | Test MAE  | Test R2 |
|-------------------|---------------|-----------|---------|
| Linear Regression | 35,478,020.68 | $4,177.05 | 0.8069  |
| Decision Tree     | 19,461,664.32 | $2,656.84 | 0.8941  |
| Random Forest     | 18,729,563.18 | $2,447.29 | 0.8981  |

## Best Model
Random Forest Regressor with Test R2 of 0.8981 which means the model 
explains 90% of the variance in insurance charges. The model was saved 
as best_model.pkl and the scaler was saved as scaler.pkl.

## How to Run
1. Clone the repository
2. Open summative/linear_regression/multivariate.ipynb
3. Run all cells in order
4. The best model will be saved automatically as best_model.pkl
5. And you  run on the google  colab using this link : https://colab.research.google.com/drive/1LdT_ju-Qd2Ma_pEJOEGLED40QR_BqoXR#scrollTo=4a-lePqeAVMD

## Requirements
- Python 3.x
- pandas
- numpy
- matplotlib
- seaborn
- scikit-learn
- joblib