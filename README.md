# MachineShop

An iOS app (Swift, SwiftUI, Xcode) for a machine shop. The secretary records job
orders with a photo, customer details and a price, and assigns tasks to workers by
specialty (reboring, resurfacing, torno, welding). Workers see their tasks and mark
them done, which updates the secretary in real time. Data and login live in Supabase;
SwiftData keeps an offline copy of the last-loaded lists.

## Screens

| Screen | Who | File |
|---|---|---|
| Login | everyone | `Views/Auth/LoginView.swift` |
| Job list | secretary | `Views/Secretary/SecretaryHomeView.swift` |
| New job order | secretary | `Views/Secretary/JobFormView.swift` |
| Job details | secretary | `Views/Secretary/JobDetailView.swift` |
| History (finished jobs) | secretary | `Views/Secretary/SecretaryHistoryView.swift` |
| My tasks | worker | `Views/Worker/WorkerHomeView.swift` |
| Task details | worker | `Views/Worker/TaskDetailView.swift` |
| History (finished tasks) | worker | `Views/Worker/WorkerHistoryView.swift` |
| Profile (role, email, log out) | everyone | `Views/Profile/ProfileView.swift` |

The login screen has a **Forgot password?** button that tells users to contact the office so the admin can change their password (accounts are admin-managed, so there is no email reset).

Navigation: login routes by role to a tab bar (Jobs/Tasks + Profile); list rows push a
details screen; the secretary's + button opens the new-job form as a sheet.

## Architecture: MVC

| Layer | Folder | Responsibility |
|---|---|---|
| **Model** | `Models/` | Data types that mirror the Supabase tables (`Models.swift`, `TaskDraft.swift`) and the SwiftData offline cache (`CachedSnapshot.swift`, `CacheStore.swift`) |
| **View** | `Views/`, `Components/` | SwiftUI screens and reusable pieces. Views never talk to the database. |
| **Controller** | `Controllers/` | `ObservableObject` classes that talk to Supabase, hold screen state and handle user actions (`AuthController`, `SecretaryJobsController`, `WorkerTasksController`, ...) |

`App/` holds the app entry point and the Supabase client.

## Setup

1. Add the `supabase-swift` package (File > Add Package Dependencies).
2. Put your project URL and anon key in `App/SupabaseManager.swift`.
3. Run `supabase/schema.sql` in the Supabase SQL Editor (tables, row level security, trigger, storage bucket).
4. Create users in Supabase Authentication and add a matching row in `profiles`.
