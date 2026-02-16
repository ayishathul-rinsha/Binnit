BINNIT — Smart Waste Management App
Progress Report
Date: 14 February 2026
Prepared by: Ayishathul Rinsha
GitHub: https://github.com/ayishathul-rinsha/Binnit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. PROJECT OVERVIEW

Binnit is a smart waste management mobile application built using Flutter. It enables users to schedule waste pickups, track collection drivers in real-time, sell recyclable waste at market rates, monitor smart bin fill levels, and manage subscription plans — all from a single app.

The goal is to make waste collection and recycling convenient, efficient, and rewarding for households while contributing to a cleaner environment.

Target Platform: Android, iOS, Web
Framework: Flutter (Dart)
Design System: Material 3 with custom green theme


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2. SCREENS COMPLETED (11 Screens)

Below is a detailed description of every screen implemented so far.
[NOTE: Add your screenshots next to each section in Google Docs]

━━━━━━━━━━━━━━━━━━━━━━━━

2.1 LOGIN SCREEN
File: login_screen.dart

Description:
The login screen provides two authentication modes that users can toggle between:

• Email/Password Login
  - Email input field with validation
  - Password input with show/hide toggle
  - "Forgot Password?" link
  - "Sign Up" redirect for new users

• Phone Number OTP Login
  - Country code selector (+91 India)
  - Phone number input field
  - "Send OTP" button
  - Navigates to OTP verification screen

Design Details:
  - Clean, minimal layout with green (#4A6741) accent colors
  - Toggle switch at the top to switch between Email and Phone login
  - Google Sign-In button with icon
  - Smooth animated transitions between modes

━━━━━━━━━━━━━━━━━━━━━━━━

2.2 SIGN UP SCREEN
File: signup_screen.dart

Description:
New user registration screen with the following fields:

• Full Name input
• Email Address input
• Phone Number input
• Password input (with visibility toggle)
• Confirm Password input
• "Sign Up" button (green gradient)
• Google Sign-In option
• "Already have an account? Login" link

Design Details:
  - Back arrow navigation
  - Rounded input fields (16px radius) with subtle borders
  - Light beige background (#F5F5F0)
  - Form validation for all fields

━━━━━━━━━━━━━━━━━━━━━━━━

2.3 PHONE VERIFICATION SCREEN
File: phone_verification_screen.dart

Description:
OTP verification screen that appears after phone-based login/signup:

• Displays the phone number OTP was sent to
• 6-digit OTP input boxes (auto-focus to next box)
• "Verify" button
• Countdown timer for resend (30 seconds)
• "Resend OTP" link after timer expires

Design Details:
  - Individual digit boxes with focus animation
  - Green accent on active box
  - Auto-submit when all 6 digits are entered

━━━━━━━━━━━━━━━━━━━━━━━━

2.4 HOME SCREEN (DASHBOARD)
File: home_screen.dart

Description:
The main dashboard screen with bottom navigation. This is the central hub of the app.

Sections included:
• Top Bar — User avatar, "Hello, [Name]!" greeting, notification bell icon
• Welcome Banner — Gradient green card with eco-impact summary
• Quick Actions Grid — 4 cards:
    1. Schedule Pickup (calendar icon)
    2. Smart Bin (trash icon)
    3. Marketplace (store icon)
    4. Subscription Plans (card icon)
• Smart Bin Overview — Shows fill levels of different bins with progress bars
• Upcoming Pickup — Card showing next scheduled pickup with date, time, address, and waste type
• Eco Impact Stats — CO₂ saved, trees equivalent, total waste recycled
• Subscription Banner — Promotional card for upgrading plans

Bottom Navigation Bar:
  - Home (active)
  - Smart Bin
  - Marketplace
  - Subscription

Design Details:
  - Smooth fade-in animation on page load
  - Cards with rounded corners (20px) and subtle shadows
  - Green gradient on premium sections
  - Custom animated bin fill-level indicators

━━━━━━━━━━━━━━━━━━━━━━━━

2.5 SCHEDULE PICKUP SCREEN
File: schedule_pickup_screen.dart

Description:
Allows users to schedule a waste pickup at their preferred date and time.

Features:
• Interactive Map Preview — Custom-painted map showing pickup location with a red pin, zoom controls, and "Tap to expand" label
• Address Selection — Three saved addresses:
    1. Home (green icon) — "123, 5th Cross, Koramangala, Bengaluru"
    2. Office (blue icon) — "456, MG Road, Bengaluru"
    3. Other (orange icon) — "Add new address"
• Custom Date Picker — Opens Flutter's date picker for selecting any date (today to 60 days ahead). Shows formatted date like "Tomorrow, 15 Feb 2026"
• Custom Time Picker — Opens Flutter's time picker for selecting exact time. Shows formatted time like "9:00 AM"
• Pickup Summary Card — Dark green gradient card showing selected date, time, and address
• "Continue to Details" button

Design Details:
  - Date and time cards with colored icons and chevron arrows
  - Map built entirely with CustomPainter (no Google Maps dependency)
  - Animated container highlighting on selection
  - Summary card with gradient and icon labels

━━━━━━━━━━━━━━━━━━━━━━━━

2.6 PICKUP DETAILS SCREEN
File: pickup_details_screen.dart

Description:
After scheduling, users provide details about the waste to be collected.

Features:
• Pickup Summary Card — Shows the scheduled date, time, and address
• Weight Input — Slider to select estimated weight (1-50 Kg)
• Waste Type Selection — Multi-select grid:
    - Paper 📄
    - Plastic ♻️
    - Metal 🔩
    - Glass 🫙
    - E-Waste 💻
    - Organic 🌿
• Additional Options — Toggles for:
    - Fragile items
    - Need bags
    - Heavy items (need help)
• Notes Section — Text area for special instructions
• Price Breakdown — Dynamic calculation showing:
    - Base price
    - Weight charge
    - Type-based pricing
    - Total estimated amount

• Bottom Button — Shows total amount (₹XX) + "Pay Now" button

Design Details:
  - Interactive slider with green accent
  - Waste type chips with emoji icons
  - Animated price update as selections change
  - Gradient summary card at top

━━━━━━━━━━━━━━━━━━━━━━━━

2.7 PAYMENT SCREEN
File: payment_screen.dart

Description:
Checkout screen with multiple payment options.

Features:
• Amount Card — Large gradient card showing total amount (₹XX), weight, and waste type count
• Order Summary — Table with pickup date, time slot, address, weight, and waste types
• Payment Methods — 5 options:
    1. UPI (Google Pay, PhonePe, Paytm) — green icon
    2. Credit/Debit Card (•••• 4532) — blue icon
    3. Net Banking (all major banks) — purple icon
    4. EcoWallet (Balance: ₹2,450) — orange icon
    5. Cash on Pickup — grey icon
• Promo Code Section — "Have a promo code?" with Apply button
• Pay Button — "Pay ₹XX" with lock icon

After Payment Success:
• Success Screen — Green checkmark animation
• Transaction details (Amount, Transaction ID, Payment Method, Eco Points Earned)
• "Track Pickup" button — Navigates to live tracking
• "Back to Home" link

Design Details:
  - Radio-style selection with colored borders
  - Animated processing spinner during payment
  - Smooth transition to success screen

━━━━━━━━━━━━━━━━━━━━━━━━

2.8 LIVE TRACKING SCREEN (NEW ✨)
File: pickup_tracking_screen.dart

Description:
Swiggy/Uber-style real-time driver tracking screen. This is one of the highlight features.

Features:
• Animated Map — Custom-painted map with:
    - Grid background with building blocks
    - Street overlay (horizontal + vertical roads)
    - Curved route path from driver to destination
    - Route progress line (completed portion highlighted)
    - Dotted waypoints along the route

• Animated Truck Icon — Green circular icon with truck that:
    - Moves along a bezier curve path
    - Has a glowing shadow effect
    - Travels from driver's location toward user's home

• Pulsing Home Marker — Red circle with home icon at the destination:
    - Pulse ring animates outward (grows and fades)
    - Home icon stays fixed in position

• ETA Banner — Dark green gradient card showing:
    - "Arriving in" label
    - Large countdown number (e.g., "10 min")
    - Countdown decreases over time
    - "Share" button to share tracking link

• Tracking Timeline — Step-by-step progress:
    ✅ Pickup Confirmed — 3:30 PM (completed)
    ✅ Driver Assigned — 3:32 PM (completed)
    🟡 On the Way — 3:45 PM (in progress)
    ⬜ Arriving Soon — ETA 10 min (pending)
    ⬜ Pickup Complete — (pending)

• Driver Details Card:
    - Driver avatar with initials "RS"
    - Name: "Rahul Sharma"
    - Rating: 4.8 ⭐ (342 trips)
    - Call button (green) 📞
    - Chat button (blue) 💬

• Vehicle Information:
    - Vehicle: "Tata Ace — Green"
    - License plate: "KA-01-AB-1234"
    - "Verified ✓" badge

• Pickup Info Panel:
    - Date, Time, Address, Waste Type, Weight

Design Details:
  - All map rendering done with CustomPainter (no Google Maps)
  - AnimationController drives truck movement along bezier curve
  - Pulse animation uses repeating scale transformation
  - ETA countdown uses periodic timer
  - "LIVE" badge in app bar with green dot

━━━━━━━━━━━━━━━━━━━━━━━━

2.9 MARKETPLACE SCREEN
File: marketplace_screen.dart

Description:
Shows current market rates for recyclable waste materials.

Features:
• Earnings Banner — Gradient card showing total earnings and percentage change
• Category Filter — Scrollable row of category chips with icons:
    - All, Paper, Plastic, Metal, Glass, E-Waste
• Material Rate Cards — List of waste materials with:
    - Material name and icon
    - Current rate per Kg (₹/Kg)
    - Price trend indicator (up/down arrow)
    - "Sell" action button

Design Details:
  - Colorful category icons
  - Rate chips with scrollable layout
  - Green/red indicators for price trend

━━━━━━━━━━━━━━━━━━━━━━━━

2.10 SMART BIN SCREEN
File: smart_bin_screen.dart

Description:
IoT smart bin monitoring dashboard.

Features:
• Overview Card — Total bins, average fill level, pickups this week
• Auto-Schedule Info — Banner explaining automatic pickup scheduling when bin reaches threshold
• Bin List — Cards for each bin:
    - General Waste (grey)
    - Recyclable (green)
    - Organic (brown)
    - Hazardous (red)
  Each card shows:
    - Custom circular fill gauge (painted with CustomPainter)
    - Fill percentage and status text
    - Last emptied date
    - Action buttons (Notify, Schedule, Details)
• Weekly Stats — Bar chart showing daily waste generation (Mon–Sun) painted with CustomPainter

Design Details:
  - Animated circular gauges for fill levels
  - Color-coded bins (green = good, yellow = moderate, red = full)
  - Custom bar chart with gradient fills

━━━━━━━━━━━━━━━━━━━━━━━━

2.11 SUBSCRIPTION SCREEN
File: subscription_screen.dart

Description:
Subscription plan management screen.

Features:
• Header Banner — Gradient card with crown icon and "Go Premium" messaging
• Current Plan — Shows active plan with usage stats
• Plan Cards — 3 tiers:
    1. Free — Basic features (₹0/month)
    2. Pro — ₹99/month — Priority pickups, marketplace access, smart bin
    3. Business — ₹299/month — Unlimited pickups, dedicated driver, analytics
  Each card shows: price, feature list, "Subscribe" button
• Benefits Section — 4 benefit cards with icons:
    - Priority pickups
    - Better rates
    - Smart reports
    - 24/7 support
• FAQ Section — Expandable questions and answers
• Subscribe Button — Bottom action button

Design Details:
  - Popular plan highlighted with "Most Popular" badge
  - Feature comparison with checkmarks
  - Gradient subscribe button


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

3. TECHNICAL DETAILS

3.1 Tech Stack
┌──────────────────┬────────────────────────────────────┐
│ Technology       │ Purpose                            │
├──────────────────┼────────────────────────────────────┤
│ Flutter          │ Cross-platform UI framework         │
│ Dart             │ Programming language                │
│ Material 3       │ Design system                      │
│ CustomPainter    │ Maps, charts, gauges (no plugins!) │
│ AnimationController │ Truck movement, transitions     │
└──────────────────┴────────────────────────────────────┘

3.2 Custom Components Built From Scratch
• Map rendering — Grid, streets, buildings (no Google Maps API needed)
• Route animation — Bezier curve path with truck icon
• Bin fill gauges — Circular progress with wave effect
• Weekly bar chart — Custom painted bars with labels
• Pulse animation — Expanding ring on destination marker

3.3 Color Theme
• Primary Green: #4A6741
• Dark Green: #3D5635
• Background: #F5F5F0
• Text Primary: #2D2D2D
• Accent Green: #8CB369

3.4 Project Structure
Binnit/
├── eco_waste_app/
│   ├── lib/
│   │   ├── main.dart (App entry point)
│   │   ├── theme/
│   │   │   └── app_theme.dart (Colors, text styles, decorations)
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       ├── phone_verification_screen.dart
│   │       ├── home_screen.dart
│   │       ├── schedule_pickup_screen.dart
│   │       ├── pickup_details_screen.dart
│   │       ├── pickup_tracking_screen.dart
│   │       ├── payment_screen.dart
│   │       ├── marketplace_screen.dart
│   │       ├── smart_bin_screen.dart
│   │       └── subscription_screen.dart
│   └── pubspec.yaml
└── README.md


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4. APP FLOW

Login/Signup → Home Dashboard → Schedule Pickup → Pickup Details → Payment → Live Tracking
                    │
                    ├── Smart Bin Monitoring
                    ├── Marketplace (Sell Waste)
                    └── Subscription Plans


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

5. WHAT'S COMPLETED ✅

✅ Authentication — Login (Email + Phone OTP), Signup, OTP Verification
✅ Home Dashboard — Full dashboard with bottom navigation (4 tabs)
✅ Schedule Pickup — Custom date & time picker, address selection, map preview
✅ Pickup Details — Weight, waste type, notes, price breakdown
✅ Payment — 5 payment methods, promo code, success screen
✅ Live Tracking — Animated truck on map, driver details, ETA countdown, timeline
✅ Marketplace — Material rates, earnings, category filter
✅ Smart Bin — Bin monitoring with gauges, weekly chart, auto-schedule
✅ Subscription — 3 plans, benefits, FAQ
✅ Theme — Complete design system (colors, text styles, buttons, cards)
✅ README — Professional documentation on GitHub
✅ Git — Code pushed to GitHub repository


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

6. NEXT STEPS / UPCOMING WORK

🔲 Backend Integration — Firebase/Supabase for auth, database, and real-time tracking
🔲 Google Maps API — Replace custom painted maps with actual Google Maps
🔲 Push Notifications — Pickup reminders, driver arrival alerts
🔲 Real-time Tracking — WebSocket/Firebase for live driver location
🔲 User Profile — Profile management, pickup history, payment history
🔲 Admin Panel — Dashboard for waste collection companies
🔲 Rewards System — Points, badges, and leaderboard
🔲 Multi-language Support — Hindi, Tamil, Malayalam


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

7. REPOSITORY

GitHub: https://github.com/ayishathul-rinsha/Binnit
Branch: main
Total Screens: 11
Total Lines of Code: ~8,500+


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE FOR TEAMMATES:
Please add screenshots from the running app next to each screen description above.
To run the app locally:
  1. Clone: git clone https://github.com/ayishathul-rinsha/Binnit.git
  2. Navigate: cd Binnit/eco_waste_app
  3. Install: flutter pub get
  4. Run: flutter run
