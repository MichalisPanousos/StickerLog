# Mac Setup Guide

This project was scaffolded on a PC (no Xcode available). Follow these steps to open it in Xcode and run it on a simulator or device.

---

## 1. Prerequisites

- **Xcode 16 or later** — download from the Mac App Store or [developer.apple.com/xcode](https://developer.apple.com/xcode). Xcode 16 is required for SwiftData features used here.
- **Git** — comes with Xcode Command Line Tools (`xcode-select --install`).

---

## 2. Clone the repository

```bash
git clone https://github.com/MichalisPanousos/StickerLog.git
cd StickerLog
```

---

## 3. Create the Xcode project

Xcode needs a `.xcodeproj` to build. You cannot open the raw folder directly.

1. Open Xcode → **Create New Project**.
2. Choose **iOS → App** and click Next.
3. Fill in:
   - **Product Name:** `StickerLog`
   - **Team:** your Apple ID (or None for simulator-only)
   - **Organization Identifier:** anything (e.g. `com.yourname`)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (SwiftData is wired manually)
4. **Save the project inside the cloned repo folder** — so the `.xcodeproj` sits alongside `Models/`, `Views/`, etc.

---

## 4. Set the deployment target

In the project navigator, select the **StickerLog** target → **General** tab → set **Minimum Deployments** to **iOS 18.0**.

---

## 5. Remove Xcode's auto-generated files

Xcode creates its own `StickerLogApp.swift` and `ContentView.swift`. Delete them:

1. In the project navigator, select `StickerLogApp.swift` → Delete → **Move to Trash**.
2. Do the same for `ContentView.swift`.

---

## 6. Add the existing source files

Drag the following folders and file from the cloned repo into the Xcode project navigator (onto the `StickerLog` group):

- `Models/`
- `Views/`
- `Helpers/`
- `StickerLogApp.swift` (root level)

When the dialog appears, make sure **"Copy items if needed"** is **unchecked** (the files are already in the project directory) and **"Create groups"** is selected.

---

## 7. Add the photo library usage description

`PhotosPicker` requires a usage description in `Info.plist` or Xcode will reject the build.

1. Select the **StickerLog** target → **Info** tab.
2. Hover over any row and click **+**.
3. Add key: `Privacy - Photo Library Usage Description`
4. Value: `StickerLog uses your photo library to add sticker photos.`

---

## 8. Build and run

Select an **iPhone simulator** (iPhone 16 or similar) from the scheme menu and press **⌘R**.

### Expected first-compile notes

- If Xcode flags `@Model` or `@Query` as unknown, confirm the deployment target is iOS 17+ (step 4). iOS 18 is recommended.
- If you see a "multiple commands produce" or duplicate-file error, check that Xcode's auto-generated files were fully deleted (step 5).
- The `Tab` initializer used in `ContentView` requires iOS 18. If you need to target iOS 17, replace it with `.tabItem { Label(...) }` on each child view.

---

## Architecture invariants

Keep these in mind when extending the app. They are not enforced by the compiler — violating them silently corrupts data.

**`currentUnits` is always the running sum of `LogEntry.quantityChange`**
It is changed only by `Sticker.record(_:type:event:)` (in `Models/Sticker.swift`), which also creates the matching `LogEntry`, never edited directly. Do not add a UI field that writes to `currentUnits` independently.

**Sales snapshot the price at the moment of the transaction**
`LogEntry.priceAtTime` is set to `sticker.unitPrice` when a sale is recorded. Event totals are computed from `priceAtTime`, not from the sticker's current `unitPrice`. This means editing a sticker's price does not retroactively change event revenue figures.

**Corrections never belong to an event**
`LogEntry` entries with `type == .correction` always have `event == nil`. They appear in a sticker's history timeline but must never be attached to an `Event` and must not appear in event detail views.

**Deleting a sticker cascades to its log entries**
The `@Relationship(deleteRule: .cascade)` on `Sticker.logEntries` means SwiftData automatically deletes all associated `LogEntry` records when a sticker is deleted. Do not manually delete log entries before deleting the sticker.
