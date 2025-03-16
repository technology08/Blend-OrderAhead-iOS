# Blend: An OrderAhead iOS App

**A streamlined iOS app for pre-ordering food and beverages, built and tested in a local business.**
Designed for **fast and secure mobile payments**, Blend allows users to order in **three taps** and track their orders in real time, minimizing friction, increasing orders, and enabling students to purchase a beverage in the tight time before class.. It features the latest technologies including Apple Pay and Stripe, leverages Amazon Web Service's Lambda cloud function service as well as CloudKit's database, and has multiple redundancies in place to ensure that if any one of these systems fail, the customer is not charged. Further, Firebase Analytics is used to track how much of each drink is being sold, allowing the coffee bar to adjust its menu accordingly. 

![Leaning Eagle Main](readme-images/leaningeagle.PNG)
![Blend Smoothie Bar Main](readme-images/blend.PNG)
![Order Page](readme-images/order.PNG)

**NOTE: This project is mostly archived, and I decided to open source this project to enable other businesses seeking a head start for their own online ordering apps to fork this repository for their own purposes.**

## 📌 Features  

✅ **Order Ahead** – Users can pre-order food and drinks through the mobile app.  
✅ **Seamless Payments** – Integrated with **Apple Pay and Stripe API** for secure transactions.
✅ **Secure Transactions** – AWS Lambda Cloud Functions support authentication in the cloud, mitigating security risks.
✅ **Minimalist UI** – Orders can be placed in **three taps** for maximum efficiency between classes or meetings.  
✅ **Cloud-Backed Database** – Orders stored securely using **CloudKit**.  
✅ **Real-Time Analytics** – Track retention rate, orders, and customer usage in real-time with Firebase.


## 🛠️ Tech Stack  

- **Languages:** Swift
- **Backend:** AWS Lambda, CloudKit
- **Frontend:** UIKit, Storyboards
- **Payments:** Apple Pay, Stripe API  
- **Networking:** URLSession, Firebase Functions  
- **Analytics:** Firebase Analytics

## 📲 Setup & Installation  

### 1️⃣ Clone the Repository  
```bash
git clone https://github.com/technology08/Blend-OrderAhead-iOS.git
cd Blend-OrderAhead-iOS
```

### 2️⃣ Open in Xcode  
- Open `BlendSmoothieBar.xcodeproj` in **Xcode** (latest version recommended).  
- Ensure you have **CocoaPods installed**, then run:  
  ```bash
  pod install
  ```

### 3️⃣ Configure Firebase  
- **Step 1:** Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)  
- **Step 2:** Download `GoogleService-Info.plist` and place it in the project root.  
- **Step 3:** Enable Firestore, Authentication, and Cloud Functions in Firebase.
- 
### 4️⃣ Add Secret API Keys
- **Step 1:** Search for "INSERT" in all files within the `BlendSmoothieBar/` directory
- **Step 2:** Add Apple merchant IDs (create within Xcode), AWS API key for Lambda, and Stripe API key for payments

### 5️⃣ Run the App  
- Select an iPhone simulator or device in Xcode.  
- Click Run or press `Cmd + R`.  

## 🔗 API Integrations  

- **[Stripe API](https://stripe.com/)** – Secure payment processing.  
- **[Firebase Firestore](https://firebase.google.com/)** – Cloud database for order storage.  
- **[AWS Lambda](https://aws.amazon.com/lambda/)** – Serverless backend execution.  
- **[Apple Pay](https://developer.apple.com/documentation/passkit/apple_pay/)** – One-tap payments.

## 📌 Roadmap / Future Improvements  

🔹 Open source an admin dashboard for store owners (under development). 
🔹 Implement loyalty rewards system for frequent customers.    

## 📜 License  

This project is licensed under the **MIT License**. See `LICENSE` for details.  

## 👨‍💻 Author  

👤 **Connor Espenshade**  
- [LinkedIn](https://linkedin.com/in/cespenshade)  
- [GitHub](https://github.com/technology08)

## 📬 Contributing  

Contributions are welcome! To contribute:  
1. Fork the repository
2. Create a feature branch (`git checkout -b feature-new`)  
3. Commit your changes (`git commit -m "Added new feature"`)  
4. Push to GitHub (`git push origin feature-new`)  
5. Submit a Pull Request 🎉  

