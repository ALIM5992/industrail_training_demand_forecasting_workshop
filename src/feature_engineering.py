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
