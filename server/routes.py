from flask import Blueprint, jsonify, request, render_template
from app import db
from apikey import apikey
import os
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate 
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain, SequentialChain, ConversationChain
from langchain.memory import ConversationBufferMemory
#from ml_model import get_dataset

os.environ['OPENAI_API_KEY'] = apikey
llm = OpenAI(temperature=1)

conversation = ConversationChain(
        llm=llm, 
        verbose=True, 
        memory=ConversationBufferMemory())

main = Blueprint('main', __name__)

@main.route('/', methods=['GET'])
def home():
    # Fetch all documents from the 'houses' collection
    docs = db.collection('houses').stream()

    houses = []
    for doc in docs:
        house = doc.to_dict()
        house['id'] = doc.id  # Add the document ID as 'id'
        houses.append(house)
    return jsonify(houses)

@main.route('/camera', methods=['GET'])
def camera():
    # Implement your logic here
    return jsonify({"message": "Camera endpoint"})

@main.route('/analytics', methods=['GET'])
def analytics():
    # Implement your logic here
    return jsonify({"message": "Analytics endpoint"})


@main.route('/add_house', methods=['POST'])
def add_house():
    data = request.get_json()  # get the data from the request

    # add a new document to the 'houses' collection
    doc_ref = db.collection('houses').document()
    doc_ref.set(data)

    return jsonify({"message": "House added successfully"}), 200

@main.route('/button', methods=['GET'])
def button():
    return render_template('page.html')

@main.route('/delete_house', methods=['DELETE'])
def delete_house():
    data = request.get_json()  # get the data from the request
    doc_id = data.get('id')  # get the document ID from the data

    if doc_id:
        # delete the document from the 'houses' collection
        db.collection('houses').document(doc_id).delete()
        return jsonify({"message": "House deleted successfully"}), 200
    else:
        return jsonify({"message": "Invalid request, no ID provided"}), 400
    
@main.route('/use_llm', methods=['GET','POST'])
def use_llm():
    #data = request.get_json()
    
    
    TEMPLATE = "Provide approximately 50 words on how you would comment on the condition of a hypothetical property (residential), and act as if it is real."
    answer = conversation.predict(input=TEMPLATE)
    print(answer)
    return jsonify({"message": f"{answer}"}), 1000


@main.route('/clear_houses', methods=['DELETE'])
def clear_houses():
    houses_ref = db.collection('houses')
    docs = houses_ref.stream()

    for doc in docs:
        doc.reference.delete()

    return jsonify({'message': 'Houses collection cleared'}), 200

    
# @main.route('/predict', methods=['POST'])
# def predict():
#     # Assuming you're receiving the file path and label name as JSON in the POST request
#     data = request.get_json()
#     file_path = data['file_path']
#     label_name = data['label_name']

#     # Use the get_dataset function from ml_model.py
#     dataset = get_dataset(file_path, label_name)

#     # Here, you would typically pass the dataset to your model for prediction
#     # For the sake of this example, let's just return a simple message
#     return "Dataset loaded successfully"