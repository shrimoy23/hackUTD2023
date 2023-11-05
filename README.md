# RenoVision.AI - HackUTD2023
# Shrimoy Satpathy, Kush Gupta, Akshat Sharma, Vishnu Nambiar
Devpost: https://devpost.com/software/renovision

## Inspiration
The challenge of evaluating properties accurately and efficiently in the real estate industry was our inspiration. We recognized that traditional methods of property assessment are often time-consuming and not fully encompassing regarding all potential variables affecting a property's value and condition. By harnessing the capabilities of LiDAR technology leveraging Machine Learning along with Artificial Intelligence, we envisioned a tool that could perform comprehensive analyses quickly and deliver insights that are both deep and actionable. 

We aimed to create a solution that could integrate seamlessly into the workflow of real estate professionals, providing them with a robust evaluation tool. This tool would not only save time but also bring a level of precision to property assessments that was previously unattainable with conventional methods. The goal was to empower users to make informed decisions by providing a detailed property narrative and valuation, derived from a multitude of data points collected through our technology.

## What it does
Our application leverages LiDAR technology, ML, and AI to analyze and evaluate properties. It works through an intuitive app built with Swift, enabling users to utilize their device's camera and Apple's ARKit to perform detailed scans of properties, both inside and out - serving as the basis of our evaluation scheme. 

The application captures encapsulates a wealth of data regarding the property, including environmental conditions and location-specific factors. The data is transformed into a sentiment analysis and a valuation plan for the property. Our neural network model processes this information and is hosted on the Google Cloud, allowing it to be accessed and used remotely. The model is designed to be efficient and not over-engineered, ensuring quick and accurate predictions. Despite its streamlined design, it achieved a loss of 0.0445 and a mean absolute error rate of 0.1559 when comparing predictions to our training data - a reliability rate we're proud of.

## How we built it
We built our application with Swift for the front end and Flask for the back end. By leveraging Apple's ARKit along with Metal and MetalKit, we were able to perform real-time vector mapping of environments through our iPhones. These detailed point-cloud models are converted into computation geometric maps, which help segment property values. 

These maps, together with historical data, are input into our TensorFlow machine learning model to evaluate metrics which is then fed into our artificial intelligence analysis scheme through LangChain. We process this data and produce a narrative based on our analysis of the property's features and potential value.

## Challenges we ran into
One of the primary challenges was the interpretation and integration of multidimensional LiDAR point cloud datasets. The visual data, coupled with variable environmental factors, presented a unique challenge that pushed the boundaries of our algorithmic model design. Additionally, integrating the frontend with a high-performing backend to process the data effectively was a task that required meticulous attention and innovation.

## Accomplishments that we're proud of
We are extremely proud of having a full-stack mobile application that is able to harness Apple's impressive hardware and combine its potential leveraging machine learning models for our specific goal.

## What we learned
We learned the intricacies of Apple's ARKit leveraging machine learning models, particularly in processing and analyzing complex data types and enriching our understanding of property evaluation. While also utilizing NLP and LiDAR technologies, emerging with a fully encompassing tool that is both intuitive and scientifically profound.

## What's next for RenoVision
Moving forward, RenoVision is focused on refining our technology and expanding our reach. We plan to enhance our machine learning models with more data, streamline the user experience, and integrate more advanced technologies to improve the accuracy and quality of our assessments. We're also aiming to integrate broader environmental and market data into our property evaluations for even greater precision.
