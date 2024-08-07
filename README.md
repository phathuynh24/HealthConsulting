![HealthConsulting](https://github.com/user-attachments/assets/c55f0e8e-8707-43db-a35c-c7b18aa6c4a2)

# Health Consulting

<table>
<tr>
<td>
  An advanced health consulting application featuring chat and video consultations, appointment management, health records, a GPT-powered chatbot, and a medical product marketplace. The app includes three modules for users, doctors, and admins. It integrates AI models for disease prediction to suggest suitable doctors for consultation.
</td>
</tr>
</table>

## Features

| Feature | Description |
| --- | --- |
| 🏥 **Register, Login, Forgot Password** | User authentication functionality. |
| 📅 **Appointment Management** | Schedule, cancel, or reschedule consultation appointments. |
| 👨‍⚕️ **Select Doctors and Consult** | Allows users to select doctors, submit consultation requests, and receive online consultations. |
| 💬 **In-app Messaging and Video Calls** | Facilitates communication between users and doctors. |
| 📋 **Manage Health Profiles** | Users can create and manage their personal health profiles with medical history and test results. |
| 📊 **Monitor Health Metrics** | Track health indicators such as temperature, height, weight, and BMI. |
| 📝 **Store Consultation Records** | Keeps a record of consultations and medical history for future reference. |
| 💳 **Payment and Feedback** | Enables users to pay for services and provide feedback on consultations. |
| 📖 **Health Articles** | Read health-related articles. |
| 🛒 **Medical Product Marketplace** | Purchase medical products from the integrated shop. |
| 🤖 **AI Doctor Recommendation** | Get doctor suggestions based on symptom analysis using AI. |
| 🗣️ **Anonymous Community Q&A** | Participate in anonymous health discussions. |
| 🗂️ **Consultation Results** | View and download consultation outcomes. |
| 💻 **Admin Management** | Admins can manage doctor accounts, handle payments, and view statistics. |
| 📈 **Doctor Statistics** | Doctors can view statistics such as revenue and consultation counts. |
| 🔧 **Admin Tools** | Admins can manage doctors, delete user reviews, and handle anonymous questions. |
| 🏪 **Product and Order Management** | Admins manage products, orders, and purchase history. |
| 📝 **Feedback Management** | Admins handle feedback and reviews. |
| 🗂️ **User Management** | Admins manage user information including personal details, addresses, reviews, and orders. |

### Main Functions in the User Interface
- 🏥 **Register, Login**: User authentication.
- 📅 **Schedule Video Consultations**: Book video consultation appointments.
- 📅 **Appointment Management**: Manage consultation schedules.
- 💬 **Messaging with Doctors and Admins**: Direct communication.
- 🗣️ **Anonymous Community Q&A**: Engage in anonymous health discussions.
- 📋 **Manage Health Profiles**: Manage health records for self and family members.
- ⭐ **Rate Services**: Provide feedback after consultations.
- 📊 **Monitor Health Metrics**: Track health indicators.
- 📝 **View Consultation Results**: Access past consultation records.
- 🤖 **Chatbot Integration**: Use a chatbot for health information.
- 👨‍⚕️ **Doctor Recommendations**: Get AI-based doctor suggestions.
- 📖 **Health Articles**: Access health articles.
- 🛒 **Medical Product Marketplace**: Buy health products online.

### Main Functions in the Doctor Interface
- 🏥 **Login**: Authenticate as a doctor.
- 📅 **Manage Consultation Schedule**: Organize appointments.
- 💬 **Online Consultation**: Provide online consultations.
- 💬 **Messaging with Patients and Admins**: Direct communication.
- 🗣️ **Answer Community Questions**: Respond to community Q&A.
- 📋 **Manage Patient Records**: Handle patient health records.
- 📝 **Return Consultation Results**: Provide consultation outcomes.
- 📈 **Statistics**: View consultation and revenue statistics.
- 📖 **Approve Health Articles**: Review and approve health articles.

### Main Functions in the Admin Interface
- 🏥 **Login**: Authenticate as an admin.
- 🔧 **Manage Doctors**: Administer doctor accounts.
- 🗑️ **Delete User Reviews**: Remove inappropriate reviews.
- 🗑️ **Delete Anonymous Questions**: Moderate community questions.
- 💬 **Messaging with Users and Doctors**: Direct communication.
- 💳 **Handle Payments**: Process payments and transactions.
- 📈 **Revenue Statistics**: View financial statistics.
- 📖 **Manage Health Articles**: Administer health articles.
- 🗂️ **Manage User Information**: Oversee user details, addresses, reviews, and orders.
- 🛒 **Manage Products and Orders**: Oversee product listings and order history.
- 📝 **Feedback Management**: Handle feedback and reviews.

## AI-Powered Doctor Recommendation Feature

The Health Consulting app integrates advanced AI models to provide doctor recommendations based on user-reported symptoms. This feature analyzes the symptoms to diagnose potential diseases and then suggests doctors with relevant experience in treating those conditions. Below is a detailed breakdown of the AI models used:

### AI Models Overview

#### Model 1: Detailed Symptom Description Analysis

- **Input**: A detailed description of the user's symptoms.
- **Output**: Predicted disease (the model can distinguish around 22 diseases).
- **Advantages**:
  - Provides accurate disease prediction based on detailed symptom descriptions.
  - Utilizes advanced NLP techniques for better understanding of medical terminologies.
- **Disadvantages**:
  - Requires users to provide comprehensive symptom descriptions, which might be challenging for some.
  - Limited to 22 diseases.
- **Training Libraries**: TensorFlow, Keras
- **Reference**: [Pretrained BERT Model](https://www.kaggle.com/code/faizalkarim/pretrained-bert-98-8)

#### Model 2: Symptom List Selection Analysis

- **Input**: Selection of symptoms from a predefined list of approximately 200 symptoms.
- **Output**: Predicted disease (the model can distinguish around 42 diseases).
- **Advantages**:
  - Allows users to easily select symptoms from a list, making it user-friendly.
  - Covers a broader range of diseases (42 diseases).
- **Disadvantages**:
  - The predefined symptom list may not cover all possible user-reported symptoms.
  - The accuracy depends on the user's ability to correctly identify and select symptoms.
- **Training Libraries**: scikit-learn (sklearn)
- **Reference**: [Disease Prediction and Analytics](https://www.kaggle.com/code/kunal2350/disease-prediction-and-analytics/comments)

### Combining AI Models

To leverage the strengths of both models, the app combines their outputs using a weighted approach. The weights assigned are:
- Model 1: 0.4
- Model 2: 0.6

This method ensures a balanced and accurate prediction by considering both detailed descriptions and symptom list selections.

### Example Workflow

1. **User Input**:
    - Users can either provide a detailed description of their symptoms or select symptoms from a list.
2. **Model Analysis**:
    - **Model 1** processes detailed descriptions to predict the disease.
    - **Model 2** processes selected symptoms to predict the disease.
3. **Weighted Combination**:
    - The outputs of both models are combined using the weights (Model 1: 0.4, Model 2: 0.6).
4. **Doctor Recommendation**:
    - Based on the final disease prediction, the app suggests doctors with relevant experience in treating the diagnosed condition.

This AI-powered feature enhances the user experience by providing accurate and reliable doctor recommendations, ensuring users receive the best possible care.

### Model Comparison Table

| Model | Input | Output | Disease Coverage | Training Libraries | Advantages | Disadvantages |
| --- | --- | --- | --- | --- | --- | --- |
| Model 1 | Detailed symptom description | Predicted disease | 22 diseases | TensorFlow, Keras | Accurate with detailed inputs | Requires comprehensive descriptions |
| Model 2 | Selected symptoms from a list | Predicted disease | 42 diseases | scikit-learn (sklearn) | User-friendly, broader disease coverage | Depends on correct symptom selection |

By combining these models, the app ensures robust and comprehensive disease diagnosis and doctor recommendations.

## Installation

### Prerequisites
- Flutter SDK
- Dart SDK
- Python
- Flask

### Steps

1. **Clone the Repository**
    ```bash
    git clone https://github.com/bduy1011/SE121.O11-Do_An_1
    cd SE121.O11-Do_An_1
    ```

2. **Navigate to the API Directory**
    ```bash
    cd SE121.O11-Do_An_1/assist_health/lib/src/api
    ```

3. **Run the API Server**
    ```bash
    python api.py
    ```

4. **Run the Application**
    - Open the project in VSCode.
    - Press the `Run` button on the IDE or use the command palette to run the application.

### Additional Tips
- Ensure all dependencies are installed by running `flutter pub get` in the terminal.
- For detailed instructions on setting up Flutter and Dart, refer to the [Flutter documentation](https://flutter.dev/docs/get-started/install).
- For Python and Flask setup, refer to the [Flask documentation](https://flask.palletsprojects.com/en/2.0.x/installation/).

## Usage

- **Register**: Create a new account or log in with an existing account.
- **Select Doctor**: Choose a doctor from the list for consultation.
- **Choose Health Profile**: Select your own or a family member's health profile that you have created.
- **Submit Consultation Request**: Provide symptom descriptions and submit requests.
- **Make Payments**: Pay for services online.
- **Manage Appointments**: Cancel or reschedule appointments.
- **Consult Online**: Communicate with doctors via messaging or video calls.
- **Review History**: View past consultation records and medical history.
- **Provide Feedback**: Rate the consultation and provide feedback.

### Additional Services:

- **AI-Powered Doctor Recommendations**: Get symptom analysis and recommendations for the most suitable doctor based on their experience with similar cases.
- **Integrated GPT Chatbot**: Use the GPT-powered chatbot for health information and inquiries.
- **Analyze Body Metrics**: Monitor body metrics such as temperature, height, weight, and BMI.
- **Read Health Articles**: Access various health-related articles.
- **Purchase Medical Products**: Buy medical products from the integrated shop.

## Technologies Used 💻

- **Dart**
- **Flutter**: For building the mobile application.
- **Python**: For backend services.
- **Flask**: For server-side logic.
- **Firebase**: For authentication and database management.
- **BloC pattern**: For state management.
- **Agora**: For video calling functionality.
- **ChatGPT-3.5**: For chatbot functionality.

## Screenshots 📸

### Authentication Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/126bbfc6-a2de-4809-bdcb-66774ac0aefe" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/2ba537a2-8eac-418e-9718-77fd062934ab" width="300"/>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/8df8a903-cdb4-4196-9f93-7823b5db6f85" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/74149599-54b4-4687-ab00-59f42a807d0c" width="300"/>
    </td>
  </tr>
</table>

### Home Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/a0ea6832-37a2-4112-af65-5e257e298ae6" alt="User Home Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/428ee3cf-18e0-4fba-91e7-a851b58d34fe" alt="Doctor Home Screen" width="300"/>
    </td>
  </tr>
</table>

### Appointment Management Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/ccc1ff31-f106-41e8-949b-b8239ad3bfad" alt="User Appointment Management Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/797e8cd7-6583-43ee-8171-5e1c81fc470a" alt="Doctor Appointment Management Screen" width="300"/>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/9c477e2c-0901-4c62-8714-608aeab6ca6a" alt="Pending Appointment Detail Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/84c68f90-1ecb-40f7-b888-d3d6c8a620e1" alt="Completed Appointment Detail Screen" width="300"/>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/d869f5e3-39d2-4767-8e61-7601848577aa" alt="Canceled Appointment Detail Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/3baf4e34-50ea-47e5-90cb-a2870528f763" alt="Approved Appointment Screen" width="300"/>
    </td>
  </tr>
  <tr>
    <td colspan="2" style="text-align: center;">
      <img src="https://github.com/user-attachments/assets/8e8080e5-4ec9-4211-b13c-cd15b302b4e5" alt="Appointment Confirmation Screen" width="300"/>
    </td>
  </tr>
</table>

### Doctor Recommendations
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/78366a1e-e7d9-43df-93c5-8ab92b711a2e" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/4636cc36-75ad-4086-a432-dc4412d27bb4" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/2268a699-ba6b-462b-b51f-4b0300d9b2ed" width="300"/>
    </td>
  </tr>
</table>
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/f87f86ee-cf99-42bf-b22b-5b4e1e619d23" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/79dde4fe-00e4-4ee2-b41f-83f0791ce98d" width="300"/>
    </td>
  </tr>
</table>

### Health Record Management Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/c55d32ed-9ee4-4089-b92b-e2aed5fcaab6" alt="Record List Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/0f1da13d-ef1b-4957-b5c9-3962feccd27d" alt="Record Detail Screen" width="300"/>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/7df4a710-c2d7-4f7d-9ced-7cf6c2a92c6f" alt="Add Record Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/0597988d-a164-4024-ab0d-d38fa4c2033b" alt="Edit Record Screen" width="300"/>
    </td>
  </tr>
</table>

### Communication and Feedback Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/5a8520f9-5da6-47a3-8fc5-00b9d7d5af56" alt="Call Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/0f69a73b-5b47-4bb7-8c94-c74d4ffdf5b9" alt="Doctor Rating Screen" width="300"/>
    </td>
  </tr>
  <tr>
    <td colspan="2" style="text-align: center;">
      <img src="https://github.com/user-attachments/assets/76b37193-65aa-43d6-82a8-e395669c5d4a" alt="Review Rating Dialog" width="300"/>
    </td>
  </tr>
</table>

### Examination Result Screens
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/8b11476e-eae2-4653-92ee-74c5aee10921" alt="Examination Results Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/67f4c61b-2f8b-4db8-b2b0-7b8b25a2fae7" alt="Examination Result Detail Screen" width="300"/>
    </td>
  </tr>
</table>

### Chat with doctors/admins
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/edcae927-c8bd-4fec-9260-31ad4ffec0c1" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/831c7754-86d4-46a8-a409-44d8c120f6db" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/edc7af3d-1181-46d5-bb0d-2cae348d150d" width="300"/>
    </td>
  </tr>
</table>

### Chatbot
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/2770aa17-e73d-4093-aca7-7b5b6f43c5c0" width="300"/>
    </td>
  </tr>
</table>

### Medical Products Shop
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/648e4738-91ab-45ce-9fef-d3adcf695453" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/00eb52c3-d283-4c2d-8dcf-1729ead43704" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/2c49cbe6-b336-4ad2-b4d2-56ac5a33083f" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/2ebdb84b-cc79-43a3-b33d-a5d02fbe372f" width="300"/>
    </td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/c7cb235a-fa30-4416-ad3c-0b45b62daba5" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/547804e0-d25d-4f37-8bca-aaecc2db5e36" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/58a1c5cc-e157-441e-a24e-b3d9fb527eaa" width="300"/>
    </td>
  </tr>
</table>

### Articles
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/cb67014c-1cca-4f04-a6d8-622513f7c80b" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/8448b080-cceb-42b7-a869-897353467c6d" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/9b5f235a-c72f-4e36-a1b7-ac7f236ceb00" width="300"/>
    </td>
  </tr>
</table>

### Health Index Analysis
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/55e27557-9619-4d11-8d16-a19086c2d479" alt="Record List Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/0b116c44-a969-440b-b9ab-cd1d30b18324" alt="Record Detail Screen" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/dc2ec1f0-3051-4999-8c22-50812a815c27" alt="Add Record Screen" width="300"/>
    </td>
  </tr>
</table>

## Contributing 🤝

Want to contribute? Great!

To fix a bug or enhance an existing module, follow these steps:

- Fork the repo
- Create a new branch (`git checkout -b improve-feature`)
- Make the appropriate changes in the files
- Add changes to reflect the changes made
- Commit your changes (`git commit -am 'Improve feature'`)
- Push to the branch (`git push origin improve-feature`)
- Create a Pull Request

## Bug / Feature Request 🐛✨

If you encounter a bug or have a feature request, please open an issue by sending an email to 2409huynhphat@gmail.com. Kindly provide details of your query and the expected result in the email.

## To-do 📝

- Add new consultation features.
- Improve user interface and experience.
- Enhance real-time communication capabilities.
- Optimize performance and stability.

## Team 👥

**Development Team**
- [Huynh Tien Phat](https://github.com/phathuynh24)
- [Nguyen Truong Bao Duy](https://github.com/bduy1011)
