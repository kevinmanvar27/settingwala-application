# Event Booking Feature - Complete API & Screen Documentation

## Table of Contents
1. [Overview](#overview)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Screen Implementations](#screen-implementations)
5. [Payment Flow (Cashfree Integration)](#payment-flow-cashfree-integration)
6. [Error Handling](#error-handling)
7. [Caching Strategy](#caching-strategy)

---

## Overview

The Event Booking feature allows users to:
- Browse available events
- View event details (date, time, location, rules)
- Join free events directly
- Pay for premium events via Cashfree payment gateway
- View joined/paid events status

### Key Files

| File | Purpose |
|------|---------|
| `lib/Service/event_service.dart` | API service layer with all event-related methods |
| `lib/model/event_payment_model.dart` | Payment response models for Cashfree integration |
| `lib/screens/events_screen.dart` | Event listing screen with search & filtering |
| `lib/screens/event_details_screen.dart` | Event details & payment flow screen |
| `lib/utils/api_constants.dart` | API endpoint definitions |

---

## API Endpoints

### Base URL
```
https://settingwala.com/api/v1
```

### Authentication
All endpoints require Bearer token authentication:
```
Authorization: Bearer {auth_token}
```

---

### 1. Get Events List

**Endpoint:** `GET /events`

**Service Method:** `EventService.getEvents({bool forceRefresh = false})`

**Description:** Fetches all available events for the authenticated user.

**Request Headers:**
```json
{
  "Content-Type": "application/json",
  "Accept": "application/json",
  "Authorization": "Bearer {token}"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": 1,
        "title": "Speed Dating Night",
        "description": "Meet new people in a fun environment",
        "location": "Mumbai, Maharashtra",
        "latitude": "19.0760",
        "longitude": "72.8777",
        "event_date": "2024-12-25T19:00:00.000000Z",
        "is_couple_event": false,
        "payment_amount_couple": null,
        "payment_amount_boys": "500.00",
        "payment_amount_girls": "300.00",
        "rules_and_regulations": "<ul><li>Dress code: Smart casual</li></ul>",
        "is_event_enabled": true,
        "is_joined": false,
        "participants_count": 25
      }
    ]
  }
}
```

**Caching:** 5 minutes (CacheService.eventsCacheDuration)

---

### 2. Get Event Details

**Endpoint:** `GET /events/{eventId}`

**Service Method:** `EventService.getEventDetails(int eventId, {bool forceRefresh = false})`

**Description:** Fetches detailed information for a specific event.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "event": {
      "id": 1,
      "title": "Speed Dating Night",
      "description": "Meet new people in a fun environment",
      "location": "Mumbai, Maharashtra",
      "latitude": "19.0760",
      "longitude": "72.8777",
      "event_date": "2024-12-25T19:00:00.000000Z",
      "is_couple_event": false,
      "payment_amount_couple": null,
      "payment_amount_boys": "500.00",
      "payment_amount_girls": "300.00",
      "rules_and_regulations": "<ul><li>Dress code: Smart casual</li></ul>",
      "is_event_enabled": true,
      "is_joined": true,
      "participants_count": 25
    }
  }
}
```

**Caching:** Individual event cached with key `event_details_{eventId}`

---

### 3. Join Event

**Endpoint:** `POST /events/{eventId}/join`

**Service Method:** `EventService.joinEvent(int eventId)`

**Description:** Initiates event registration. Returns payment requirement status.

**Request:** No body required

**Response (200/201 - Free Event):**
```json
{
  "success": true,
  "message": "Successfully joined the event",
  "data": {
    "payment_required": false,
    "payment_amount": null,
    "event_payment_id": null
  }
}
```

**Response (200/201 - Paid Event):**
```json
{
  "success": true,
  "message": "Payment required to complete registration",
  "data": {
    "payment_required": true,
    "payment_amount": "500.00",
    "event_payment_id": 123
  }
}
```

**Error Response (400/409 - Already Joined):**
```json
{
  "success": false,
  "message": "You have already joined this event"
}
```

**Service Return Format:**
```dart
{
  'success': bool,
  'message': String,
  'payment_required': bool,
  'payment_amount': double,  // Converted from string
  'event_payment_id': int?,
}
```

---

### 4. Create Payment Order (Cashfree)

**Endpoint:** `POST /events/payment/{eventPaymentId}/create-order`

**Service Method:** `EventService.createPaymentOrder(int eventPaymentId)`

**Description:** Creates a Cashfree payment order for event registration.

**Request:** No body required (eventPaymentId from joinEvent response)

**Response (200/201):**
```json
{
  "success": true,
  "message": "Payment order created successfully",
  "data": {
    "payment_session_id": "session_xxx",
    "order_id": "order_xxx",
    "amount": 500.00,
    "currency": "INR",
    "event_payment_id": 123,
    "environment": "sandbox"
  }
}
```

**Model:** `EventPaymentOrderModel` → `EventPaymentOrderData`

---

### 5. Verify Payment

**Endpoint:** `POST /events/payment/{eventPaymentId}/verify`

**Service Method:** 
```dart
EventService.verifyPayment({
  required int eventPaymentId,
  required String orderId,
  String? transactionId,
  String? signature,
})
```

**Description:** Verifies payment completion with Cashfree after SDK callback.

**Request Body:**
```json
{
  "order_id": "order_xxx",
  "transaction_id": "cf_xxx",  // Optional
  "signature": "xxx"           // Optional
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Payment verified successfully",
  "data": {
    "status": "completed",
    "event_payment_id": 123,
    "amount_paid": 500.00,
    "transaction_id": "cf_xxx"
  }
}
```

**Status Values:** `completed`, `pending`, `failed`

**Model:** `EventPaymentVerifyModel` → `EventPaymentVerifyData`

---

### 6. Get Payment Status

**Endpoint:** `GET /events/payment/{eventPaymentId}/status`

**Service Method:** `EventService.getEventPaymentStatus(int eventPaymentId)`

**Description:** Checks current payment status (useful for reconciliation).

**Response (200):**
```json
{
  "success": true,
  "data": {
    "status": "completed",
    "event_payment_id": 123,
    "amount_paid": 500.00,
    "transaction_id": "cf_xxx"
  }
}
```

---

## Data Models

### EventModel

**Location:** `lib/Service/event_service.dart` (lines 10-90)

```dart
class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? eventDate;
  final bool isCoupleEvent;
  final double? paymentAmountCouple;
  final double? paymentAmountBoys;
  final double? paymentAmountGirls;
  final String? rulesAndRegulations;  // HTML content
  final bool isEventEnabled;
  final bool isJoined;
  final int participantsCount;
  final int? eventPaymentId;  // Payment ID for fetching payment status (when is_joined = true)
}
```

**JSON Mapping:**
| Dart Field | JSON Key |
|------------|----------|
| id | id |
| title | title |
| description | description |
| location | location |
| latitude | latitude (parsed as double) |
| longitude | longitude (parsed as double) |
| eventDate | event_date (ISO 8601) |
| isCoupleEvent | is_couple_event |
| paymentAmountCouple | payment_amount_couple |
| paymentAmountBoys | payment_amount_boys |
| eventPaymentId | event_payment_id |
| paymentAmountGirls | payment_amount_girls |
| rulesAndRegulations | rules_and_regulations |
| isEventEnabled | is_event_enabled |
| isJoined | is_joined |
| participantsCount | participants_count |

---

### EventPaymentOrderData

**Location:** `lib/model/event_payment_model.dart`

```dart
class EventPaymentOrderData {
  int eventPaymentId;
  double amount;
  String currency;
  String orderId;
  String paymentSessionId;
  String environment;  // "sandbox" or "production"
  
  bool get isProduction => environment.toLowerCase() == 'production';
}
```

---

### EventPaymentVerifyData

**Location:** `lib/model/event_payment_model.dart`

```dart
class EventPaymentVerifyData {
  String status;  // "completed", "pending", "failed"
  int? eventPaymentId;
  double? amountPaid;
  String? transactionId;
  
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';
}
```

---

## Screen Implementations

### EventsScreen

**Location:** `lib/screens/events_screen.dart`

**Features:**
- Search with debouncing (300ms)
- Responsive grid/list layout
- Pull-to-refresh
- Loading/Error/Empty states
- Animated transitions

**Key Components:**

| Component | Description |
|-----------|-------------|
| `_searchController` | Text controller for search input |
| `_searchDebouncer` | 300ms debounce for search |
| `filteredEvents` | Getter that filters events by search query |
| `_loadEvents()` | Fetches events from API |

**Layout Responsiveness:**
- Mobile (< 600px): Single column list
- Tablet (600-1024px): 2 column grid
- Desktop (≥ 1024px): 3 column grid

**Event Card Display:**
- Event title & icon
- Date & time
- Location
- Participant count badge
- "Paid" badge for joined events
- "Join Event" / "View Details" button

---

### EventDetailsScreen

**Location:** `lib/screens/event_details_screen.dart`

**Features:**
- Event banner with status badge
- Date/Time card
- Location card with Google Maps integration
- Description card
- Rules & Regulations (HTML parsing)
- Payment card with gender-based pricing
- Cashfree payment integration
- Join/Payment status indicators

**Key State Variables:**

```dart
bool _isJoining = false;           // Loading state for join/payment
bool _isJoined = false;            // User has joined event
String? _userGender;               // From SharedPreferences
int? _eventPaymentId;              // From joinEvent response OR widget.event.eventPaymentId
EventPaymentOrderData? _paymentOrderData;  // From createPaymentOrder

// Payment Status Display
bool _isLoadingPaymentStatus = false;      // Loading state for status fetch
EventPaymentVerifyData? _paymentStatusData; // Payment status from API
```

**Key Methods:**

| Method | Description |
|--------|-------------|
| `_loadUserGender()` | Loads user gender from SharedPreferences |
| `_getPaymentAmount()` | Returns appropriate price based on gender/couple |
| `_isFreeEvent()` | Returns true if payment amount is 0 |
| `_handleJoinEvent()` | Step 1: Initiates join flow |
| `_createPaymentOrder()` | Step 2: Creates Cashfree order |
| `_openCashfreePayment()` | Step 3: Opens Cashfree SDK |
| `_verifyPayment()` | Step 4: Verifies payment with backend |
| `_showPaymentConfirmation()` | Shows confirmation dialog before payment |
| `_fetchPaymentStatus()` | Fetches payment status from API (GET /events/payment/{id}/status) |
| `_buildPaymentStatusCard()` | Displays payment status with amount, transaction ID, status |

---

## Payment Flow (Cashfree Integration)

### Complete 4-Step Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER CLICKS "PAY NOW"                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: _handleJoinEvent()                                      │
│ ─────────────────────────────                                   │
│ POST /events/{eventId}/join                                     │
│                                                                 │
│ Response:                                                       │
│ • payment_required: true                                        │
│ • payment_amount: 500.00                                        │
│ • event_payment_id: 123                                         │
│                                                                 │
│ → Shows _showPaymentConfirmation() dialog                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                    User clicks "Pay ₹500"
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: _createPaymentOrder()                                   │
│ ─────────────────────────────                                   │
│ POST /events/payment/{eventPaymentId}/create-order              │
│                                                                 │
│ Response:                                                       │
│ • order_id: "order_xxx"                                         │
│ • payment_session_id: "session_xxx"                             │
│ • amount: 500.00                                                │
│ • environment: "sandbox"/"production"                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: _openCashfreePayment()                                  │
│ ─────────────────────────────                                   │
│ CFPaymentGatewayService.doPayment()                             │
│                                                                 │
│ Configuration:                                                  │
│ • CFEnvironment: SANDBOX or PRODUCTION                          │
│ • Payment Methods: CARD, UPI, NETBANKING, WALLET                │
│ • Theme: Purple (#6750A4)                                       │
│                                                                 │
│ Callbacks:                                                      │
│ • onSuccess(orderId) → _verifyPayment()                         │
│ • onFailure(error, orderId) → _onPaymentFailure()               │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Payment Success
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: _verifyPayment(orderId)                                 │
│ ─────────────────────────────                                   │
│ POST /events/payment/{eventPaymentId}/verify                    │
│ Body: { "order_id": "order_xxx" }                               │
│                                                                 │
│ Response:                                                       │
│ • status: "completed"                                           │
│ • amount_paid: 500.00                                           │
│                                                                 │
│ → Sets _isJoined = true                                         │
│ → Shows success message                                         │
└─────────────────────────────────────────────────────────────────┘
```

### Cashfree SDK Configuration

```dart
// Environment selection
final cfEnvironment = _paymentOrderData!.isProduction
    ? CFEnvironment.PRODUCTION
    : CFEnvironment.SANDBOX;

// Session setup
final cfSession = CFSessionBuilder()
    .setEnvironment(cfEnvironment)
    .setOrderId(_paymentOrderData!.orderId)
    .setPaymentSessionId(_paymentOrderData!.paymentSessionId)
    .build();

// Payment methods
final cfPaymentComponent = CFPaymentComponentBuilder()
    .setComponents([
      CFPaymentModes.CARD,
      CFPaymentModes.UPI,
      CFPaymentModes.NETBANKING,
      CFPaymentModes.WALLET,
    ])
    .build();

// Theme customization
final cfTheme = CFThemeBuilder()
    .setNavigationBarBackgroundColorColor("#6750A4")
    .setNavigationBarTextColor("#FFFFFF")
    .setButtonBackgroundColor("#6750A4")
    .setButtonTextColor("#FFFFFF")
    .setPrimaryTextColor("#000000")
    .setSecondaryTextColor("#666666")
    .build();
```

### Gender-Based Pricing Logic

```dart
double _getPaymentAmount() {
  // 1. Couple event - use couple price
  if (widget.event.isCoupleEvent && widget.event.paymentAmountCouple != null) {
    return widget.event.paymentAmountCouple!;
  }
  
  // 2. Female user - use girls price
  if (_userGender == 'female' && widget.event.paymentAmountGirls != null) {
    return widget.event.paymentAmountGirls!;
  }
  
  // 3. Default - use boys price
  if (widget.event.paymentAmountBoys != null) {
    return widget.event.paymentAmountBoys!;
  }
  
  // 4. Free event
  return 0.0;
}
```

**User gender is loaded from:**
```dart
final prefs = await SharedPreferences.getInstance();
_userGender = prefs.getString('user_gender') ?? 'male';
```

---

### Payment Status Display

When user has already joined an event (`is_joined = true`), the screen automatically fetches and displays the payment status.

**Initialization Flow:**
```dart
@override
void initState() {
  super.initState();
  _isJoined = widget.event.isJoined;
  _eventPaymentId = widget.event.eventPaymentId;
  
  // Auto-fetch payment status if user is joined and has payment ID
  if (_isJoined && widget.event.eventPaymentId != null) {
    _fetchPaymentStatus();
  }
}
```

**API Call:**
```dart
Future<void> _fetchPaymentStatus() async {
  final result = await EventService.getEventPaymentStatus(widget.event.eventPaymentId!);
  if (result != null && result.data != null) {
    _paymentStatusData = result.data;
  }
}
```

**Status Card Display:**

| Status | Color | Icon | Description |
|--------|-------|------|-------------|
| `completed` | Green | ✓ check_circle | Payment successful |
| `pending` | Orange | ⏱ access_time | Payment processing |
| `failed` | Red | ✗ cancel | Payment failed |
| No data | Green | ✓ check_circle | Registered (free event) |

**Payment Details Shown:**
- Status badge (COMPLETED/PENDING/FAILED)
- Amount Paid (₹500)
- Transaction ID (cf_xxx)
- Payment Reference (#123)
- Refresh Status button

**UI Section:**
```dart
if (_isJoined) ...[
  _buildSectionTitle('Payment Status', colors, sectionTitleSize),
  _buildPaymentStatusCard(context, colors, primaryColor, isDark),
]
```

---

## Error Handling

### API Error Handling in EventService

```dart
// Empty response body
if (response.body.isEmpty) {
  return {
    'success': false,
    'message': 'Server returned empty response',
  };
}

// Invalid JSON
try {
  data = jsonDecode(response.body);
} catch (e) {
  return {
    'success': false,
    'message': 'Invalid server response format',
  };
}

// Error message extraction
String errorMessage = 'Failed to join event';
if (data['message'] != null) {
  errorMessage = data['message'];
} else if (data['error'] != null) {
  errorMessage = data['error'];
} else if (data['errors'] != null && data['errors'] is Map) {
  // Validation errors
  final errors = data['errors'] as Map;
  errorMessage = errors.values.first is List 
      ? (errors.values.first as List).first.toString()
      : errors.values.first.toString();
}
```

### Payment Verification Fallback

```dart
Future<void> _verifyPayment(String orderId) async {
  try {
    final verifyResult = await EventService.verifyPayment(...);
    
    if (verifyResult != null && verifyResult.success) {
      setState(() => _isJoined = true);
      _showSuccessMessage('Payment successful!');
    } else {
      // Even if verify fails, payment might be successful
      // Backend will handle reconciliation
      setState(() => _isJoined = true);
      _showSuccessMessage('Payment completed! Registration confirmed.');
    }
  } catch (e) {
    // Assume success if verification call fails but payment was done
    setState(() => _isJoined = true);
    _showSuccessMessage('Payment completed! Please check your registration status.');
  }
}
```

### UI Error Messages

```dart
void _showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
```

---

## Caching Strategy

### Cache Keys

| Key | Description | Duration |
|-----|-------------|----------|
| `events_list` | All events list | 5 minutes |
| `event_details_{id}` | Individual event details | 5 minutes |

### Cache Service Usage

```dart
// Check cache first
if (!forceRefresh) {
  final cachedData = await CacheService.getFromCache(CacheService.eventsListKey);
  if (cachedData != null) {
    return eventsList.map((e) => EventModel.fromJson(e)).toList();
  }
}

// Save to cache after API call
await CacheService.saveToCache(
  key: CacheService.eventsListKey,
  data: eventsList,
  durationMinutes: CacheService.eventsCacheDuration,
);
```

### Force Refresh

Both `getEvents()` and `getEventDetails()` accept `forceRefresh` parameter:
```dart
// Normal load (uses cache)
await EventService.getEvents();

// Force refresh (bypasses cache)
await EventService.getEvents(forceRefresh: true);
```

---

## UI Components Reference

### Color Scheme

| Color | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| Primary | `AppColors.primary` | `AppColors.primaryLight` | Buttons, icons, accents |
| Success | `AppColors.success` | `AppColors.success` | Joined status, payment done |
| Error | `AppColors.error` | `AppColors.error` | Error messages |
| Boys Price | `Colors.blue` | `Colors.blue` | Male pricing display |
| Girls Price | `Colors.pink` | `Colors.pink` | Female pricing display |

### Responsive Breakpoints

| Screen Type | Width | Grid Columns |
|-------------|-------|--------------|
| Small | < 360px | 1 |
| Mobile | 360-599px | 1 |
| Tablet | 600-1023px | 2 |
| Desktop | ≥ 1024px | 3 |

---

## Test Scenarios

### Free Event Flow
1. User clicks "Join Event (Free)"
2. API returns `payment_required: false`
3. `_isJoined` set to `true`
4. Success message shown
5. UI updates to show "You have joined this event!"

### Paid Event Flow
1. User clicks "Pay Now"
2. `joinEvent()` returns `payment_required: true` with `event_payment_id`
3. Confirmation dialog shown with amount
4. User confirms → `createPaymentOrder()` called
5. Cashfree SDK opens
6. User completes payment
7. `verifyPayment()` called
8. Success → UI updates to "Payment Done"

### Already Joined Event
1. Event has `is_joined: true` from API
2. Button shows "Payment Done" (disabled)
3. Banner shows green "Payment Done" badge
4. Tick mark icon displayed

---

## Known Limitations

1. **No getMyEvents endpoint** - Use `getEvents()` and filter by `is_joined` flag
2. **HTML in rules** - Rules field contains HTML that needs parsing
3. **Payment amount as string** - API returns amounts as strings, need parsing

---

## Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_cashfree_pg_sdk: ^x.x.x  # Cashfree payment SDK
  shared_preferences: ^x.x.x       # User data storage
  url_launcher: ^x.x.x             # Maps integration
  http: ^x.x.x                     # API calls
```

---

*Documentation generated: Event Booking Feature v1.0*
*Last updated: Based on current codebase analysis*
