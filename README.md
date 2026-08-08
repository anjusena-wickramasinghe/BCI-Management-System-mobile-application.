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

## SOLID principles (Assignment 02)

See **[docs/SOLID.md](docs/SOLID.md)** for a full mapping. Summary:

| Principle | How it is applied |
|-----------|-------------------|
| **S**ingle Responsibility | Separate student / course / enrolment services and repositories |
| **O**pen/Closed | New storage (e.g. API) can implement the same repository interfaces without changing services |
| **L**iskov Substitution | In-memory repositories fully implement their interfaces and are interchangeable |
| **I**nterface Segregation | Small interfaces (`IStudentRepository`, `ICourseRepository`, `IEnrollmentRepository`, plus matching services) instead of one fat store |
| **D**ependency Inversion | Services and UI depend on abstractions; `AppContainer` wires concrete classes |

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

## Project structure

```
lib/
  main.dart                      # Composition root entry
  app/app_container.dart         # DI wiring (DIP)
  core/interfaces/               # Abstractions contracts (ISP + DIP)
  data/                          # In-memory repository implementations (LSP + OCP)
  services/                      # Business rules per domain (SRP)
  models/                        # Student, Course, Enrollment
  screens/                       # Home, Students, Courses, Enrol
  widgets/                       # Shared UI helpers
  theme/                         # BCI colour theme
docs/
  SOLID.md                       # SOLID explanation for reviewers
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
