# TwoDo iPhone App - Technical Specification

## Executive Summary

TwoDo is a couples-focused life management iOS application that enables partners to collaboratively manage tasks, routines, events, and shared notes. The iPhone app will provide a native iOS experience while consuming the existing REST API backend.

---

## 1. Technology Stack

### iOS Development
- **Platform**: iOS 16.0+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependency Management**: Swift Package Manager

### Core Libraries
- **Networking**: URLSession with async/await
- **Local Storage**: SwiftData (iOS 17+) or Core Data (iOS 16)
- **Authentication**: Keychain Services for token storage
- **Push Notifications**: APNs (Apple Push Notification service)
- **Calendar Integration**: EventKit
- **Image Handling**: SwiftUI Image + AsyncImage

---

## 2. Architecture Overview

### Project Structure
```
TwoDo/
├── App/
│   ├── TwoDoApp.swift                    # App entry point
│   └── AppDelegate.swift                 # Push notification handling
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift              # Base API client
│   │   ├── APIEndpoint.swift            # Endpoint definitions
│   │   └── APIError.swift               # Error handling
│   ├── Storage/
│   │   ├── KeychainManager.swift        # Secure token storage
│   │   └── CacheManager.swift           # Local data caching
│   └── Extensions/
│       ├── Date+Extensions.swift
│       ├── Color+Extensions.swift
│       └── View+Extensions.swift
├── Models/
│   ├── User.swift
│   ├── Couple.swift
│   ├── Task.swift
│   ├── TaskList.swift
│   ├── Routine.swift
│   ├── Event.swift
│   ├── Note.swift
│   └── Notification.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── TaskViewModel.swift
│   ├── RoutineViewModel.swift
│   ├── CalendarViewModel.swift
│   ├── NotificationViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Authentication/
│   │   ├── LoginView.swift
│   │   ├── SignupView.swift
│   │   └── EmailVerificationView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── TaskListView.swift
│   │   └── TaskDetailView.swift
│   ├── Routines/
│   │   ├── RoutinesView.swift
│   │   ├── RoutineDetailView.swift
│   │   └── RoutineFormView.swift
│   ├── Calendar/
│   │   ├── CalendarView.swift
│   │   ├── EventDetailView.swift
│   │   └── EventFormView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ProfileSettingsView.swift
│   │   └── CoupleSettingsView.swift
│   └── Components/
│       ├── TaskRow.swift
│       ├── NotificationBadge.swift
│       ├── LoadingView.swift
│       └── EmptyStateView.swift
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── Info.plist
```

### Data Flow
```
View → ViewModel → APIClient → Backend API
  ↑        ↓
  └── Combine Publishers (State Management)
```

---

## 3. API Integration

### Base Configuration
```swift
struct APIConfig {
    static let baseURL = "https://api.twodo.app"
    static let apiVersion = "/api"
    static let timeout: TimeInterval = 30
}
```

### Authentication Flow
1. **Login/Register**: POST credentials → Receive JWT access token + refresh token
2. **Token Storage**: Store refresh token in Keychain, access token in memory
3. **Token Refresh**: Automatic refresh when access token expires
4. **Logout**: Clear tokens from Keychain

### API Endpoints (from existing backend)

#### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user
- `POST /api/auth/verify-email` - Email verification
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

#### Couples
- `POST /api/couples` - Create couple
- `GET /api/couples/me` - Get user's couple
- `POST /api/couples/generate-invite` - Generate invite code
- `POST /api/couples/join` - Join couple with code
- `PUT /api/couples/:id` - Update couple
- `DELETE /api/couples/:id/leave` - Leave couple

#### Tasks
- `GET /api/lists` - Get all task lists
- `POST /api/lists` - Create task list
- `GET /api/lists/:id/tasks` - Get tasks in list
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `POST /api/tasks/:id/complete` - Toggle completion
- `POST /api/tasks/:id/assign` - Assign task
- `DELETE /api/tasks/:id` - Delete task

#### Routines
- `GET /api/routines` - Get all routines
- `POST /api/routines` - Create routine
- `GET /api/routines/:id` - Get routine details
- `PUT /api/routines/:id` - Update routine
- `DELETE /api/routines/:id` - Delete routine
- `POST /api/routines/:id/occurrences/:occurrenceId/complete` - Complete occurrence
- `POST /api/routines/:id/occurrences/:occurrenceId/skip` - Skip occurrence
- `GET /api/routines/:id/stats` - Get routine statistics

#### Events
- `GET /api/events` - Get events (with date range)
- `GET /api/events/upcoming` - Get upcoming events
- `POST /api/events` - Create event
- `GET /api/events/:id` - Get event details
- `PUT /api/events/:id` - Update event
- `DELETE /api/events/:id` - Delete event

#### Notifications
- `GET /api/notifications` - Get notifications
- `GET /api/notifications/unread-count` - Get unread count
- `PUT /api/notifications/:id/read` - Mark as read
- `PUT /api/notifications/read-all` - Mark all as read
- `DELETE /api/notifications/:id` - Delete notification

#### Notes
- `GET /api/notes/:type/:id` - Get notes for entity (task/event/routine)
- `POST /api/notes` - Create note
- `PUT /api/notes/:id` - Update note
- `DELETE /api/notes/:id` - Delete note

#### Settings
- `GET /api/settings` - Get user and couple settings
- `PUT /api/settings/profile` - Update profile
- `PUT /api/settings/password` - Update password
- `PUT /api/settings/couple` - Update couple settings

---

## 4. Screen Specifications

### 4.1 Authentication Screens

#### Login Screen
- **Elements**:
  - Email text field (keyboard: email)
  - Password text field (secure entry)
  - "Login" button (primary action)
  - "Forgot Password?" link
  - "Don't have an account? Sign up" link
- **Validation**:
  - Email format validation
  - Password minimum 8 characters
- **Error Handling**:
  - Display inline errors below fields
  - Show alert for network errors

#### Signup Screen
- **Elements**:
  - Display name text field
  - Email text field
  - Password text field
  - Confirm password text field
  - Timezone picker (optional)
  - "Sign Up" button
  - "Already have an account? Login" link
- **Validation**:
  - All fields required except timezone
  - Password match validation
  - Email format validation

#### Email Verification Screen
- **Elements**:
  - Verification code text field (6 digits)
  - "Verify" button
  - "Resend Code" button
  - Timer countdown (24 hours)
- **Auto-fill**: Support SMS code auto-fill

### 4.2 Couple Setup Screens

#### Create Couple Screen
- **Elements**:
  - Couple name text field
  - "Create Couple" button
- **Post-creation**:
  - Show invite code modal
  - Copy to clipboard button
  - Share via iOS share sheet

#### Join Couple Screen
- **Elements**:
  - Invite code text field (formatted: XXXX-XXXX-XXXX-XXXX)
  - "Join Couple" button
  - QR code scanner button (optional)
- **Validation**:
  - Code format validation
  - Expiration check

### 4.3 Dashboard (Home) Screen

#### Layout
- **Navigation Bar**:
  - Title: "TwoDo"
  - Notification bell icon (with badge)
  - Settings gear icon
- **Content**:
  - Tab bar: Tasks | Routines | Calendar
  - Task list sidebar (collapsible)
  - Main content area
  - Floating "+" button for quick add

#### Task List View
- **Sidebar**:
  - "All Tasks" (default)
  - Custom lists (scrollable)
  - "+" button to create list
  - Routines link
  - Calendar link
  - Settings link
- **Main Area**:
  - Task list with checkboxes
  - Swipe actions: Edit | Delete
  - Tap to expand: Shows description, due date, notes
  - Pull to refresh

#### Task Detail View (Sheet/Modal)
- **Elements**:
  - Title (editable)
  - Description (editable, multi-line)
  - Due date picker
  - Priority selector (Low/Medium/High)
  - Assign to partner toggle
  - Notes section (expandable)
  - Delete button
- **Actions**:
  - Save changes
  - Complete/Uncomplete toggle
  - Add note

### 4.4 Routines Screen

#### Routines List View
- **Elements**:
  - List of active routines
  - Each card shows:
    - Routine name
    - Schedule (e.g., "Daily", "Mon, Wed, Fri")
    - Current streak 🔥
    - Completion rate %
    - Today's status (checkbox if due today)
- **Actions**:
  - Tap to view details
  - Swipe to edit/delete
  - "+" button to create routine

#### Routine Detail View
- **Tabs**:
  - Overview: Stats, description, schedule
  - History: Last 30 days with checkmarks
- **Stats**:
  - Current streak
  - Longest streak
  - Completion rate
  - Total completed
- **Actions**:
  - Edit routine
  - Complete today's occurrence
  - Skip today
  - Delete routine

#### Routine Form (Create/Edit)
- **Elements**:
  - Name text field
  - Description (optional)
  - Schedule picker:
    - Frequency: Daily | Weekly | Monthly
    - Days of week (for weekly)
    - Day of month (for monthly)
  - Assign to partner toggle
  - Color picker (optional)
- **Validation**:
  - Name required
  - Valid schedule configuration

### 4.5 Calendar Screen

#### Calendar View
- **Elements**:
  - Month view (grid)
  - Week view (optional)
  - Current day highlighted
  - Event dots on days with events
  - Month navigation (< >)
  - "Today" button
- **Tap Day**: Show events for that day
- **Long Press Day**: Quick create event

#### Event List View (Bottom Sheet)
- **Elements**:
  - List of events for selected day
  - Each event shows:
    - Time (or "All Day")
    - Title
    - Location (if present)
    - Assigned partner icon
- **Tap Event**: Open detail view

#### Event Detail View
- **Elements**:
  - Title
  - Description
  - Start date/time
  - End date/time (optional)
  - All-day toggle
  - Location
  - Reminder settings (minutes before)
  - Recurrence settings
  - Assigned to partner toggle
  - Notes section
- **Actions**:
  - Edit event
  - Delete event
  - Add to iOS Calendar (EventKit integration)

### 4.6 Notifications Screen

#### Notification Center
- **Elements**:
  - List of notifications (grouped by date)
  - Each notification shows:
    - Icon based on type (📋 task, 🔄 routine, 📅 event)
    - Title
    - Body text
    - Timestamp
    - Read/unread indicator
- **Actions**:
  - Tap to mark as read and navigate to entity
  - Swipe to delete
  - "Mark all as read" button
- **Empty State**:
  - Bell icon
  - "No notifications yet"

### 4.7 Settings Screen

#### Settings Tabs
1. **Profile**
   - Display name
   - Email (read-only)
   - Timezone picker
   - Avatar image (upload/camera)
   - Save button

2. **Couple**
   - Couple name
   - Partner's name/email
   - Leave couple button (with confirmation)
   - Invite new partner (if solo)

3. **Password**
   - Current password
   - New password
   - Confirm new password
   - Update button

4. **Notifications** (iOS Native)
   - Enable/disable push notifications
   - Notification categories:
     - Tasks
     - Routines
     - Events
   - Link to iOS Settings

5. **About**
   - App version
   - Terms of Service
   - Privacy Policy
   - Logout button

---

## 5. Features & Functionality

### 5.1 Authentication & Security
- ✅ JWT-based authentication
- ✅ Secure token storage in Keychain
- ✅ Automatic token refresh
- ✅ Biometric authentication (Face ID / Touch ID) for quick login
- ✅ Logout clears all local data

### 5.2 Offline Support
- ✅ Cache tasks, routines, events locally
- ✅ Queue mutations while offline
- ✅ Sync when connection restored
- ✅ Conflict resolution (last-write-wins)
- ✅ Visual indicator for offline mode

### 5.3 Push Notifications
- ✅ Task due reminders
- ✅ Routine due reminders
- ✅ Event reminders
- ✅ Partner activity notifications
- ✅ Rich notifications with quick actions:
  - Complete task/routine
  - Snooze reminder
  - View details

### 5.4 iOS Integrations
- ✅ EventKit: Export events to iOS Calendar
- ✅ Share Sheet: Share invite codes
- ✅ Widgets: Today's tasks and routines
- ✅ Siri Shortcuts: "Complete morning routine"
- ✅ Spotlight Search: Search tasks/events

### 5.5 Real-time Updates
- ✅ WebSocket connection for live updates
- ✅ Partner completes task → instant sync
- ✅ New notification → badge update
- ✅ Optimistic UI updates

### 5.6 Accessibility
- ✅ VoiceOver support
- ✅ Dynamic Type (text sizing)
- ✅ High contrast mode
- ✅ Reduce motion support
- ✅ Semantic labels

---

## 6. Data Models (Swift)

### User Model
```swift
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String
    var avatarUrl: String?
    var timezone: String
    var emailVerified: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

### Couple Model
```swift
struct Couple: Codable, Identifiable {
    let id: String
    var name: String
    var inviteCode: String?
    var inviteCodeExpiresAt: Date?
    var createdAt: Date
    var updatedAt: Date
}
```

### Task Model
```swift
struct Task: Codable, Identifiable {
    let id: String
    let listId: String
    var title: String
    var description: String?
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date?
    var assignedToUserId: String?
    var completedAt: Date?
    var completedById: String?
    let createdById: String
    var createdAt: Date
    var updatedAt: Date
}

enum TaskStatus: String, Codable {
    case pending, inProgress = "in_progress", completed
}

enum TaskPriority: String, Codable {
    case low, medium, high
}
```

### Routine Model
```swift
struct Routine: Codable, Identifiable {
    let id: String
    var name: String
    var description: String?
    var schedule: RoutineSchedule
    var assignedToUserId: String?
    let createdById: String
    var createdAt: Date
    var updatedAt: Date
}

struct RoutineSchedule: Codable {
    var frequency: RoutineFrequency
    var daysOfWeek: [Int]? // 0 = Sunday, 6 = Saturday
    var dayOfMonth: Int?
}

enum RoutineFrequency: String, Codable {
    case daily, weekly, monthly
}

struct RoutineStats: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCompleted: Int
    var completionRate: Double
}
```

### Event Model
```swift
struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var location: String?
    var reminderMinutes: Int?
    var recurrence: EventRecurrence?
    var assignedToUserId: String?
    let createdById: String
    var createdAt: Date
    var updatedAt: Date
}

struct EventRecurrence: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int
    var until: Date?
}

enum RecurrenceFrequency: String, Codable {
    case daily, weekly, monthly, yearly
}
```

### Note Model
```swift
struct Note: Codable, Identifiable {
    let id: String
    var content: String
    var attachedToType: NoteAttachmentType
    var attachedToId: String
    let createdById: String
    var createdAt: Date
    var updatedAt: Date
}

enum NoteAttachmentType: String, Codable {
    case task, event, routine
}
```

### Notification Model
```swift
struct Notification: Codable, Identifiable {
    let id: String
    var type: NotificationType
    var title: String
    var body: String
    var isRead: Bool
    var relatedEntityType: String?
    var relatedEntityId: String?
    var createdAt: Date
}

enum NotificationType: String, Codable {
    case taskDue = "task_due"
    case taskAssigned = "task_assigned"
    case routineDue = "routine_due"
    case eventReminder = "event_reminder"
}
```

---

## 7. UI/UX Design Guidelines

### Color Palette
- **Primary**: #6366F1 (Indigo)
- **Secondary**: #EC4899 (Pink)
- **Success**: #10B981 (Green)
- **Warning**: #F59E0B (Amber)
- **Error**: #EF4444 (Red)
- **Background**: #F9FAFB (Light Gray)
- **Surface**: #FFFFFF (White)
- **Text Primary**: #111827 (Dark Gray)
- **Text Secondary**: #6B7280 (Medium Gray)

### Typography
- **Headline**: SF Pro Display Bold, 28pt
- **Title**: SF Pro Text Semibold, 20pt
- **Body**: SF Pro Text Regular, 16pt
- **Caption**: SF Pro Text Regular, 12pt

### Spacing
- **XS**: 4pt
- **SM**: 8pt
- **MD**: 16pt
- **LG**: 24pt
- **XL**: 32pt

### Components
- **Buttons**: Rounded corners (8pt), min height 44pt
- **Cards**: Shadow, rounded corners (12pt), padding 16pt
- **Input Fields**: Border radius 8pt, height 44pt
- **Icons**: SF Symbols, 20pt default

---

## 8. Performance Requirements

### Response Times
- API calls: < 2s
- Screen transitions: < 300ms
- List scrolling: 60fps
- Image loading: Progressive (blur-up)

### Data Limits
- Cache size: Max 100MB
- Image cache: Max 50MB
- Offline queue: Max 1000 operations

### Battery & Network
- Background sync: Limited to 15 minutes per session
- Image quality: Adaptive based on network (WiFi vs Cellular)
- Pagination: 50 items per page

---

## 9. Testing Strategy

### Unit Tests
- ViewModels: Business logic, state management
- API Client: Request/response handling
- Models: Codable conformance
- Cache Manager: Storage/retrieval

### UI Tests
- Authentication flow
- Task creation and completion
- Routine tracking
- Event management
- Settings updates

### Integration Tests
- API integration
- Push notification handling
- Calendar sync
- Offline sync

---

## 10. Development Phases

### Phase 1: Foundation (Week 1-2)
- ✅ Project setup
- ✅ API client implementation
- ✅ Authentication flow
- ✅ Token management
- ✅ Basic navigation

### Phase 2: Core Features (Week 3-4)
- ✅ Dashboard with task lists
- ✅ Task CRUD operations
- ✅ Couple pairing
- ✅ Local caching

### Phase 3: Advanced Features (Week 5-6)
- ✅ Routines with streak tracking
- ✅ Calendar and events
- ✅ Notes system
- ✅ Notifications

### Phase 4: Polish & iOS Integration (Week 7-8)
- ✅ Push notifications
- ✅ Widgets
- ✅ Siri Shortcuts
- ✅ EventKit integration
- ✅ Offline support

### Phase 5: Testing & Launch (Week 9-10)
- ✅ Comprehensive testing
- ✅ App Store submission
- ✅ Beta testing (TestFlight)
- ✅ Launch

---

## 11. App Store Information

### App Name
**TwoDo - Couples Life Manager**

### Category
- Primary: Productivity
- Secondary: Lifestyle

### Keywords
couples, tasks, routines, calendar, shared, productivity, habits, life management

### Description
TwoDo helps couples stay organized together. Manage shared tasks, build routines, sync calendars, and collaborate on your life together - all in one beautiful app.

### Features List
- Shared task lists with your partner
- Habit tracking with streaks
- Shared calendar and events
- Real-time sync across devices
- Push notifications for reminders
- Notes on tasks and events
- Beautiful, intuitive interface

### Screenshots Required
1. Dashboard with task lists
2. Routine tracking with streaks
3. Calendar view
4. Task detail with notes
5. Settings screen

### Privacy Policy Points
- Data encryption in transit and at rest
- No third-party data sharing
- User can delete all data
- OAuth for authentication
- Minimal data collection

---

## 12. Future Enhancements (Post-Launch)

### v1.1
- Dark mode support
- Custom themes
- Task categories/tags
- File attachments

### v1.2
- Apple Watch companion app
- Home Screen widgets (medium/large)
- Siri integration improvements
- Location-based reminders

### v1.3
- iPad app with split view
- Shared shopping lists
- Budget tracking
- Goal setting

### v1.4
- macOS app (Catalyst)
- Vision Pro support
- Advanced analytics
- Export data

---

## 13. Backend Requirements (Existing)

The existing TwoDo backend API already supports all required endpoints. The following enhancements would improve the iOS experience:

### Recommended Backend Additions
1. **WebSocket Support**: Real-time updates
2. **APNs Integration**: Server-side push notification delivery
3. **File Upload**: For avatar images and attachments
4. **Rate Limiting**: Per-device rate limits
5. **Device Management**: Register/unregister devices for push

### WebSocket Events
```typescript
// Client → Server
"task:complete", "task:create", "task:update", "task:delete"
"routine:complete", "routine:skip"
"event:create", "event:update", "event:delete"
"notification:read"

// Server → Client
"task:updated", "task:deleted"
"routine:completed_by_partner"
"event:reminder"
"notification:new"
```

---

## 14. Security Considerations

### Data Security
- ✅ HTTPS only
- ✅ Certificate pinning
- ✅ Keychain for sensitive data
- ✅ No plaintext passwords in memory
- ✅ Auto-lock after inactivity

### API Security
- ✅ JWT token rotation
- ✅ Token expiration handling
- ✅ Refresh token single-use
- ✅ API request signing (optional)

### Privacy
- ✅ Request only necessary permissions
- ✅ Clear privacy policy
- ✅ User data export
- ✅ Account deletion

---

## 15. Monitoring & Analytics

### App Analytics (Privacy-Preserving)
- Screen views
- Feature usage
- Crash reports
- Performance metrics
- Error tracking

### Tools
- **Crashlytics**: Crash reporting
- **Analytics**: Apple App Analytics (privacy-focused)
- **Logging**: Custom logging framework

---

## Appendix A: API Request Examples

### Login Request
```swift
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}
```

### Create Task Request
```swift
struct CreateTaskRequest: Codable {
    let listId: String
    let title: String
    let description: String?
    let dueDate: Date?
    let priority: TaskPriority
}

struct CreateTaskResponse: Codable {
    let task: Task
}
```

---

## Appendix B: SwiftUI View Examples

### Task Row Component
```swift
struct TaskRow: View {
    @Binding var task: Task
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == .completed ? .green : .gray)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.status == .completed)

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let priority = task.priority {
                PriorityBadge(priority: priority)
            }
        }
        .padding(.vertical, 8)
    }
}
```

---

## Conclusion

This specification provides a comprehensive blueprint for building the TwoDo iPhone app. The app will leverage the existing robust backend API while providing a native iOS experience with SwiftUI, offline support, push notifications, and deep iOS integrations.

The modular architecture ensures maintainability and scalability, while the phased development approach allows for iterative delivery and user feedback incorporation.

**Next Steps:**
1. Set up Xcode project with Swift Package Manager
2. Implement API client and authentication
3. Build out core screens (Dashboard, Routines, Calendar)
4. Integrate push notifications
5. Add iOS-specific features (Widgets, Siri)
6. Test thoroughly and submit to App Store

---

**Document Version:** 1.0
**Last Updated:** 2025-11-21
**Author:** Claude (AI Software Architect)
