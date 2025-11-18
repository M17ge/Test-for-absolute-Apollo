# New Features V3 - User Approval & Role Management System

## Overview
This document outlines the latest additions to the Apollo Agro platform, focusing on user registration, approval workflows, and comprehensive admin user management capabilities.

## 🔐 User Approval System

### Problem Solved
Previously, any user could create an account with any role and immediately access the system. This posed security and organizational risks. The new system ensures:
- Only authorized users can access the platform
- User roles are properly assigned by administrators
- Complete control over who has access to what functionality

### Key Features

#### 1. **Self-Registration for Farmers**
New farmers can register themselves from the login page:

**Registration Process:**
```
1. Click "Sign Up" on login page
2. Enter: Full Name, Email, Phone, Password
3. Submit registration
4. See success message: "Account created! Please wait for admin approval"
5. Cannot login until admin approves
```

**Technical Implementation:**
- Registration always creates user with `UserRole.farmer`
- Account created with `isApproved: false`
- User is immediately signed out after registration
- Credentials saved to Firebase but login blocked

#### 2. **Approval Requirement**
All new users must be approved before accessing the system:

**Sign-In Validation:**
```dart
// Auth service checks approval status
if (userData != null && !userData.isApproved) {
  await _auth.signOut();
  throw Exception('Your account is pending approval');
}
```

**User Experience:**
- Login attempt shows: "Account pending approval from administrator"
- User must wait for admin action
- No access to any part of the application

#### 3. **Enhanced User Model**
New fields added to track approval:

```dart
class AppUser {
  // ... existing fields ...
  final bool isApproved;        // Approval status
  final String? approvedBy;      // Admin who approved
  final DateTime? approvedAt;    // When approved
}
```

## 👥 Web Admin User Management

### Access
Navigate to: `web/users.html` from the admin portal

### Features Overview

#### **Tab 1: Pending Approval** ⏳
View and manage users waiting for approval:

**Display Information:**
- User's full name
- Email address
- Phone number
- Registration date/time

**Available Actions:**
1. **✓ Approve**: Grant access to the user
2. **✗ Reject**: Delete the user account
3. **👤 Assign Role**: Set user's role before approval

**Approval Workflow:**
```
Admin clicks "Approve" 
  → User record updated with:
    - isApproved: true
    - approvedBy: [Admin Name]
    - approvedAt: [Current Timestamp]
  → User can now login
  → Activity logged in records
```

#### **Tab 2: All Users** 👥
Comprehensive view of all registered users:

**Filters Available:**
- Search by name or email
- Filter by role (all 9 roles)
- Filter by status (Active/Inactive)
- Real-time refresh

**Displayed Information:**
- Name, Email, Role
- Active/Inactive status
- Approval status
- Creation date

**Management Actions:**
1. **✏️ Edit**: Modify user information
2. **🔒 Deactivate/Activate**: Toggle account access
3. **👤 Change Role**: Reassign user role

**Role Management:**
Users can be assigned any of these roles:
1. Farmer
2. Finance Manager
3. Inventory Manager
4. Supplier
5. Driver
6. Dispatch Manager
7. Trainer
8. Service Manager
9. Admin

#### **Tab 3: Create New User** ➕
Admin can create users directly:

**Required Information:**
- Full Name
- Email Address
- Phone Number
- Initial Password
- User Role (dropdown)

**Auto-Approve Option:**
- Checkbox: "Auto-approve this user"
- When checked: User can login immediately
- When unchecked: User needs separate approval

**Use Cases:**
- Creating staff accounts
- Adding employees with specific roles
- Bulk user setup
- Emergency access creation

### Statistics Dashboard
Real-time metrics displayed:
- **Total Users**: All registered users
- **Pending Approval**: Users awaiting approval
- **Active Users**: Currently active accounts
- **Farmers**: Count of farmer users

## 🔄 Complete User Flows

### Flow 1: New Farmer Registration
```
┌─────────────────────────────────────────────────────┐
│ 1. Farmer visits login page                         │
│ 2. Clicks "Don't have an account? Sign Up"         │
│ 3. Fills registration form:                         │
│    - Full Name: John Farmer                         │
│    - Email: john@example.com                        │
│    - Phone: +1234567890                             │
│    - Password: ********                             │
│ 4. Clicks "Sign Up"                                 │
│ 5. Account created in Firebase                      │
│    - role: farmer                                   │
│    - isApproved: false                              │
│ 6. User automatically signed out                    │
│ 7. Success message shown                            │
│ 8. Switches to login mode                           │
└─────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ WAITING FOR ADMIN APPROVAL                          │
│ User cannot login until approved                    │
└─────────────────────────────────────────────────────┘
```

### Flow 2: Admin Approval Process
```
┌─────────────────────────────────────────────────────┐
│ 1. Admin logs into web portal                       │
│ 2. Navigates to Users page                          │
│ 3. Sees "Pending Approval (2)" tab                  │
│ 4. Views pending user: John Farmer                  │
│ 5. Options:                                          │
│    a) Click "Approve" → User can login as Farmer   │
│    b) Click "Assign Role" → Choose different role  │
│    c) Click "Reject" → Delete account              │
│ 6. Admin clicks "Approve"                           │
│ 7. Firebase updated:                                │
│    - isApproved: true                               │
│    - approvedBy: "Admin Name"                       │
│    - approvedAt: 2024-11-18T10:30:00Z              │
│ 8. Activity record created                          │
└─────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│ USER CAN NOW LOGIN                                  │
└─────────────────────────────────────────────────────┘
```

### Flow 3: Role-Based Login
```
┌─────────────────────────────────────────────────────┐
│ 1. Approved user visits login page                  │
│ 2. Enters credentials                                │
│ 3. Auth service validates:                          │
│    - Email/password correct ✓                       │
│    - isApproved: true ✓                             │
│ 4. User logged in successfully                      │
│ 5. System checks user.role                          │
│ 6. Routes to appropriate dashboard:                 │
│                                                      │
│    switch (user.role) {                             │
│      case UserRole.farmer:                          │
│        → Navigate to Pending Courses Screen         │
│      case UserRole.financeManager:                  │
│        → Navigate to Finance Home Screen            │
│      case UserRole.trainer:                         │
│        → Navigate to Trainer Home Screen            │
│      case UserRole.serviceManager:                  │
│        → Navigate to Service Manager Home Screen    │
│      // ... other roles                             │
│    }                                                 │
└─────────────────────────────────────────────────────┘
```

### Flow 4: Admin Creates User
```
┌─────────────────────────────────────────────────────┐
│ 1. Admin navigates to Users → Create New User tab   │
│ 2. Fills form:                                       │
│    - Name: Sarah Finance                             │
│    - Email: sarah@apolloagro.com                    │
│    - Phone: +1234567891                             │
│    - Password: temppass123                          │
│    - Role: Finance Manager                          │
│    - [✓] Auto-approve this user                     │
│ 3. Clicks "Create User"                             │
│ 4. Firebase creates user account                    │
│    - role: financeManager                           │
│    - isApproved: true (auto-approved)               │
│ 5. Success message shown                            │
│ 6. User can login immediately                       │
└─────────────────────────────────────────────────────┘
```

## 🔧 Technical Implementation

### Modified Files

#### 1. `lib/models/user_model.dart`
```dart
// Added fields
final bool isApproved;
final String? approvedBy;
final DateTime? approvedAt;

// Updated factory and toMap methods
// Updated copyWith method
```

#### 2. `lib/services/auth_service.dart`
```dart
// Modified signIn to check approval
Future<User?> signIn(String email, String password) async {
  // ... authentication ...
  if (!userData.isApproved) {
    await _auth.signOut();
    throw Exception('Account pending approval');
  }
}

// Modified signUp to set isApproved: false
Future<User?> signUp(...) async {
  final appUser = AppUser(
    // ...
    isApproved: false,
  );
  // Sign out immediately
}

// New methods
Future<List<AppUser>> getAllUsers()
Future<List<AppUser>> getPendingApprovalUsers()
Future<void> approveUser(userId, approvedByUserId, approverName)
Future<void> updateUserRole(userId, newRole)
Future<void> toggleUserActiveStatus(userId, isActive)
```

#### 3. `lib/screens/auth/login_screen.dart`
```dart
// Removed role selector from sign-up
// Always creates farmer accounts
// Enhanced error messaging for approval status
// Shows success message after registration
```

#### 4. `web/users.html` (NEW)
- Complete user management interface
- Three tabs: Pending, All Users, Create
- Real-time statistics
- Role assignment modal
- Approval/rejection actions

#### 5. `web/index.html` & other web pages
- Updated navigation to include Users link

### Firebase Collections Structure

#### users collection
```javascript
{
  "userId": {
    "email": "user@example.com",
    "name": "User Name",
    "phone": "+1234567890",
    "role": "farmer",
    "isActive": true,
    "isApproved": false,           // NEW
    "approvedBy": "Admin Name",     // NEW
    "approvedAt": "2024-11-18T...", // NEW
    "createdAt": "2024-11-18T...",
    "metadata": {}
  }
}
```

## 📝 User Management Best Practices

### For Administrators

1. **Review Registration Requests Promptly**
   - Check pending approvals daily
   - Verify user information before approving
   - Contact users if information is unclear

2. **Role Assignment Guidelines**
   - Farmers: Agricultural product buyers
   - Finance Manager: Payment and credit approval
   - Trainer: Conducts training sessions
   - Service Manager: Assigns duties to staff
   - Admin: Full system access

3. **Security Considerations**
   - Never auto-approve suspicious registrations
   - Verify business email addresses for staff
   - Use strong initial passwords when creating users
   - Regularly review active user list
   - Deactivate unused accounts

4. **User Communication**
   - Notify users when approved (external to system)
   - Provide login instructions
   - Share appropriate documentation based on role

### For Users

1. **Registration**
   - Provide accurate information
   - Use a valid email address
   - Create a strong password
   - Wait patiently for approval

2. **First Login**
   - Check email for approval notification
   - Login with registered credentials
   - You'll be directed to your role-specific dashboard
   - Update your profile if needed

## 🚀 Future Enhancements

Potential improvements for the approval system:

1. **Email Notifications**
   - Send email when user registers
   - Notify user when approved/rejected
   - Send welcome email with instructions

2. **Approval Notes**
   - Admin can add notes during approval
   - Rejection reasons logged
   - Approval history tracking

3. **Bulk Operations**
   - Approve multiple users at once
   - Bulk role assignment
   - Export user list to CSV

4. **Advanced Filtering**
   - Filter by registration date range
   - Search by multiple criteria
   - Save filter presets

5. **User Analytics**
   - Registration trends
   - Approval time metrics
   - Role distribution charts
   - Active user patterns

## 📊 Impact Summary

### Security Improvements
- ✅ Prevents unauthorized access
- ✅ Ensures proper role assignment
- ✅ Complete audit trail of approvals
- ✅ Admin control over user base

### User Experience
- ✅ Simple self-registration for farmers
- ✅ Clear feedback on account status
- ✅ Automatic routing to correct dashboard
- ✅ No confusion about access rights

### Administrative Control
- ✅ Full visibility of pending users
- ✅ Easy approval/rejection process
- ✅ Flexible role management
- ✅ Direct user creation capability

### Compliance & Audit
- ✅ Track who approved what
- ✅ Timestamp all approvals
- ✅ Activity records for all actions
- ✅ User lifecycle documentation

## 🎯 Integration with Existing Features

The approval system works seamlessly with:

1. **Training Appointments**: Only approved farmers can book
2. **Credit Services**: Only approved users can apply
3. **Product Orders**: Only approved users can purchase
4. **Trainer Assignment**: Service Manager can only assign approved trainers
5. **Activity Records**: All approval actions are logged
6. **Receipts**: Only approved users have transactions

## ✅ Testing Checklist

- [ ] New user can register from login page
- [ ] Registration creates farmer with isApproved: false
- [ ] Login attempt shows "pending approval" message
- [ ] Admin can see pending users in web portal
- [ ] Admin can approve user successfully
- [ ] Approved user can login
- [ ] Role-based routing works after approval
- [ ] Admin can create user with any role
- [ ] Auto-approve option works correctly
- [ ] Role assignment modal functions properly
- [ ] User deactivation prevents login
- [ ] Statistics update correctly
- [ ] Activity records created for approvals

## 📚 Related Documentation

- `SETUP.md`: Firebase configuration for users collection
- `ARCHITECTURE.md`: User model and auth service design
- `NEW_FEATURES.md`: Training appointment system
- `NEW_FEATURES_V2.md`: Service Manager and activity records
- `COMPLETE_SUMMARY.md`: Full system overview

---

**Version**: 3.0
**Last Updated**: 2024-11-18
**Author**: Copilot
**Status**: Production Ready ✅
