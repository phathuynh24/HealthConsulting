from flask import Flask, request, jsonify
from transformers import TextClassificationPipeline, TFAutoModelForSequenceClassification, BertTokenizer
import pandas as pd
import numpy as np
import joblib

app = Flask(__name__)

# Constants
# Window ACER NITRO 5
# path = "D:/Nam_3/HK2/AI/NLP"

# Macbook
path = "/Users/phathuynhtien/Downloads/UIT/Model-Recommendation"
MODEL_1_PATH = f"{path}/Disease Diagnosis Model/Model_1/Model/"
MODEL_2_PATH = f"{path}/Disease Diagnosis Model/Model_2/Model/model.pkl"
SYMPTOM_CSV_FILE_PATH = f"{path}/Disease Diagnosis Model/Model_2/Dataset/Symptom-severity.csv"
SYMPTOM_EXCEL_FILE_PATH = f"{path}/Disease Diagnosis Model/Model_2/Dataset/Dataset_Vi/Symptom-severity_Vi.xlsx"
DISEASE_EXCEL_FILE_PATH = f"{path}/Disease Diagnosis Model/Model_2/Dataset/Dataset_Vi/symptom_Description_Vi.xlsx"

NUM_CLASSES = 24

# Load models and tokenizer
model_1 = TFAutoModelForSequenceClassification.from_pretrained(MODEL_1_PATH)
tokenizer = BertTokenizer.from_pretrained('bert-base-cased')
model_2 = joblib.load(MODEL_2_PATH)

# Load data
df = pd.read_csv(SYMPTOM_CSV_FILE_PATH)
df_symptom_vi_en = pd.read_excel(SYMPTOM_EXCEL_FILE_PATH)
df_disease_vi_en = pd.read_excel(DISEASE_EXCEL_FILE_PATH)

@app.route('/get_symptoms', methods=['GET'])
def get_symptoms():
    symptoms_Vi = df_symptom_vi_en["Symptom_Vi"].tolist()
    symptoms_En = df_symptom_vi_en["Symptom_En"].tolist()
    
    symptoms_En = [symptom.capitalize() for symptom in symptoms_En]
    symptoms_Vi = [symptom.capitalize() for symptom in symptoms_Vi]
    
    return jsonify({'symptoms_Vi': symptoms_Vi, 'symptoms_En': symptoms_En})

@app.route('/predict_1', methods=['POST'])
def predict_1():
    text = request.json['text']
    pipe = TextClassificationPipeline(model=model_1, tokenizer=tokenizer, top_k=NUM_CLASSES)
    prediction = pipe(text)
    prediction_Vi = df_disease_vi_en.loc[df_disease_vi_en['Disease_En'] == prediction[0][0]['label']]['Disease_Vi'].values[0]
    prediction_Vi = {'label': prediction_Vi, 'score': prediction[0][0]['score']}
    return jsonify(prediction_Vi)

@app.route('/predict_2', methods=['POST'])
def predict_2():
    symptoms = request.json['symptoms']

    # Preprocess symptoms
    a = np.array(df["Symptom"])
    b = np.array(df["weight"])
    for i in range(len(symptoms)):
        for j in range(len(a)):
            if symptoms[i] == a[j]:
                symptoms[i] = b[j]
    
    # Prepare input for prediction
    nulls = [0] * (17-len(symptoms))
    input_data = [symptoms + nulls]

    # Make prediction using the loaded model
    disease = model_2.classes_
    score = model_2.decision_function(input_data)

    # Combine disease list and softmax scores
    combined_results = list(zip(disease, score[0]))

    # Sort by score from high to low
    sorted_results = sorted(combined_results, key=lambda x: x[1], reverse=True)

    # Get top 3 diseases
    top_diseases = sorted_results[:3]

    # Get disease names in Vietnamese and scores
    diseases_Vi_scores = [{'label': df_disease_vi_en.loc[df_disease_vi_en['Disease_En'] == disease[0]]['Disease_Vi'].values[0], 'Score': disease[1]} for disease in top_diseases]

    # Return the predicted disease and scores
    return jsonify({'disease': diseases_Vi_scores})

@app.route('/predict_disease_weighted_combination', methods=['POST'])
def predict_disease_weighted_combination():
    text = request.json['text']
    symptoms = request.json['symptoms']
    weights = request.json['weights']

    # Predict with model 1
    pipe = TextClassificationPipeline(model=model_1, tokenizer=tokenizer, top_k=NUM_CLASSES)
    prediction1 = pipe(text)
    disease1 = [pred['label'].lower() for pred in prediction1[0]]
    score1 = [pred['score'] for pred in prediction1[0]]

    # Preprocess symptoms for model 2
    a = np.array(df["Symptom"])
    b = np.array(df["weight"])
    for i in range(len(symptoms)):
        for j in range(len(a)):
            if symptoms[i] == a[j]:
                symptoms[i] = b[j]
    
    # Prepare input for prediction with model 2
    nulls = [0] * (17-len(symptoms))
    input_data = [symptoms + nulls]

    # Make prediction using model 2
    disease2 = [d.lower() for d in model_2.classes_]
    score2 = model_2.decision_function(input_data)

    def softmax(scores):
        exp_scores = np.exp(scores)
        return exp_scores / np.sum(exp_scores)

    # Calculate softmax scores for model 2
    softmax_scores2 = softmax(score2[0])

    # Combine disease list and softmax scores for model 2
    combined_results2 = list(zip(disease2, softmax_scores2))

    # Combine the results from the two models with weights
    combined_results = {}
    for disease, score in zip(disease1, score1):
        combined_results[disease] = score * weights[0]
    for disease, score in combined_results2:
        if disease in combined_results:
            combined_results[disease] += score * weights[1]
        else:
            combined_results[disease] = score * weights[1]

    # Sort by score from high to low
    sorted_results = sorted(combined_results.items(), key=lambda x: x[1], reverse=True)

    # Process sorted_results to include Vietnamese translation and percentages
    processed_results = []
    for disease, score in sorted_results:
        disease_en = disease.capitalize()
        disease_vi_entry = df_disease_vi_en.loc[df_disease_vi_en['Disease_En'].str.lower() == disease]
        if not disease_vi_entry.empty:
            disease_vi = disease_vi_entry['Disease_Vi'].values[0].capitalize()
            description = disease_vi_entry['Description_Vi'].values[0]
        else:
            disease_vi = "N/A" 
            description = "N/A"
        percentage = f"{score * 100:.2f}%"
        
        processed_results.append([disease_en, disease_vi, percentage, description])

    # Return the processed results
    return jsonify({"disease": processed_results})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)