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

### User Interface
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/ab7ec712-6ef5-4a45-b93a-22a9f1109f4c" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/254824ea-7c19-4c62-a32a-e5ab8a0264bd" width="300"/>
    </td>
  </tr>
</table>

### Doctor's Interface
<table>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/9ca0c01e-ec2f-450d-8c0f-27e91a869cb7" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/19e46217-ecc5-4009-b12c-f07d7592ee6a" width="300"/>
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/e0f0e13e-995b-4772-8308-1e5b7dd94e79" width="300"/>
    </td>
  </tr>
</table>

### Admin Interface
<table>
  <tr>
    <td style="text-align: center;">
      <img src="https://github.com/user-attachments/assets/0d25285f-f2d4-4043-83f9-39be9a9fbaca" width="300"/>
    </td>
    <td style="text-align: center;">
      <img src="https://github.com/user-attachments/assets/7a2341d9-ef69-47d0-afcc-f2e8da462b02" width="300"/>
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
