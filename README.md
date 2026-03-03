<p align="center">
  <img src="https://img.icons8.com/3d-fluency/94/recycle-sign.png" width="80" alt="Binnit Logo"/>
</p>

<h1 align="center">🗑️ Binnit</h1>

<p align="center">
  <strong>Smart Waste Management — Schedule, Track, Recycle.</strong>
</p>

<p align="center">
  <a href="#-features"><img src="https://img.shields.io/badge/Features-12+-4CAF50?style=for-the-badge" alt="Features"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License"/></a>
</p>

<p align="center">
  <em>An intelligent, beautifully designed mobile application that makes waste collection, recycling, and tracking effortless — built with Flutter & Dart.</em>
</p>

---

## 🌍 The Problem

Every year, **billions of tons** of waste end up in landfills, harming our planet. Waste collection is inefficient, unorganized, and often inconvenient for households. There's no easy way to schedule pickups, track collection trucks, or know the value of recyclable materials.

## 💡 Our Solution

**Binnit** bridges the gap between waste generators and waste collectors through a seamless mobile experience. Users can:

- 📅 **Schedule** waste pickups at their preferred date & time
- 🚚 **Track** the collection truck in real-time (like Swiggy/Uber!)
- 💰 **Earn** by selling recyclable waste at market rates
- 🗑️ **Monitor** smart bin fill levels for smarter disposal
- 🌱 **Contribute** to a greener planet with every pickup

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔐 Authentication
- Email/Password login & signup
- Google Sign-In integration
- Phone number OTP verification
- Animated screen transitions

</td>
<td width="50%">

### 🏠 Home Dashboard
- Personalized welcome banner
- Quick-action cards (Schedule, Smart Bin, Market, Plans)
- Smart bin fill-level overview
- Upcoming pickup details with countdown
- Eco-impact stats (CO₂ saved, trees planted, waste recycled)
- Subscription plan banner

</td>
</tr>
<tr>
<td width="50%">

### 📅 Schedule Pickup
- **Custom date & time picker** — pick the exact time
- Multiple saved addresses (Home, Office, Other)
- Interactive map preview with location pin
- Schedule summary card with gradient design

</td>
<td width="50%">

### 📦 Pickup Details
- Adjustable weight slider
- Waste type selection — Paper, Plastic, Metal, Glass, E-waste, Organic
- Additional options — fragile handling, bag requirements
- Notes section for special instructions
- Real-time price estimation & breakdown

</td>
</tr>
<tr>
<td width="50%">

### 🚚 Live Driver Tracking
- **Swiggy-style animated map** with route rendering
- **Animated truck icon** moving toward your location
- **Pulsing home marker** showing your destination
- **ETA countdown** banner (e.g., "10 min to your place")
- **Tracking timeline** — Confirmed → Assigned → On the Way → Arriving → Complete
- **Driver card** — name, rating ⭐, trip count, vehicle info
- Call 📞 and Chat 💬 buttons

</td>
<td width="50%">

### 💳 Payment System
- UPI (Google Pay, PhonePe, Paytm)
- Credit/Debit Card
- Net Banking
- EcoWallet (in-app wallet)
- Cash on Pickup
- Promo code support
- Animated processing & success screen
- One-tap navigation to live tracking

</td>
</tr>
<tr>
<td width="50%">

### 💰 Marketplace
- Live market rates for recyclable materials
- Earnings tracker with analytics
- Material rate comparison chips
- Category-wise filtering with icons

</td>
<td width="50%">

### 🗑️ Smart Bin Monitoring
- Real-time bin fill-level tracking with animated gauges
- Multiple bin support (General, Recyclable, Organic, Hazardous)
- Auto-schedule pickup when bin is full
- Weekly waste generation statistics with charts
- Bin action controls (notifications, alerts)

</td>
</tr>
<tr>
<td colspan="2">

### 📋 Subscription Plans
- **Free**, **Pro** (₹99/mo), and **Business** (₹299/mo) tiers
- Current plan overview with usage stats
- Feature comparison grid
- Benefits section with icons
- FAQ accordion
- Upgrade/Subscribe button with gradient design

</td>
</tr>
</table>

---

## 🛠️ Tech Stack

| Technology        | Purpose                                     |
| ----------------- | ------------------------------------------- |
| **Flutter**       | Cross-platform mobile UI framework          |
| **Dart**          | Programming language                        |
| **Material 3**    | Google's latest design system               |
| **CustomPainter** | Map rendering, route animations, bin gauges |
| **AnimationController** | Truck movement, pulse effects, transitions |

---

## 🎨 Design Philosophy

```
🔵 Premium First  →  Gradient cards, glassmorphism, shadows
🔵 Micro-Animations →  Smooth transitions, pulse effects, animated truck
🔵 Green-Themed    →  Eco-friendly color palette (#4A6741 primary)
🔵 Consistent      →  Unified AppTheme with reusable text styles & decorations
🔵 Responsive      →  Adapts to different screen sizes
```

### Color Palette

| Color         | Hex       | Usage                 |
| ------------- | --------- | --------------------- |
| Primary Green | `#4A6741` | Buttons, accents      |
| Dark Green    | `#3D5635` | Gradients, headers    |
| Light Green   | `#6B8E5F` | Highlights            |
| Accent Green  | `#8CB369` | Secondary accents     |
| Background    | `#F5F5F0` | Page backgrounds      |
| Text Primary  | `#2D2D2D` | Headings, body text   |
| Text Secondary| `#6B6B6B` | Subtitles, captions   |

---

## 📂 Project Structure

```
Binnit/
├── eco_waste_app/
│   ├── lib/
│   │   ├── main.dart                          # 🚀 App entry point
│   │   ├── theme/
│   │   │   └── app_theme.dart                 # 🎨 Colors, text styles, decorations
│   │   └── screens/
│   │       ├── login_screen.dart              # 🔐 Email/Phone login toggle
│   │       ├── signup_screen.dart             # 📝 Registration with Google sign-in
│   │       ├── phone_verification_screen.dart # 📱 OTP verification flow
│   │       ├── home_screen.dart               # 🏠 Dashboard + bottom navigation
│   │       ├── schedule_pickup_screen.dart     # 📅 Date/time picker + map
│   │       ├── pickup_details_screen.dart      # 📦 Weight, type, pricing
│   │       ├── pickup_tracking_screen.dart     # 🚚 Live tracking + driver info
│   │       ├── payment_screen.dart             # 💳 Payment + success screen
│   │       ├── marketplace_screen.dart         # 💰 Market rates + earnings
│   │       ├── smart_bin_screen.dart           # 🗑️ Bin monitoring + charts
│   │       └── subscription_screen.dart        # 📋 Plans + FAQ
│   ├── pubspec.yaml                            # 📦 Dependencies
│   ├── android/                                # 🤖 Android config
│   ├── ios/                                    # 🍎 iOS config
│   ├── web/                                    # 🌐 Web config
│   └── windows/                                # 🪟 Windows config
└── README.md                                   # 📄 This file
```

---

## 🚀 Getting Started

### Prerequisites

| Requirement        | Version |
| ------------------ | ------- |
| Flutter SDK        | 3.0+    |
| Dart               | 3.0+    |
| Android Studio / VS Code | Latest |
| Git                | Latest  |

### Quick Start

```bash
# 1️⃣ Clone the repository
git clone https://github.com/ayishathul-rinsha/Binnit.git

# 2️⃣ Navigate to the project
cd Binnit/eco_waste_app

# 3️⃣ Install dependencies
flutter pub get

# 4️⃣ Run the app
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

---

## 📱 App Flow

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│   Login /    │────▶│     Home     │────▶│  Schedule Pickup  │
│   Signup     │     │  Dashboard   │     │  (Date/Time/Map)  │
└─────────────┘     └──────┬───────┘     └────────┬─────────┘
                           │                       │
                    ┌──────┴───────┐         ┌─────▼──────────┐
                    │              │         │ Pickup Details  │
              ┌─────▼─────┐ ┌─────▼─────┐   │ (Weight/Type)   │
              │ Smart Bin  │ │Marketplace│   └────────┬────────┘
              │ Monitor    │ │  Rates    │            │
              └───────────┘ └───────────┘     ┌──────▼────────┐
                                              │   Payment     │
                    ┌───────────┐             │  (UPI/Card)   │
                    │Subscription│             └──────┬────────┘
                    │   Plans   │                     │
                    └───────────┘             ┌───────▼───────┐
                                              │ Live Tracking │
                                              │ (Truck + ETA) │
                                              └───────────────┘
```

---

## 🏗️ Key Components

### Custom Painters (No External Map Libraries!)
The app features **fully custom-rendered maps** using Flutter's `CustomPainter`:

- **`_MapGridPainter`** — Renders the grid-based map background
- **`_MapStreetPainter`** — Draws street overlays
- **`_TrackingMapPainter`** — Map with buildings and road network
- **`_RoutePainter`** — Animated route path with progress indicator
- **`_BinFillPainter`** — Circular gauge showing bin fill levels
- **`_WeeklyChartPainter`** — Bar chart for weekly waste statistics

### Animation System
- **Truck animation** — `AnimationController` with bezier curve path
- **Pulse effect** — Repeating scale animation on destination marker
- **ETA countdown** — Periodic timer updating arrival estimate
- **Fade transitions** — Page-level entrance animations

---

## 👥 Team

| Role        | Name                      |
| ----------- | ------------------------- |
| Developer   | **DEVIKA S KUMAR**     |

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/your-feature
   ```
3. **Commit** your changes
   ```bash
   git commit -m "feat: Add your feature description"
   ```
4. **Push** to your branch
   ```bash
   git push origin feature/your-feature
   ```
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Made with 💚 by Team Binnit</strong>
  <br/>
  <em>Every pickup counts. Every bin matters. 🌱</em>
</p>

<p align="center">
  <a href="https://github.com/ayishathul-rinsha/Binnit">
    <img src="https://img.shields.io/badge/⭐_Star_this_repo-4A6741?style=for-the-badge" alt="Star"/>
  </a>
</p>
