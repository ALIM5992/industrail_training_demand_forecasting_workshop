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
