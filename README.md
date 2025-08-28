# InventoryManager (Scanventory)

InventoryManager is a modern **iOS app built with SwiftUI** that allows users to **scan QR codes**, manage them via a **local Core Data database**, and seamlessly **sync results to Google Sheets**.  
It also includes a flexible **settings system** where scanning rules, parsing delimiters, and spreadsheet destinations can be customized.

---

## Functionalities

- **Live QR Code Scanning** using `AVFoundation`
- **Photo Picker** — decode QR codes from existing images
- **Google Sheets Integration** via Google APIs (Sheets, Drive, Auth)
- **Offline-first persistence** with Core Data
- **Customizable settings**
  - Spreadsheet selection
  - Scanning behavior (e.g. result screen on/off, auto-save)
  - QR code parsing rules (delimiter, acceptance text)
-  **Developer-friendly UX**
  - Toast notifications
  - Loading overlays with animated SF Symbols
  - Modern SwiftUI design, edge-to-edge gradients

---

## Architecture Overview

The project is structured according to **MVVM + Services + Protocol-oriented DI**:

### Folder Structure
- **Constants** — app-wide constants (colors, Google keys, UserDefaults keys)
- **Errors** — strongly-typed error enums (`GoogleAuthError`, `QrCodeError`, etc.)
- **Model** — core data models & domain entities (`GoogleSpreadsheet`, `QRCodeResult`)
- **Protocols** — dependency injection boundaries (`QRScanning`, `SelectionProvider`, `DatabaseProvider`, etc.)
- **Services**
  - `GoogleServices` — authentication & spreadsheets API
  - `QRScannerService` — wraps AVFoundation camera session
  - `DatabaseService` — Core Data persistence
  - `SelectionService` — manages user spreadsheet/sheet selections
- **ViewModels** — one per feature screen (`ScannerViewModel`, `ScanHistoryViewModel`, `SettingsViewModel`, etc.)
- **Views**
  - **Scanning** — camera preview, stream, picker
  - **History** — scan history, detail view
  - **Settings** — QR code settings, scan settings, spreadsheet settings
- **ViewComponents** — reusable SwiftUI components (cards, toasts, loading overlay)

### Design Patterns & Methodologies
- **MVVM** — clear separation of concerns between `View`, `ViewModel`, and `Service`
- **Dependency Injection** — all services are injected via **protocols** (`QRScanning`, `GoogleSpreadsheetWriter`, etc.)
- **Protocol-Oriented Programming** — abstractions for persistence, scanning, and settings
- **Single Source of Truth** — state stored in ViewModels or SettingsStores, published via Combine
- **Environment Objects** — propagate shared stores across the view hierarchy
- **Async/Await + Combine** — modern concurrency & reactive pipelines

---

## Modern iOS Concepts Used

- **SwiftUI-first architecture**
  - `NavigationStack`, `.sheet(item:)`, `.alert(item:)`
  - `@StateObject`, `@EnvironmentObject`, `@ObservedObject`
- **Structured Concurrency**
  - `async/await`, `Task`, `withCheckedThrowingContinuation`
- **Combine Interop**
  - Service publishers bridged into `@Published` ViewModel state
- **Core Data**
  - `@FetchRequest`, data grouping by date for history
- **AppStorage**
  - lightweight UserDefaults integration for settings
- **Protocol-driven testing**
  - mock implementations of `QRScanning`, `GoogleSheetWriting`, `QRCodeSettingsProviding`
- **UI Polish**
  - SF Symbols with `.symbolEffect()`
  - Animated Toasts and Loading overlays
  - Safe area–aware buttons & layouts

---

## Testability
- ViewModels are tested by injecting **fake services** (e.g., `FakeQRScannerService`).
- Pure parsing functions for QR logic (delimiter, acceptance text) allow unit testing without UI.
- Mock persistence and settings stores enable snapshot-style testing of app flows.

---

## License
MIT
