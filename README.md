# 🗑️ Binnit — Smart Waste Management App

<p align="center">
  <strong>A modern, eco-friendly waste management mobile application built with Flutter</strong>
</p>

---

## 📖 About

**Binnit** is an intelligent waste management application designed to make waste collection and recycling effortless. Users can schedule pickups, track drivers in real-time, explore a waste marketplace, monitor smart bins, and contribute to a greener planet — all from the palm of their hand.

---

## ✨ Features

### 🔐 Authentication
- **Email/Password** login and signup
- **Google Sign-In** integration
- **Phone Number OTP** verification
- Smooth onboarding flow with animated transitions

### 🏠 Home Dashboard
- Overview of scheduled pickups and activity
- Quick-access cards for all major features
- Eco-impact stats and rewards

### 📅 Schedule Pickup
- **Custom date & time picker** — choose the exact pickup time
- Multiple address selection (Home, Office, or custom)
- Interactive map preview with pickup location
- Pickup summary with schedule details

### 📦 Pickup Details
- Waste weight input with slider
- Waste type selection (Paper, Plastic, Metal, Glass, E-waste, Organic)
- Additional options (fragile items, special handling)
- Real-time price breakdown and estimation

### 🚚 Live Driver Tracking
- **Swiggy-style real-time tracking** with animated map
- **Animated truck icon** moving along the route toward the user's location
- **Pulsing destination marker** with home icon
- **ETA countdown** — shows estimated arrival time
- **Tracking timeline** — step-by-step status updates
- **Driver details** — name, rating, trip count, vehicle info
- **Call & chat buttons** to contact the driver directly

### 💰 Marketplace
- Browse waste material market rates
- Earnings tracker with trends
- Rate comparison chips for different materials

### 💳 Payment
- Multiple payment methods (UPI, Card, Net Banking, EcoWallet, Cash)
- Promo code support
- Animated payment processing
- Success screen with transaction details & tracking navigation

### 🗑️ Smart Bin Monitoring
- Real-time bin fill-level tracking
- Smart bin locations and status

### 📋 Subscription Plans
- Flexible subscription tiers
- Plan comparison and management

---

## 🛠️ Tech Stack

| Technology     | Purpose                          |
| -------------- | -------------------------------- |
| **Flutter**    | Cross-platform UI framework      |
| **Dart**       | Programming language              |
| **Material 3** | Design system                    |
| **CustomPaint**| Map rendering & route animations |

---

## 📂 Project Structure

```
eco_waste_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── theme/
│   │   └── app_theme.dart                 # Global theme, colors, text styles
│   └── screens/
│       ├── login_screen.dart              # Login with email/phone toggle
│       ├── signup_screen.dart             # Registration screen
│       ├── phone_verification_screen.dart # OTP verification
│       ├── home_screen.dart               # Main dashboard
│       ├── schedule_pickup_screen.dart    # Date/time picker & address selection
│       ├── pickup_details_screen.dart     # Waste details & pricing
│       ├── pickup_tracking_screen.dart    # Live driver tracking with animated map
│       ├── payment_screen.dart            # Payment methods & checkout
│       ├── marketplace_screen.dart        # Waste marketplace & rates
│       ├── smart_bin_screen.dart          # Smart bin monitoring
│       └── subscription_screen.dart       # Subscription plans
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (3.0+)
- **Dart** (3.0+)
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ayishathul-rinsha/Binnit.git
   cd Binnit/eco_waste_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK** (optional)
   ```bash
   flutter build apk --release
   ```

---

## 📱 Screens Preview

| Screen             | Description                                      |
| ------------------ | ------------------------------------------------ |
| Login              | Email/Password & Phone OTP toggle                |
| Sign Up            | User registration with Google sign-in            |
| Home               | Dashboard with quick actions & eco stats         |
| Schedule Pickup    | Custom date/time picker & map preview            |
| Pickup Details     | Waste type, weight & price breakdown             |
| Live Tracking      | Animated truck, driver info & ETA countdown      |
| Payment            | Multi-method checkout with success screen        |
| Marketplace        | Market rates & earnings overview                 |

---

## 🎨 Design Highlights

- **Custom map rendering** using `CustomPainter` for grid, streets & route paths
- **Smooth animations** — truck movement, pulse effects, fade transitions
- **Premium UI** with gradient cards, glassmorphism elements, and micro-interactions
- **Green-themed** design system reflecting the eco-friendly mission
- **Responsive layouts** optimized for various screen sizes

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">
  Made with 💚 for a greener planet 🌍
</p>
