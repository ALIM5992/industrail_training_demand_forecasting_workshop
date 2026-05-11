# ============================================================
#  NexAI Academy x NIBM -- Retail Demand Forecasting Workshop
#  One-Shot Project Setup Script (Windows PowerShell)
#  Run this in an EMPTY folder where you want the project
#  Usage:  .\setup_project.ps1
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  NexAI Academy x NIBM Workshop -- Project Setup" -ForegroundColor Cyan
Write-Host "  Retail Demand Forecasting Pipeline" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# == Ask for GitHub repo URL ==================================
$repoUrl = Read-Host "Paste your GitHub repo HTTPS URL (e.g. https://github.com/username/retail-demand-forecasting-workshop.git)"
Write-Host ""

# == Step 1: Create all folders ===============================
Write-Host "[1/6] Creating folder structure..." -ForegroundColor Yellow

$folders = @(
    "data\raw",
    "data\processed",
    "data\inference",
    "models",
    "outputs",
    "src\config",
    "src\utils",
    "logs"
)
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
}
Write-Host "      Folders created." -ForegroundColor Green

# == Step 2: Create all files =================================
Write-Host "[2/6] Writing all project files..." -ForegroundColor Yellow

# ---------- __init__.py files (empty) ----------
New-Item -ItemType File -Force -Path "src\__init__.py" | Out-Null
New-Item -ItemType File -Force -Path "src\config\__init__.py" | Out-Null
New-Item -ItemType File -Force -Path "src\utils\__init__.py" | Out-Null

# ---------- data/raw/sales.csv ----------
@"
date,store_id,item_id,sales_qty
2024-01-01,S001,I001,12
2024-01-02,S001,I001,15
2024-01-03,S001,I001,11
2024-01-04,S001,I001,14
2024-01-05,S001,I001,13
2024-01-06,S001,I001,16
2024-01-07,S001,I001,18
2024-01-08,S001,I001,17
2024-01-09,S001,I001,19
2024-01-10,S001,I001,20
2024-01-11,S001,I001,15
2024-01-12,S001,I001,14
2024-01-13,S001,I001,16
2024-01-14,S001,I001,18
2024-01-15,S001,I001,17
2024-01-16,S001,I001,19
2024-01-17,S001,I001,16
2024-01-18,S001,I001,15
2024-01-19,S001,I001,18
2024-01-20,S001,I001,17
2024-01-21,S001,I001,19
2024-01-22,S001,I001,20
2024-01-23,S001,I001,18
2024-01-24,S001,I001,17
2024-01-25,S001,I001,16
2024-01-26,S001,I001,19
2024-01-27,S001,I001,18
2024-01-28,S001,I001,20
2024-01-29,S001,I001,21
2024-01-30,S001,I001,19
2024-01-31,S001,I001,18
2024-02-01,S001,I001,20
2024-02-02,S001,I001,21
2024-02-03,S001,I001,19
2024-02-04,S001,I001,20
2024-02-05,S001,I001,22
2024-02-06,S001,I001,21
2024-02-07,S001,I001,23
2024-02-08,S001,I001,22
2024-02-09,S001,I001,21
"@ | Set-Content -Path "data\raw\sales.csv" -Encoding UTF8

# ---------- data/inference/future_data.csv ----------
@"
date,store_id,item_id
2024-02-10,S001,I001
2024-02-11,S001,I001
2024-02-12,S001,I001
2024-02-13,S001,I001
2024-02-14,S001,I001
2024-02-15,S001,I001
2024-02-16,S001,I001
"@ | Set-Content -Path "data\inference\future_data.csv" -Encoding UTF8

# ---------- src/config/config.py ----------
@"
DATA_RAW_PATH         = "data/raw/sales.csv"
DATA_CLEAN_PATH       = "data/processed/clean_sales.csv"
DATA_FEATURE_PATH     = "data/processed/features.csv"
MODEL_PATH            = "models/random_forest.pkl"
INFERENCE_INPUT_PATH  = "data/inference/future_data.csv"
INFERENCE_OUTPUT_PATH = "outputs/predictions.csv"
FEATURE_COLS          = ["lag_1", "lag_3", "day_of_week"]
TARGET_COL            = "sales_qty"
"@ | Set-Content -Path "src\config\config.py" -Encoding UTF8

# ---------- src/utils/io_utils.py ----------
@"
import pandas as pd

def load_csv(path: str) -> pd.DataFrame:
    return pd.read_csv(path)

def save_csv(df, path: str):
    df.to_csv(path, index=False)
"@ | Set-Content -Path "src\utils\io_utils.py" -Encoding UTF8

# ---------- src/utils/metrics.py ----------
@"
import numpy as np

def calculate_mape(y_true, y_pred):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    non_zero_mask = y_true != 0
    return np.mean(
        np.abs((y_true[non_zero_mask] - y_pred[non_zero_mask])
               / y_true[non_zero_mask])
    ) * 100
"@ | Set-Content -Path "src\utils\metrics.py" -Encoding UTF8

# ---------- src/utils/logger.py ----------
@"
import logging
import os

def get_logger(name=__name__, log_file="logs/pipeline.log"):
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler = logging.FileHandler(log_file)
    file_handler.setFormatter(formatter)
    file_handler.setLevel(logging.DEBUG)
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    console_handler.setLevel(logging.INFO)
    if not logger.hasHandlers():
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)
    return logger
"@ | Set-Content -Path "src\utils\logger.py" -Encoding UTF8

# ---------- src/data_preprocessing.py ----------
@"
import pandas as pd
from src.config.config import DATA_RAW_PATH

def preprocess_run():
    # Loads raw sales data, parses dates, removes null rows
    df = pd.read_csv(DATA_RAW_PATH)
    df['date'] = pd.to_datetime(df['date'])
    df = df.dropna()
    return df
"@ | Set-Content -Path "src\data_preprocessing.py" -Encoding UTF8

# ---------- src/feature_engineering.py ----------
@"
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
import joblib
import os

def add_features(df):
    df['day_of_week'] = df['date'].dt.dayofweek
    weekend_days = [5, 6]  # 5=Saturday, 6=Sunday
    df['is_weekend'] = df['day_of_week'].isin(weekend_days).astype(int)
    return df

def prepare_features(df, target='sales_qty', test_size=0.2, random_state=42):
    y = df[target]
    X = df.drop(columns=[target, 'date'])

    store_le = LabelEncoder()
    X['store_id'] = store_le.fit_transform(X['store_id'])
    item_le = LabelEncoder()
    X['item_id']  = item_le.fit_transform(X['item_id'])

    os.makedirs('models', exist_ok=True)
    joblib.dump(store_le, 'models/store_le.pkl')
    joblib.dump(item_le,  'models/item_le.pkl')

    return train_test_split(X, y, test_size=test_size, random_state=random_state)
"@ | Set-Content -Path "src\feature_engineering.py" -Encoding UTF8

# ---------- src/train_model.py ----------
@"
from sklearn.ensemble import RandomForestRegressor
import os
import joblib
from src.config.config import MODEL_PATH

def train_model(X_train, y_train, model_path=None):
    if model_path is None:
        model_path = MODEL_PATH
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    os.makedirs(os.path.dirname(model_path), exist_ok=True)
    joblib.dump(model, model_path)
    print(f'Model saved to {model_path}')
    return model
"@ | Set-Content -Path "src\train_model.py" -Encoding UTF8

# ---------- src/evaluate_model.py ----------
@"
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

def evaluate_model(model, X_test, y_test):
    y_pred = model.predict(X_test)
    print(f'MAE: {mean_absolute_error(y_test, y_pred):.4f}')
    print(f'MSE: {mean_squared_error(y_test, y_pred):.4f}')
    print(f'R2 Score: {r2_score(y_test, y_pred):.4f}')
    return {
        'MAE': mean_absolute_error(y_test, y_pred),
        'MSE': mean_squared_error(y_test, y_pred),
        'R2':  r2_score(y_test, y_pred),
    }
"@ | Set-Content -Path "src\evaluate_model.py" -Encoding UTF8

# ---------- src/run_inference_future_predict.py ----------
@"
from src.feature_engineering import add_features
import pandas as pd
import joblib
import os
from src.config.config import INFERENCE_OUTPUT_PATH

def run_inference_future_predict(
    model_path: str,
    input_path: str,
    output_path: str = INFERENCE_OUTPUT_PATH
):
    df_future = pd.read_csv(input_path)
    df_future['date'] = pd.to_datetime(df_future['date'])
    df_future = df_future.dropna()

    # Apply SAME feature engineering as training -- critical!
    df_future = add_features(df_future)

    store_le_path = 'models/store_le.pkl'
    item_le_path  = 'models/item_le.pkl'
    if os.path.exists(store_le_path) and os.path.exists(item_le_path):
        store_le = joblib.load(store_le_path)
        item_le  = joblib.load(item_le_path)
        df_future['store_id'] = store_le.transform(df_future['store_id'])
        df_future['item_id']  = item_le.transform(df_future['item_id'])
    else:
        raise FileNotFoundError('Label encoders not found. Run training first.')

    cols_to_drop = ['date']
    if 'sales_qty' in df_future.columns:
        cols_to_drop.append('sales_qty')
    X_future = df_future.drop(columns=cols_to_drop)

    if not os.path.exists(model_path):
        raise FileNotFoundError(f'Model not found at {model_path}')
    model = joblib.load(model_path)
    df_future['sales_qty_pred'] = model.predict(X_future)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df_future.to_csv(output_path, index=False)
    print(f'Future predictions saved to {output_path}')
"@ | Set-Content -Path "src\run_inference_future_predict.py" -Encoding UTF8

# ---------- main.py ----------
@"
from src.data_preprocessing           import preprocess_run
from src.feature_engineering          import add_features, prepare_features
from src.train_model                  import train_model
from src.evaluate_model               import evaluate_model
from src.utils.io_utils               import load_csv, save_csv
from src.run_inference_future_predict import run_inference_future_predict
from src.config.config                import (
    MODEL_PATH,
    INFERENCE_INPUT_PATH,
    INFERENCE_OUTPUT_PATH,
)
from src.utils.logger import get_logger

logger = get_logger('RetailForecastPipeline')

def main():
    logger.info('Starting Retail Demand Forecasting Pipeline')

    df = preprocess_run()
    logger.info('Data preprocessing completed')

    df = add_features(df)
    logger.info('Feature engineering completed')
    logger.debug(f'Columns after feature engineering: {df.columns.tolist()}')

    X_train, X_test, y_train, y_test = prepare_features(df)
    logger.info('Features prepared & train/test split done')

    model = train_model(X_train, y_train, model_path=MODEL_PATH)
    logger.info(f'Model training & saving completed at {MODEL_PATH}')

    evaluate_model(model, X_test, y_test)
    logger.info('Model evaluation completed')

    run_inference_future_predict(
        model_path=MODEL_PATH,
        input_path=INFERENCE_INPUT_PATH,
        output_path=INFERENCE_OUTPUT_PATH,
    )
    logger.info('Inference completed & predictions saved')
    logger.info('Pipeline completed successfully')

if __name__ == '__main__':
    main()
"@ | Set-Content -Path "main.py" -Encoding UTF8

# ---------- requirements.txt ----------
@"
pandas
numpy
scikit-learn
matplotlib
joblib
"@ | Set-Content -Path "requirements.txt" -Encoding UTF8

# ---------- .gitignore ----------
@"
__pycache__/
*.py[cod]
*$py.class
venv/
env/
logs/
.idea/
*.iml
.DS_Store
*.swp
*.log
models/
outputs/
*.pkl
*.joblib
config/config_secret.py
.ipynb_checkpoints/
Thumbs.db
"@ | Set-Content -Path ".gitignore" -Encoding UTF8

# ---------- README.md ----------
@"
# Retail Demand Forecasting Workshop
**NexAI Academy x NIBM -- Technical Hands-On Workshop**

A full end-to-end ML pipeline for retail sales forecasting built using
Python, scikit-learn, and industry-standard modular design.

## How to Run

```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

## Pipeline Steps
1. Data Preprocessing
2. Feature Engineering
3. Model Training (Random Forest)
4. Model Evaluation (MAE, MSE, R2)
5. Future Sales Prediction

## Expected Output
- `models/random_forest.pkl` -- trained model
- `outputs/predictions.csv` -- 7-day sales forecast
- `logs/pipeline.log` -- execution log
"@ | Set-Content -Path "README.md" -Encoding UTF8

Write-Host "      All files written." -ForegroundColor Green

# == Step 3: Virtual environment ==============================
Write-Host "[3/6] Creating virtual environment..." -ForegroundColor Yellow
python -m venv venv
Write-Host "      venv created." -ForegroundColor Green

# == Step 4: Install packages =================================
Write-Host "[4/6] Installing Python packages..." -ForegroundColor Yellow
& "venv\Scripts\pip.exe" install pandas numpy scikit-learn matplotlib joblib --quiet
Write-Host "      Packages installed." -ForegroundColor Green

# == Step 5: Test the pipeline ================================
Write-Host "[5/6] Running pipeline to verify zero errors..." -ForegroundColor Yellow
Write-Host ""
& "venv\Scripts\python.exe" main.py
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "      Pipeline ran successfully!" -ForegroundColor Green
} else {
    Write-Host "      ERROR: pipeline failed. Check output above." -ForegroundColor Red
    Write-Host "      Fix the error before pushing to GitHub." -ForegroundColor Red
    exit 1
}

# == Step 6: Git init, commit, push ===========================
Write-Host "[6/6] Initialising Git and pushing to GitHub..." -ForegroundColor Yellow

git init
git add .
git commit -m "Initial commit: retail demand forecasting pipeline"
git branch -M main
git remote add origin $repoUrl
git push -u origin main

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Your project is ready. Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  Open in PyCharm:" -ForegroundColor Yellow
Write-Host "    File -> Open -> select this folder" -ForegroundColor White
Write-Host "    Settings -> Project -> Python Interpreter" -ForegroundColor White
Write-Host "    -> Add -> Existing -> venv\Scripts\python.exe" -ForegroundColor White
Write-Host ""
Write-Host "  Open in VS Code:" -ForegroundColor Yellow
Write-Host "    code ." -ForegroundColor White
Write-Host ""
Write-Host "  Run again anytime:" -ForegroundColor Yellow
Write-Host "    venv\Scripts\activate" -ForegroundColor White
Write-Host "    python main.py" -ForegroundColor White
Write-Host ""
Write-Host "  Check GitHub -- all files are now online." -ForegroundColor Green
Write-Host ""
