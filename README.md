# Freelance Opportunity Tracker

An offline-first Flutter app for organizing a personal shortlist of freelance opportunities.

**Portfolio sample:** prepared for Ghaya with AI assistance. It uses demonstration records only. It does not connect to freelance marketplaces, scrape listings, submit proposals, sync data to a server, or train a model.

## Features

- Create, edit, search, filter, and archive opportunity records.
- Track saved leads, applications, interviews, and archived items with live counts.
- Keep notes, budget, source link, platform, and status together in one view.
- Store records locally as JSON through `shared_preferences`.
- Use responsive one- and two-column layouts and clear empty, validation, loading, and storage-error states.

## Data and privacy

The app stores records in the device's standard application preferences. It has no backend or marketplace integration, and the stored data is not encrypted. Avoid entering sensitive personal, account, or client information. Clearing app data or uninstalling the app can remove records.

## Project structure

- `lib/domain` — opportunity model.
- `lib/data` — local persistence repository.
- `lib/features/opportunities` — screens, editor, and view model.
- `android/` and `web/` — Flutter platform scaffolding.

## Run locally

Requirements: Flutter 3.16.9 or newer, Dart 3.2.6 or newer, and the Android SDK for Android builds.

    flutter pub get
    flutter run

No API keys or backend account are needed. Android package identity and release signing remain demo placeholders; this repository does not claim an app-store or production release.

## Verification and limitations

Dart formatting was applied to the updated source files. Static analysis did not complete during preparation, so no analyzer pass or automated test result is claimed. Review the project in your local Flutter environment before using it in a release.

This is a portfolio demonstration, not a production job-search service. No license is included; review source, dependencies, and ownership before redistribution.

## Attribution

Prepared for Ghaya with AI assistance. No model was trained as part of this project.
