from google.cloud import storage
import tensorflow as tf
from tensorflow.keras import layers, models
import os

# Set up the Google Cloud credentials and client
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = 'C:/Users/vishn/Desktop/FlaskGoogleBackend/glossy-fastness-404223-4f353d9f4ab3.json'
gcs = storage.Client()

# Assuming you have already uploaded the processed dataset to GCS
bucket_name = 'important_data_renovision'
blob_name = 'processed_property_conditions.csv'
local_file_path = 'new_processed_property_conditions.csv'

bucket = gcs.get_bucket(bucket_name)
blob = bucket.blob(blob_name)
blob.download_to_filename(local_file_path)

# Load the processed CSV data into a TensorFlow Dataset
dataset = tf.data.experimental.make_csv_dataset(
    local_file_path,
    batch_size=32,
    label_name='RATING',
    na_value="?",
    num_epochs=1,
    ignore_errors=True
)

# Rename the column
dataset = dataset.map(lambda x, y: ({'roof_type_solar_panel' if k == 'roof_type_solar panel' else k: v for k, v in x.items()}, y))

# Define the feature columns
feature_columns = []
for header in ['holes_cracks', 'cosmetic_dmg', 'window_count', 'latitude', 'longitude']:
    feature_columns.append(tf.feature_column.numeric_column(header))

# The categorical features have been one-hot encoded, so they're already represented as numeric columns
for header in ['property_type', 'trending_style', 'wall_type_metal', 'wall_type_wood',
               'roof_type_solar_panel', 'roof_type_tile', 'lawn_type_none', 'lawn_type_small',
               'interior_quality_fair', 'interior_quality_good', 'interior_quality_poor']:
    feature_columns.append(tf.feature_column.numeric_column(header))

# Create a feature layer from the feature columns
feature_layer = tf.keras.layers.DenseFeatures(feature_columns)

# Build, compile, and train the model
model = models.Sequential([
    feature_layer,
    layers.Dense(128, activation='relu'),
    layers.Dense(128, activation='relu'),
    layers.Dense(1)
])

model.compile(optimizer='adam',
              loss='mean_squared_error',
              metrics=['mean_absolute_error'])

# Convert the dataset into a format that contains a dictionary with feature names mapping to tensor values
def preprocess(features, label):
    return features, label

train_dataset = dataset.map(preprocess)

# Train the model
model.fit(train_dataset, epochs=1000)
loss, mae = model.evaluate(train_dataset)
print(f"Model Mean Absolute Error: {mae}")
# Save the trained model
model_save_path = 'saved_model_new'
model.save(model_save_path)

# Print a summary of the model
model.summary()
