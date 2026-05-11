import pandas as pd
from src.config.config import DATA_RAW_PATH

def preprocess_run():
    # Loads raw sales data, parses dates, removes null rows
    df = pd.read_csv(DATA_RAW_PATH)
    df['date'] = pd.to_datetime(df['date'])
    df = df.dropna()
    return df
