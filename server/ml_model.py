from google.cloud import storage
import tensorflow as tf
from tensorflow.keras import Input, Model
from tensorflow.keras.layers import Dense, Concatenate
from tensorflow.keras.optimizers import Adam
import os

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'C:/Users/vishn/Desktop/FlaskGoogleBackend/glossy-fastness-404223-4f353d9f4ab3.json'

# Create a Cloud Storage client.
gcs = storage.Client()

# Get the bucket that the file will be uploaded to.
bucket = gcs.get_bucket('important_data_renovision')

# Get the blob that you want to download.
blob = storage.Blob('processed_property_conditions.csv', bucket)

# Download the file to a destination
blob.download_to_filename('new_processed_property_conditions.csv')

# Now the file has been downloaded locally, you can use a local file path
csv_file_path = 'new_processed_property_conditions.csv'

# Load the CSV data into a TensorFlow Dataset
def get_dataset(file_path, label_name, batch_size=32):
    dataset = tf.data.experimental.make_csv_dataset(
        file_path,
        batch_size=batch_size,
        label_name=label_name,
        na_value="?",
        num_epochs=1,
        ignore_errors=True,
        header=True
    )
    return dataset

# Use the utility function to create the dataset
train_dataset = get_dataset(csv_file_path, label_name='RATING')

# Define which features are categorical
categorical_features = [
    'wall_type', 'roof_type', 'lawn_type', 'interior_quality', 'trending_style'
]

# Define which features are numerical
numerical_features = [
    'holes_cracks', 'cosmetic_dmg_level', 'window_count'
]

# Define the input layers for each feature
inputs = {
    feature: Input(name=feature, shape=(), dtype='string') 
    if feature in categorical_features else Input(name=feature, shape=(), dtype='float32') 
    for feature in categorical_features + numerical_features
}
# Preprocess the input layers if necessary (e.g., normalization, encoding)
# You need to define these preprocessing steps based on your feature types and requirements

# Combine all inputs into a single list (preserving the order of feature_names)
combined_inputs = Concatenate()(list(inputs.values()))

# Define the rest of the neural network
x = Dense(64, activation='relu')(combined_inputs)
x = Dense(64, activation='relu')(x)
output = Dense(1)(x)

# Create the model
model = Model(inputs=inputs, outputs=output)

# Compile the model with the Adam optimizer and mean squared error loss function
model.compile(optimizer=Adam(), loss='mean_squared_error')

# Train the model
# Convert the dataset into a format that contains a dictionary with feature names mapping to tensor values
def preprocess(features, label):
    return {key: value for key, value in features.items()}, label

train_dataset = train_dataset.map(preprocess)

# Train the model with the dataset
model.fit(train_dataset, epochs=10, steps_per_epoch=30)

# Save the trained model to Google Cloud Storage
# Ensure that the Google Cloud environment is properly configured to save directly to GCS
model_save_path = 'saved_model' # Temporarily save locally
model.save(model_save_path)

# Upload the saved model to GCS
bucket.blob('saved_model').upload_from_filename(model_save_path)
