# SOLID principles in the BCI Management System

This document explains how SOLID was applied when improving the Assignment 01 app.

## Architecture overview

```
UI Screens
    ↓ depends on
Service interfaces (IStudentService, ICourseService, IEnrollmentService)
    ↓ implemented by
Services (StudentService, CourseService, EnrollmentService)
    ↓ depend on
Repository interfaces (IStudentRepository, ICourseRepository, IEnrollmentRepository)
    ↓ implemented by
In-memory repositories (can later be replaced by API/database repositories)
```

`AppContainer` is the **composition root**. It creates concrete repositories and injects them into services. Screens use the container’s service abstractions—not a single monolithic store.

## S — Single Responsibility Principle

Each class has one reason to change:

| Class | Responsibility |
|-------|----------------|
| `StudentService` | Student business rules (add/update/remove + uniqueness) |
| `CourseService` | Course business rules |
| `EnrollmentService` | Enrolment rules and student–course linking |
| `InMemoryStudentRepository` | Persist students only |
| `InMemoryCourseRepository` | Persist courses only |
| `InMemoryEnrollmentRepository` | Persist enrolments only |
| `SeedData` | Demo seed lists only |
| Screens | Presentation / user interaction only |

The old `BciStore` class mixed storage and all business rules. That was split across the classes above.

## O — Open/Closed Principle

Services are **open for extension** and **closed for modification**:

- To use a REST API or database later, create e.g. `ApiStudentRepository implements IStudentRepository`.
- Wire it in `AppContainer` instead of `InMemoryStudentRepository`.
- `StudentService` and the UI do **not** need rewriting.

## L — Liskov Substitution Principle

Any class that implements a repository or service interface can replace the default implementation without breaking callers.

Example: `InMemoryStudentRepository` fulfils every method of `IStudentRepository` with correct behaviour, so `StudentService` can use it wherever `IStudentRepository` is required.

## I — Interface Segregation Principle

Instead of one large “god” store interface, the app uses **small, focused interfaces**:

- `IStudentRepository` / `IStudentService`
- `ICourseRepository` / `ICourseService`
- `IEnrollmentRepository` / `IEnrollmentService`

Clients only depend on the methods they need. For example, enrolment logic does not force a course screen to implement student-persistence methods.

## D — Dependency Inversion Principle

High-level modules depend on abstractions, not concrete classes:

- `StudentService` depends on `IStudentRepository` and `IEnrollmentRepository` (not `InMemory*`).
- `EnrollmentService` depends on all three repository interfaces.
- UI receives services through `AppContainer`, which is constructed in `main.dart`.

This keeps business logic independent of how data is stored.

## Key files to review

| Path | Role |
|------|------|
| `lib/core/interfaces/*.dart` | Abstractions contracts |
| `lib/data/in_memory_*.dart` | Concrete repositories |
| `lib/services/*.dart` | Domain services |
| `lib/app/app_container.dart` | Dependency wiring |
| `lib/main.dart` | App entry / composition root |
| `test/widget_test.dart` | Behaviour tests against services |

## Behaviour unchanged

Student CRUD, course CRUD, enrolment, and “courses assigned to each student” still work the same way in the UI. The change is **structure and design**, not feature removal.
