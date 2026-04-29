# QA Release Tracker

A native iOS workflow management application built using the **SwiftUI** framework, developed as part of a QA consulting engagement through **CodeRendering Studio** for **Fusion Systems Inc**.

## What This App Does

QA Release Tracker enables consulting teams to manage tasks, track software deployment releases, and send automated SMS notifications to task owners — all backed by a real-time cloud database.

## Features

- **Dashboard** — live task counts showing total, completed, pending, and overdue items
- **Task Management** — add, edit, delete, and archive tasks with swipe gestures
- **Release Calendar** — deployment releases grouped by month with color-coded status badges
- **Weekly Schedule** — tasks and releases displayed day by day with today highlighted
- **SMS Alerts** — automated text notifications via Twilio when deadlines are missed
- **Authentication** — secure login powered by Supabase Auth
- **Cloud Storage** — real-time Supabase PostgreSQL database with row-level security

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Swift / SwiftUI |
| Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| SMS Notifications | Twilio via Supabase Edge Function |
| Automated Testing | Python + Appium + XCUITest |
| Platform | iOS Simulator (iPhone 16e, iOS 26.2) |

## Project Structure

QAReleaseTracker/
├── QAReleaseTrackerApp.swift   ← App entry point (@main)
├── ContentView.swift           ← 4-tab navigation container
├── Models/
│   ├── AppState.swift          ← Shared state + Supabase API calls
│   └── Task.swift              ← Data models
└── Views/
    ├── AuthView.swift          ← Login and signup
    ├── DashboardView.swift     ← Live counts and navigation
    ├── TasksView.swift         ← Task management
    ├── ScheduleView.swift      ← Weekly calendar
    └── ReleaseCalendarView.swift ← Monthly deployment calendar

## Automated Test Suite

Python-based Appium test suite running against iOS simulator via XCUITest driver.

### Running the Tests

appium
python3 fusion_ios_test.py

## Consulting Context

Built and QA-validated through CodeRendering Studio for Fusion Systems Inc, Oakbrook, IL.

Built by Ahmed Mustafa — Sr. QA Automation Consultant, CodeRendering Studio
