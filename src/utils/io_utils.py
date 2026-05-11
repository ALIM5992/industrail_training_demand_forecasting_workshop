import pandas as pd

def load_csv(path: str) -> pd.DataFrame:
    return pd.read_csv(path)

def save_csv(df, path: str):
    df.to_csv(path, index=False)
