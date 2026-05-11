import numpy as np

def calculate_mape(y_true, y_pred):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    non_zero_mask = y_true != 0
    return np.mean(
        np.abs((y_true[non_zero_mask] - y_pred[non_zero_mask])
               / y_true[non_zero_mask])
    ) * 100
