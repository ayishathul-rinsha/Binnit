from fpdf import FPDF

class BinnitPDF(FPDF):
    def header(self):
        self.set_font('Helvetica', 'B', 10)
        self.set_text_color(74, 103, 65)  # Green
        self.cell(0, 8, 'Binnit - Smart Waste Management App', align='R')
        self.ln(4)
        self.set_draw_color(74, 103, 65)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(6)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.set_text_color(128, 128, 128)
        self.cell(0, 10, f'Page {self.page_no()}/{{nb}}', align='C')

    def section_title(self, title):
        self.set_font('Helvetica', 'B', 16)
        self.set_text_color(74, 103, 65)
        self.cell(0, 10, title, new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(74, 103, 65)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(4)

    def sub_title(self, title):
        self.set_font('Helvetica', 'B', 13)
        self.set_text_color(45, 45, 45)
        self.cell(0, 9, title, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def body_text(self, text):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(60, 60, 60)
        self.multi_cell(0, 5.5, text)
        self.ln(2)

    def bullet(self, text, indent=10):
        self.set_font('Helvetica', '', 10)
        self.set_text_color(60, 60, 60)
        x = self.get_x()
        self.cell(indent, 5.5, '')
        self.set_font('Helvetica', '', 10)
        self.cell(4, 5.5, chr(8226) + ' ')
        self.multi_cell(0, 5.5, text)

    def bold_bullet(self, bold_part, normal_part, indent=10):
        self.set_text_color(60, 60, 60)
        self.cell(indent, 5.5, '')
        self.set_font('Helvetica', '', 10)
        self.cell(4, 5.5, chr(8226) + ' ')
        self.set_font('Helvetica', 'B', 10)
        self.write(5.5, bold_part)
        self.set_font('Helvetica', '', 10)
        self.write(5.5, normal_part)
        self.ln(6)

    def divider(self):
        self.ln(3)
        self.set_draw_color(200, 200, 200)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(5)

pdf = BinnitPDF()
pdf.alias_nb_pages()
pdf.set_auto_page_break(auto=True, margin=20)

# ── COVER PAGE ──
pdf.add_page()
pdf.ln(40)
pdf.set_font('Helvetica', 'B', 36)
pdf.set_text_color(74, 103, 65)
pdf.cell(0, 15, 'BINNIT', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.set_font('Helvetica', '', 16)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 10, 'Smart Waste Management App', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.ln(8)
pdf.set_draw_color(74, 103, 65)
pdf.line(60, pdf.get_y(), 150, pdf.get_y())
pdf.ln(12)
pdf.set_font('Helvetica', 'B', 14)
pdf.set_text_color(60, 60, 60)
pdf.cell(0, 8, 'Progress Report', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.ln(30)
pdf.set_font('Helvetica', '', 12)
pdf.set_text_color(80, 80, 80)
pdf.cell(0, 7, 'Prepared by: Devika S Kumar', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.cell(0, 7, 'Date: 14 February 2026', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.cell(0, 7, 'GitHub: github.com/ayishathul-rinsha/Binnit', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.ln(20)
pdf.set_font('Helvetica', 'I', 10)
pdf.set_text_color(74, 103, 65)
pdf.cell(0, 7, 'Schedule. Track. Recycle. Repeat.', align='C', new_x="LMARGIN", new_y="NEXT")

# ── TABLE OF CONTENTS ──
pdf.add_page()
pdf.section_title('Table of Contents')
pdf.ln(4)
toc = [
    '1. Project Overview',
    '2. Screens Completed (11 Screens)',
    '   2.1  Login Screen',
    '   2.2  Sign Up Screen',
    '   2.3  Phone Verification Screen',
    '   2.4  Home Screen (Dashboard)',
    '   2.5  Schedule Pickup Screen',
    '   2.6  Pickup Details Screen',
    '   2.7  Payment Screen',
    '   2.8  Live Tracking Screen',
    '   2.9  Marketplace Screen',
    '   2.10 Smart Bin Screen',
    '   2.11 Subscription Screen',
    '3. Technical Details',
    '4. App Flow',
    '5. Completion Status',
    '6. Next Steps',
    '7. Repository Info',
]
for item in toc:
    pdf.set_font('Helvetica', '', 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, item, new_x="LMARGIN", new_y="NEXT")

# ── 1. PROJECT OVERVIEW ──
pdf.add_page()
pdf.section_title('1. Project Overview')
pdf.body_text(
    'Binnit is a smart waste management mobile application built using Flutter. '
    'It enables users to schedule waste pickups, track collection drivers in real-time, '
    'sell recyclable waste at market rates, monitor smart bin fill levels, and manage '
    'subscription plans - all from a single app.'
)
pdf.body_text(
    'The goal is to make waste collection and recycling convenient, efficient, and '
    'rewarding for households while contributing to a cleaner environment.'
)
pdf.ln(4)
pdf.sub_title('Key Information')
pdf.bold_bullet('Target Platform: ', 'Android, iOS, Web')
pdf.bold_bullet('Framework: ', 'Flutter (Dart)')
pdf.bold_bullet('Design System: ', 'Material 3 with custom green theme')
pdf.bold_bullet('Total Screens: ', '11')
pdf.bold_bullet('Lines of Code: ', '~8,500+')

# ── 2. SCREENS ──
pdf.add_page()
pdf.section_title('2. Screens Completed')
pdf.body_text('Below is a detailed description of all 11 screens implemented so far.')
pdf.body_text('[Add screenshots from the running app next to each section]')

# 2.1 Login
pdf.divider()
pdf.sub_title('2.1 Login Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/login_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text(
    'The login screen provides two authentication modes that users can toggle between:'
)
pdf.bold_bullet('Email/Password Login - ', 'Email input, password with show/hide toggle, "Forgot Password?" link')
pdf.bold_bullet('Phone Number OTP Login - ', 'Country code selector (+91), phone number input, "Send OTP" button')
pdf.bullet('Google Sign-In button with icon')
pdf.bullet('Toggle switch to seamlessly switch between Email and Phone modes')
pdf.bullet('Smooth animated transitions between login modes')
pdf.bullet('"Don\'t have an account? Sign Up" redirect link')

# 2.2 Signup
pdf.divider()
pdf.sub_title('2.2 Sign Up Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/signup_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('New user registration screen with the following fields:')
pdf.bullet('Full Name input')
pdf.bullet('Email Address input with validation')
pdf.bullet('Phone Number input')
pdf.bullet('Password input with visibility toggle')
pdf.bullet('Confirm Password input')
pdf.bullet('Green gradient "Sign Up" button')
pdf.bullet('Google Sign-In option')
pdf.bullet('"Already have an account? Login" redirect')

# 2.3 OTP
pdf.divider()
pdf.sub_title('2.3 Phone Verification Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/phone_verification_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('OTP verification screen that appears after phone-based login or signup:')
pdf.bullet('Displays the phone number OTP was sent to')
pdf.bullet('6-digit OTP input boxes with auto-focus to next box')
pdf.bullet('"Verify" button with green gradient')
pdf.bullet('30-second countdown timer for resend')
pdf.bullet('"Resend OTP" link after timer expires')
pdf.bullet('Auto-submit when all 6 digits are entered')

# 2.4 Home
pdf.add_page()
pdf.sub_title('2.4 Home Screen (Dashboard)')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/home_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text(
    'The main dashboard screen with bottom navigation bar. This is the central hub of the app.'
)
pdf.set_font('Helvetica', 'B', 10)
pdf.set_text_color(60, 60, 60)
pdf.cell(0, 7, 'Sections:', new_x="LMARGIN", new_y="NEXT")
pdf.bold_bullet('Top Bar - ', 'User avatar, "Hello, [Name]!" greeting, notification bell')
pdf.bold_bullet('Welcome Banner - ', 'Gradient green card with eco-impact summary')
pdf.bold_bullet('Quick Actions Grid - ', '4 cards: Schedule Pickup, Smart Bin, Marketplace, Subscription Plans')
pdf.bold_bullet('Smart Bin Overview - ', 'Shows fill levels of different bins with progress bars')
pdf.bold_bullet('Upcoming Pickup - ', 'Card showing next scheduled pickup with date, time, address, waste type')
pdf.bold_bullet('Eco Impact Stats - ', 'CO2 saved, trees equivalent, total waste recycled')
pdf.bold_bullet('Subscription Banner - ', 'Promotional card for upgrading plans')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.cell(0, 7, 'Bottom Navigation (4 tabs):', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Home (default active tab)')
pdf.bullet('Smart Bin')
pdf.bullet('Marketplace')
pdf.bullet('Subscription')

# 2.5 Schedule Pickup
pdf.divider()
pdf.sub_title('2.5 Schedule Pickup Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/schedule_pickup_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('Allows users to schedule a waste pickup at their preferred date and time.')
pdf.bold_bullet('Interactive Map Preview - ', 'Custom-painted map with red location pin, zoom controls')
pdf.bold_bullet('Address Selection - ', '3 saved addresses: Home, Office, Other (Add new)')
pdf.bold_bullet('Custom Date Picker - ', 'Opens native date picker (today to 60 days ahead)')
pdf.bold_bullet('Custom Time Picker - ', 'Opens native time picker for exact time selection')
pdf.bold_bullet('Pickup Summary Card - ', 'Dark green gradient showing selected date, time, and address')
pdf.bullet('"Continue to Details" button navigates to Pickup Details screen')

# 2.6 Pickup Details
pdf.add_page()
pdf.sub_title('2.6 Pickup Details Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/pickup_details_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('After scheduling, users provide details about the waste to be collected.')
pdf.bold_bullet('Weight Input - ', 'Slider to select estimated weight (1-50 Kg)')
pdf.bold_bullet('Waste Type Selection - ', 'Multi-select grid: Paper, Plastic, Metal, Glass, E-Waste, Organic')
pdf.bold_bullet('Additional Options - ', 'Toggles: Fragile items, Need bags, Heavy items')
pdf.bold_bullet('Notes Section - ', 'Text area for special instructions')
pdf.bold_bullet('Price Breakdown - ', 'Dynamic calculation: base price + weight charge + type pricing = total')
pdf.bullet('Bottom bar shows total amount with "Pay Now" button')

# 2.7 Payment
pdf.divider()
pdf.sub_title('2.7 Payment Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/payment_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('Checkout screen with multiple payment options.')
pdf.set_font('Helvetica', 'B', 10)
pdf.set_text_color(60, 60, 60)
pdf.cell(0, 7, '5 Payment Methods:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('UPI (Google Pay, PhonePe, Paytm)')
pdf.bullet('Credit/Debit Card')
pdf.bullet('Net Banking')
pdf.bullet('EcoWallet (in-app wallet with balance display)')
pdf.bullet('Cash on Pickup')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.cell(0, 7, 'After Successful Payment:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Animated success screen with green checkmark')
pdf.bullet('Transaction details: Amount, Transaction ID, Payment Method, Eco Points')
pdf.bullet('"Track Pickup" button - navigates to Live Tracking screen')
pdf.bullet('"Back to Home" secondary link')

# 2.8 Live Tracking
pdf.add_page()
pdf.sub_title('2.8 Live Tracking Screen (Highlight Feature)')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/pickup_tracking_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text(
    'Swiggy/Uber-style real-time driver tracking screen. '
    'This is one of the highlight features of the app.'
)
pdf.set_font('Helvetica', 'B', 10)
pdf.set_text_color(60, 60, 60)
pdf.cell(0, 7, 'Animated Map:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Custom-painted map with grid, buildings, and street overlay')
pdf.bullet('Curved route path from driver to destination')
pdf.bullet('Animated truck icon moving along bezier curve toward user\'s home')
pdf.bullet('Pulsing red home marker at destination (icon stays fixed, ring pulses)')
pdf.bullet('"Driver" and "Your Location" labels on map')
pdf.bullet('Zoom controls (+ / - / My Location)')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.cell(0, 7, 'ETA & Timeline:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Dark green ETA banner: "Arriving in X min" with countdown')
pdf.bullet('Tracking Timeline with 5 steps:')
pdf.bold_bullet('  1. ', 'Pickup Confirmed - 3:30 PM (completed)')
pdf.bold_bullet('  2. ', 'Driver Assigned - 3:32 PM (completed)')
pdf.bold_bullet('  3. ', 'On the Way - 3:45 PM (in progress)')
pdf.bold_bullet('  4. ', 'Arriving Soon - ETA 10 min (pending)')
pdf.bold_bullet('  5. ', 'Pickup Complete (pending)')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.cell(0, 7, 'Driver Details:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Driver avatar with initials, name: "Rahul Sharma"')
pdf.bullet('Rating: 4.8 stars (342 trips)')
pdf.bullet('Call and Chat action buttons')
pdf.bullet('Vehicle info: "Tata Ace - Green", License: KA-01-AB-1234, Verified badge')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.cell(0, 7, 'Pickup Info Panel:', new_x="LMARGIN", new_y="NEXT")
pdf.bullet('Date, Time, Address, Waste Type, Weight')

# 2.9 Marketplace
pdf.divider()
pdf.sub_title('2.9 Marketplace Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/marketplace_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('Shows current market rates for recyclable waste materials.')
pdf.bold_bullet('Earnings Banner - ', 'Gradient card showing total earnings and % change')
pdf.bold_bullet('Category Filter - ', 'Scrollable chips: All, Paper, Plastic, Metal, Glass, E-Waste')
pdf.bold_bullet('Material Rate Cards - ', 'Material name, rate per Kg, price trend (up/down), "Sell" button')

# 2.10 Smart Bin
pdf.add_page()
pdf.sub_title('2.10 Smart Bin Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/smart_bin_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('IoT smart bin monitoring dashboard.')
pdf.bold_bullet('Overview Card - ', 'Total bins count, average fill level, pickups this week')
pdf.bold_bullet('Auto-Schedule Info - ', 'Banner: pickup auto-scheduled when bin reaches 80%')
pdf.bold_bullet('Bin Cards - ', '4 bins: General (grey), Recyclable (green), Organic (brown), Hazardous (red)')
pdf.bullet('Each card: circular fill gauge (CustomPainter), fill %, status, last emptied date')
pdf.bullet('Action buttons: Notify, Schedule, Details')
pdf.bold_bullet('Weekly Stats - ', 'Custom bar chart showing daily waste generation (Mon-Sun)')

# 2.11 Subscription
pdf.divider()
pdf.sub_title('2.11 Subscription Screen')
pdf.set_font('Helvetica', 'I', 9)
pdf.set_text_color(120, 120, 120)
pdf.cell(0, 5, 'File: lib/screens/subscription_screen.dart', new_x="LMARGIN", new_y="NEXT")
pdf.ln(3)
pdf.body_text('Subscription plan management screen with 3 tiers.')
pdf.bold_bullet('Free Plan - ', 'Basic features, 0/month')
pdf.bold_bullet('Pro Plan - ', 'Rs.99/month - Priority pickups, marketplace, smart bin')
pdf.bold_bullet('Business Plan - ', 'Rs.299/month - Unlimited pickups, dedicated driver, analytics')
pdf.ln(2)
pdf.bullet('Header banner with crown icon and "Go Premium" CTA')
pdf.bullet('Current plan overview with usage stats')
pdf.bullet('Feature comparison with checkmarks')
pdf.bullet('"Most Popular" badge on Pro plan')
pdf.bullet('Benefits section: Priority pickups, Better rates, Smart reports, 24/7 support')
pdf.bullet('FAQ accordion section')
pdf.bullet('Gradient "Subscribe" button')

# ── 3. TECHNICAL DETAILS ──
pdf.add_page()
pdf.section_title('3. Technical Details')

pdf.sub_title('3.1 Tech Stack')
pdf.ln(2)
# Table
pdf.set_font('Helvetica', 'B', 10)
pdf.set_fill_color(74, 103, 65)
pdf.set_text_color(255, 255, 255)
pdf.cell(60, 8, ' Technology', fill=True)
pdf.cell(0, 8, ' Purpose', fill=True, new_x="LMARGIN", new_y="NEXT")
pdf.set_text_color(60, 60, 60)
pdf.set_font('Helvetica', '', 10)
rows = [
    ('Flutter', 'Cross-platform mobile UI framework'),
    ('Dart', 'Programming language'),
    ('Material 3', 'Google\'s latest design system'),
    ('CustomPainter', 'Maps, charts, gauges (no external plugins)'),
    ('AnimationController', 'Truck movement, pulse effects, transitions'),
]
fill = False
for tech, purpose in rows:
    if fill:
        pdf.set_fill_color(245, 245, 240)
    else:
        pdf.set_fill_color(255, 255, 255)
    pdf.cell(60, 7, ' ' + tech, fill=True)
    pdf.cell(0, 7, ' ' + purpose, fill=True, new_x="LMARGIN", new_y="NEXT")
    fill = not fill

pdf.ln(6)
pdf.sub_title('3.2 Custom Components (Built from Scratch)')
pdf.bullet('Map rendering - Grid, streets, buildings (no Google Maps API needed)')
pdf.bullet('Route animation - Bezier curve path with truck icon')
pdf.bullet('Bin fill gauges - Circular progress with color coding')
pdf.bullet('Weekly bar chart - Custom painted bars with gradient fills')
pdf.bullet('Pulse animation - Expanding ring on destination marker')

pdf.ln(4)
pdf.sub_title('3.3 Color Theme')
pdf.ln(2)
pdf.set_font('Helvetica', 'B', 10)
pdf.set_fill_color(74, 103, 65)
pdf.set_text_color(255, 255, 255)
pdf.cell(50, 8, ' Color', fill=True)
pdf.cell(35, 8, ' Hex Code', fill=True)
pdf.cell(0, 8, ' Usage', fill=True, new_x="LMARGIN", new_y="NEXT")
pdf.set_text_color(60, 60, 60)
pdf.set_font('Helvetica', '', 10)
colors = [
    ('Primary Green', '#4A6741', 'Buttons, accents, primary actions'),
    ('Dark Green', '#3D5635', 'Gradients, headers'),
    ('Light Green', '#6B8E5F', 'Highlights, active states'),
    ('Accent Green', '#8CB369', 'Secondary accents'),
    ('Background', '#F5F5F0', 'Page backgrounds'),
    ('Text Primary', '#2D2D2D', 'Headings, body text'),
    ('Text Secondary', '#6B6B6B', 'Subtitles, captions'),
]
fill = False
for name, hex_code, usage in colors:
    if fill:
        pdf.set_fill_color(245, 245, 240)
    else:
        pdf.set_fill_color(255, 255, 255)
    pdf.cell(50, 7, ' ' + name, fill=True)
    pdf.cell(35, 7, ' ' + hex_code, fill=True)
    pdf.cell(0, 7, ' ' + usage, fill=True, new_x="LMARGIN", new_y="NEXT")
    fill = not fill

# ── 4. APP FLOW ──
pdf.ln(8)
pdf.section_title('4. App Flow')
pdf.ln(2)
pdf.set_font('Courier', '', 9)
pdf.set_text_color(60, 60, 60)
flow_lines = [
    'Login/Signup',
    '     |',
    '     v',
    'Home Dashboard ----+---- Smart Bin Monitoring',
    '     |             |',
    '     v             +---- Marketplace (Sell Waste)',
    'Schedule Pickup    |',
    '     |             +---- Subscription Plans',
    '     v',
    'Pickup Details',
    '     |',
    '     v',
    'Payment',
    '     |',
    '     v',
    'Live Tracking (Truck + ETA + Driver)',
]
for line in flow_lines:
    pdf.cell(0, 5, '  ' + line, new_x="LMARGIN", new_y="NEXT")

# ── 5. COMPLETION STATUS ──
pdf.add_page()
pdf.section_title('5. Completion Status')
pdf.ln(2)

completed = [
    'Authentication - Login (Email + Phone OTP), Signup, OTP Verification',
    'Home Dashboard - Full dashboard with 4-tab bottom navigation',
    'Schedule Pickup - Custom date & time picker, address selection, map preview',
    'Pickup Details - Weight, waste type, notes, real-time price breakdown',
    'Payment - 5 payment methods, promo code, animated success screen',
    'Live Tracking - Animated truck on map, driver details, ETA countdown, timeline',
    'Marketplace - Material rates, earnings tracker, category filter',
    'Smart Bin - Bin monitoring with gauges, weekly chart, auto-schedule',
    'Subscription - 3-tier plans, benefits, FAQ',
    'Theme System - Complete design system (colors, text styles, buttons, cards)',
    'README - Professional documentation on GitHub',
    'Git - Code pushed to GitHub repository',
]
for item in completed:
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(74, 103, 65)
    pdf.cell(6, 6, chr(10003))  # checkmark
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 6, ' ' + item, new_x="LMARGIN", new_y="NEXT")

# ── 6. NEXT STEPS ──
pdf.ln(6)
pdf.section_title('6. Next Steps / Upcoming Work')
pdf.ln(2)
next_steps = [
    'Backend Integration - Firebase/Supabase for auth, database, and real-time tracking',
    'Google Maps API - Replace custom painted maps with actual Google Maps',
    'Push Notifications - Pickup reminders, driver arrival alerts',
    'Real-time Tracking - WebSocket/Firebase for live driver location updates',
    'User Profile - Profile management, pickup history, payment history',
    'Admin Panel - Dashboard for waste collection companies',
    'Rewards System - Points, badges, and leaderboard for eco-contributions',
    'Multi-language Support - Hindi, Tamil, Malayalam',
]
for item in next_steps:
    pdf.set_font('Helvetica', '', 10)
    pdf.set_text_color(200, 200, 200)
    pdf.cell(6, 6, chr(9633))  # empty square
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 6, ' ' + item, new_x="LMARGIN", new_y="NEXT")

# ── 7. REPOSITORY ──
pdf.ln(8)
pdf.section_title('7. Repository Info')
pdf.ln(2)
pdf.bold_bullet('GitHub: ', 'https://github.com/ayishathul-rinsha/Binnit')
pdf.bold_bullet('Branch: ', 'main')
pdf.bold_bullet('Total Screens: ', '11')
pdf.bold_bullet('Total Lines of Code: ', '~8,500+')
pdf.bold_bullet('Framework: ', 'Flutter 3.0+ / Dart 3.0+')

# ── FINAL PAGE ──
pdf.add_page()
pdf.ln(50)
pdf.set_font('Helvetica', 'B', 24)
pdf.set_text_color(74, 103, 65)
pdf.cell(0, 12, 'Thank You!', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.ln(6)
pdf.set_font('Helvetica', '', 12)
pdf.set_text_color(100, 100, 100)
pdf.cell(0, 8, 'Every pickup counts. Every bin matters.', align='C', new_x="LMARGIN", new_y="NEXT")
pdf.ln(4)
pdf.set_font('Helvetica', 'I', 10)
pdf.set_text_color(74, 103, 65)
pdf.cell(0, 8, 'Made with love for a greener planet', align='C', new_x="LMARGIN", new_y="NEXT")

# Save
output_path = r"c:\Users\devik\OneDrive\Documents\Desktop\mini project\Binnit_Progress_Report.pdf"
pdf.output(output_path)
print(f"PDF saved to: {output_path}")
