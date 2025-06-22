# Awas Guncang: A Mobile App for Future InaEEWS Dissemination

**Awas Guncang** is a mobile application developed as part of a research project focused on the future dissemination of the Indonesian Earthquake Early Warning System (InaEEWS). This app is designed to be a proof-of-concept for how warnings and information from InaEEWS can be effectively delivered to the public using modern mobile technologies.

This project is the implementation component of the undergraduate thesis titled: *"Design and Implementation of Awas Guncang: a Mobile App for Future Dissemination of InaEEWS"*.

<table>
  <tr>
    <td><img src="https://i.imgur.com/bRyG0WE.png" alt="Screenshot on Explore Menu" width="200"></td>
    <td><img src="https://i.imgur.com/IhvyIOx.png" alt="Screenshot on Alert" width="200"></td>
    <td><img src="https://i.imgur.com/Ax1bnhp.png" alt="Screenshot on Event's Detail" width="200"></td>
  </tr>
</table>

## 📖 About The Project

Indonesia is located in a seismically active region, making an effective earthquake early warning system (EEWS) crucial for public safety. While Indonesia is developing its own system (InaEEWS), the dissemination of its warnings to the public remains a challenge. This project explores a potential solution by creating **Awas Guncang**, a mobile application that serves as a channel for these critical alerts.

The application is designed to:
- Receive and process earthquake raw warnings.
- Notify users based on their predicted shaking intensity.
- Provide timely and actionable information during an earthquake event.
- Serve as a robust and scalable model for the eventual nationwide rollout of InaEEWS.

## 🛠️ Tech Stack

The application is built using a modern, cross-platform technology stack:

- [**Flutter**](https://flutter.dev/): The UI toolkit for building the application for both Android and iOS from a single codebase.
- [**Firebase Cloud Messaging (FCM)**](https://firebase.google.com/docs/cloud-messaging): Used as the core of the push notification system to send data messages containing warning and event information.
- [**Cloud Firestore**](https://firebase.google.com/docs/firestore): A NoSQL database used to store user-submitted reports and feedback, as well as potentially storing event information.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps. **Currently only working on Android**

### Prerequisites

- Flutter SDK: [Installation Guide](https://docs.flutter.dev/get-started/install)
- A Firebase project. You will need your own `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS).

### Installation

1.  Clone the repo
    ```sh
    git clone [https://github.com/your_username/awas-guncang.git](https://github.com/your_username/awas-guncang.git)
    ```
2.  Navigate to the project directory
    ```sh
    cd awas-guncang
    ```
3.  Install Flutter packages
    ```sh
    flutter pub get
    ```
4.  Place your Firebase configuration files (`google-services.json` and/or `GoogleService-Info.plist`) in the appropriate directories.
5.  Run the app
    ```sh
    flutter run
    ```

## 🤝 Contributing

This project was created for academic purposes. As such, contributions are not actively sought at this time. However, you are welcome to fork the repository and use it as a reference for your own work, in accordance with the license.

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

Hanif Kurniawan - [hanifkurniawan@stmkg.ac.id](mailto:hanifkurniawan@stmkg.ac.id)

Project Link: `https://github.com/hanjpk/awas-guncang`
