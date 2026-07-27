# BCI Management System (Flutter)

Mobile-friendly Flutter app for managing **students**, **courses**, and **enrolments** at BCI.

Data is stored in memory for demonstration. Closing the app clears newly entered records.

## Features (clearly defined)

### 1. Student management
| Action | How to use |
|--------|------------|
| **View** | Open the **Students** tab, or tap a student row / choose **View** |
| **Add** | Tap **Add Student**, fill the form, tap **Save** |
| **Edit** | Choose **Edit** on a student, or use the edit icon on the detail page |
| **Delete** | Choose **Delete** and confirm |

On a student detail page you also see **Assigned courses** for that student.

### 2. Course management
| Action | How to use |
|--------|------------|
| **View** | Open the **Courses** tab, or tap a course row / choose **View** |
| **Add** | Tap **Add Course**, fill the form, tap **Save** |
| **Edit** | Choose **Edit** on a course, or use the edit icon on the detail page |
| **Delete** | Choose **Delete** and confirm |

On a course detail page you also see **Enrolled students**.

### 3. Enrolment
| Action | How to use |
|--------|------------|
| **Enrol** | Open **Enrol** → **Enrol Student** → pick student + course → **Enrol** |
| **View enrolments** | List on the **Enrol** tab (searchable) |
| **See courses per student** | Open a student → **Assigned courses** |
| **Unenrol** | On Enrol tab, or remove a course from the student detail page |

Duplicate enrolments (same student + same course) are blocked.

## App navigation

- **Home** — summary counts and short guide  
- **Students** — student CRUD + assigned courses  
- **Courses** — course CRUD + enrolled students  
- **Enrol** — link students to courses  

## Run the app

```bash
cd bci_management_system
flutter pub get
flutter devices
flutter run
```

Useful targets:

```bash
flutter run -d windows
flutter run -d chrome
flutter run                 # phone / emulator
```

If you see an old red error screen in the browser, close that tab and run again on a fresh device/port.

## Project structure

```
lib/
  main.dart                 # App entry
  models/                   # Student, Course, Enrollment
  state/bci_store.dart      # In-memory data + business rules
  screens/                  # Home, Students, Courses, Enrol
  widgets/                  # Shared UI helpers
```

## Validation rules

- Required fields must not be empty  
- Email must contain `@`  
- Course credits must be a positive whole number  
- Student ID / course code must be unique when adding  
- A student cannot be enrolled in the same course twice  

## Tests

```bash
flutter test
dart analyze lib test
```
