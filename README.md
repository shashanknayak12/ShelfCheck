# ShelfCheck

A shift handover app for retail staff log expiry checks per shelf section and pass clear notes to the next shift, so nobody has to guess what's already been done.

## Domain

At a servo (convenience store), 5 casual staff rotate shifts with no shared record of what is been checked. Expiry checks are currently done manualy and logged on paper, which gets lost after a few months, forcing the whole check to start over. This leads to expired stock staying on shelves like chocolate, gum, and drinks sections have all had products found with expiry dates already passed, sometimes hidden at the back of the shelf behind fresher stock at the front.

**Persona:** Jordan, 25, casual servo worker. Currently relies on paper logs and verbal handovers between shifts.

## Screens

1. **Shift Start** — pick your name, see the previous shift's handover notes, and today's outstanding vs. completed checks
2. **Checklist** — log an expiry check per shelf section (dairy, hot food, drinks, chocolate, gum), the expiry date you read off the product decides fresh / near expiry / expired automatically
3. **Handover** — write a note for the next shift, optionally flagged to a specific section
4. **Manager Dashboard** Has pin (1234), see every shift's compliance status (done / in progress / missed), with a drill down into each shift's checks and notes

## Architecture

```
SwiftUI Views
ViewModels 
Use Case Layer
Domain Models + Repositories
```

**Use Cases:**

- `LogExpiryCheckUseCase` — a shelf section can only be checked once per shift and classifies fresh/near-expiry/expired from the expiry date entered
- `SubmitHandoverNoteUseCase` — a handover note can not be blank and must reference a real shift
- `ReviewShiftComplianceUseCase` — a shift only counts as complete once all 5 categories have been checked

**Data layer:** in-memory repository (`InMemoryShelfCheckStore`) no backend for this MVP, data resets on app relaunch.

## Project structure

```
ShelfCheck/
  Models/          domain models (StaffIdentifier, Shift, ProductCategory, ExpiryStatus, ExpiryCheckRecord, ShiftHandoverNote)
  Repositories/     repository protocols + in-memory implementation
  UseCases/         the 3 Use Cases and their typed error enums
  ViewModels/       one per screen, plus ShiftSession for shared shift state
  Views/            the 6 SwiftUI screens
ShelfCheckTests/    13 unit tests across the 3 Use Cases
```

## Setup

1. Clone the repo and open `ShelfCheck.xcodeproj` in Xcode 16 or later
2. Select an iOS simulator and press `Cmd+R` to run
3. Press `Cmd+U` to run the test suite
5. Password to view manager dashboard: **`1234`**

No external dependencies, no backend setup required the app runs entirely against seeded in memory data.
