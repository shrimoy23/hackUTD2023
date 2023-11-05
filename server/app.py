import os
from flask import Flask, jsonify
from flask_cors import CORS
from google.cloud import storage
from google.cloud import firestore
# from ml_model import get_dataset

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'C:/Users/vishn/Desktop/FlaskGoogleBackend/glossy-fastness-404223-4f353d9f4ab3.json'
os.environ["GOOGLE_CLOUD_PROJECT"]="glossy-fastness-404223"
storage_client = storage.Client()
db = firestore.Client()

def create_app():
    app = Flask(__name__)
    CORS(app)

    from routes import main
    app.register_blueprint(main)  # Register the Blueprint

    # the rest of your Flask app setup goes here

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)