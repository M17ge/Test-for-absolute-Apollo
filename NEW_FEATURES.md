# New Features - Pending Courses and Payment Requests

## Overview
Added comprehensive training appointment booking system with payment request workflow for farmers and finance managers.

## Features Added (Commit: e1ccd01)

### 1. Pending Courses Screen (After Login)
**Location:** `lib/screens/appointments/pending_courses_screen.dart`

When farmers log in, they're now directed to a "Pending Courses" screen that displays:
- List of all scheduled/confirmed training appointments
- Course type (Organic Farming, Pest Control, etc.)
- Scheduled date and location
- Course fee
- Payment status badge (Pending/Approved/Rejected/Paid)
- Color-coded status indicators

**Empty State:**
- If no pending courses, shows empty state message
- Prominent "Book Training" button
- Encouragement text to book first certification

### 2. Book Appointment Screen
**Location:** `lib/screens/appointments/book_appointment_screen.dart`

Comprehensive booking form with:
- **Certification Selection:** Dropdown with 8 certification types
- **Date Picker:** Choose preferred training date
- **Location Input:** Specify training location
- **Notes Field:** Optional additional requirements
- **Course Fee Input:** Enter training cost
- **Payment Request Toggle:** 
  - When enabled: Sends payment request to Finance Manager
  - When disabled: Payment auto-approved
  - Info banner explains the approval process

### 3. Payment Requests Management (Finance Manager)
**Location:** `lib/screens/appointments/payment_requests_screen.dart`

Finance Manager features:
- Dashboard stat card showing pending payment request count
- "View Payment Requests" button in purple
- Dedicated screen listing all pending payment requests with:
  - Farmer name
  - Certification type
  - Course fee prominently displayed
  - Scheduled date and location
  - Additional notes if provided
  - Two action buttons:
    - **Approve** (Green) - Approves payment and updates status
    - **Reject** (Red) - Rejects payment request
  - Confirmation dialogs for both actions

### 4. Updated Finance Manager Dashboard
**Location:** `lib/screens/finance/finance_home_screen.dart`

Changes:
- Added "Payment Requests" stat card (purple, replaces "Amount Due")
- Added "View Payment Requests" button below "View All Credits"
- Auto-loads pending payment requests on screen init

### 5. Enhanced Data Models

**Appointment Model:** `lib/models/appointment_model.dart`
- Added `PaymentStatus` enum (pending, approved, rejected, paid)
- Added `courseFee` field (double)
- Added `paymentStatus` field
- Added `financeManagerId` field (who approved/rejected)
- Added `paymentApprovedDate` field

**New Services:**
- `AppointmentService`: Firebase CRUD operations for appointments
- Methods: create, get, approve/reject payment, update status

**New Providers:**
- `AppointmentProvider`: State management for appointments
- Manages pending courses, payment requests, and approval workflow

### 6. Navigation Flow Updates

**For Farmers:**
```
Login → Pending Courses Screen → [Home or Book Appointment]
```

**For Other Roles:**
```
Login → Role-specific Dashboard
```

## User Workflow

### Farmer Books Course with Payment Request:
1. Log in → Redirected to Pending Courses
2. Click "Book New Course" FAB
3. Fill in course details
4. Enter course fee ($150 default)
5. Toggle "Request Payment Approval" ON
6. Click "Book Appointment"
7. Success message: "Payment request sent to Finance Manager"
8. Course appears in pending list with "PENDING" orange badge

### Finance Manager Approves Payment:
1. Log in → Finance Dashboard
2. See "Payment Requests: X" card
3. Click "View Payment Requests"
4. Review course details and fee
5. Click "Approve" → Confirmation dialog
6. Approve confirmed
7. Payment status updates to "APPROVED" (green)
8. Farmer sees updated status in their pending courses

## Technical Details

### Files Created (5 new files):
1. `lib/services/appointment_service.dart` - Firebase integration
2. `lib/providers/appointment_provider.dart` - State management
3. `lib/screens/appointments/pending_courses_screen.dart` - Main view
4. `lib/screens/appointments/book_appointment_screen.dart` - Booking form
5. `lib/screens/appointments/payment_requests_screen.dart` - Finance approval

### Files Modified (4 files):
1. `lib/main.dart` - Added AppointmentProvider and route
2. `lib/models/appointment_model.dart` - Added payment fields
3. `lib/screens/auth/login_screen.dart` - Updated navigation logic
4. `lib/screens/finance/finance_home_screen.dart` - Added payment requests

### New Route:
- `/pending-courses` - Shows pending training courses

## Firebase Collections

### appointments Collection Schema:
```javascript
{
  id: string,
  farmerId: string,
  farmerName: string,
  trainerId: string,
  trainerName: string,
  certificationType: enum,
  scheduledDate: timestamp,
  location: string,
  status: enum,
  notes: string?,
  certificateIssued: boolean,
  certificateIssuedDate: timestamp?,
  createdAt: timestamp,
  courseFee: number,              // NEW
  paymentStatus: enum,            // NEW
  financeManagerId: string?,      // NEW
  paymentApprovedDate: timestamp? // NEW
}
```

## Color Coding

**Payment Status Colors:**
- 🟠 **Pending** - Orange (awaiting approval)
- 🟢 **Approved** - Green (payment approved)
- 🔴 **Rejected** - Red (payment denied)
- 🔵 **Paid** - Blue (payment completed)

## Key Features

✅ Seamless integration with existing authentication
✅ Role-based navigation (farmers vs other roles)
✅ Real-time status updates via Provider
✅ Confirmation dialogs for critical actions
✅ Empty states with helpful CTAs
✅ Responsive card-based UI
✅ Pull-to-refresh functionality
✅ Floating action buttons for quick access
✅ Color-coded status indicators
✅ Input validation on booking form

## Benefits

1. **For Farmers:**
   - Clear view of all pending courses immediately after login
   - Easy booking process with payment request option
   - Visual status tracking

2. **For Finance Managers:**
   - Centralized payment request management
   - Quick approve/reject workflow
   - Dashboard integration for visibility

3. **For System:**
   - Proper payment approval workflow
   - Audit trail with manager ID and dates
   - Scalable Firebase architecture
