# Retail Demand Forecasting Workshop
**NexAI Academy x NIBM -- Technical Hands-On Workshop**

A full end-to-end ML pipeline for retail sales forecasting built using
Python, scikit-learn, and industry-standard modular design.

## How to Run

`powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python main.py
`

## Pipeline Steps
1. Data Preprocessing
2. Feature Engineering
3. Model Training (Random Forest)
4. Model Evaluation (MAE, MSE, R2)
5. Future Sales Prediction

## Expected Output
- models/random_forest.pkl -- trained model
- outputs/predictions.csv -- 7-day sales forecast
- logs/pipeline.log -- execution log
