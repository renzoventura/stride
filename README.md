# Stride

**Your performance. Beautifully presented.**

Every runner is an artist. Every run a canvas. Stride is just the brush.

https://github.com/user-attachments/assets/0beaf45c-fbfe-4d19-985d-9008ee2cae51

---

## What is Stride?

Stride connects to Strava, pulls your run data, and transforms it into premium share-ready graphics.

Pick a run. Choose a photo. Add data-driven stickers — distance, pace, time, location, PRs — styled with intention. Export to your camera roll or share directly to Instagram Stories.

No tracking. No dashboards. No noise.
Just your performance, presented the way it deserves.

---

## Features

### Strava Integration

- OAuth sign-in — no separate account
- Automatic run feed with infinite scroll
- Real data: distance, pace, time, location, route maps

### Photo Editor

- Full-screen zoomable, pannable canvas
- Pinch to zoom, drag to reposition
- Stickers can be dragged freely — including off-edge for creative compositions
- Export matches what you see, pixel for pixel

### Data-Driven Sticker System

25 distinct sticker layouts across 7 categories:

- **Big Metric** — Hero numbers with supporting details
- **Bars & Strips** — Compact horizontal performance strips
- **Badges** — Rounded, centered compositions with labels
- **Editorial** — Structured label-over-value hierarchy
- **Compositions** — Asymmetric layouts with visual tension
- **Minimal & Special** — Clean single-metric and location stickers
- **PR Celebration** — Six dedicated layouts for personal records

Every sticker is dynamically populated from the selected run.

### Sharing

- **Instagram Stories** — One tap. Canvas exports to pasteboard, Instagram opens with the image as your story background.
- **Save** — Export to photo library at display scale
- **Share** — System share sheet for any destination

### Design System

- Dark theme with strong orange accent
- Centralized color, typography, spacing, and corner radius tokens
- Four reusable button styles: Accent, Accent Outline, Ghost, Floating Circle
- Custom display fonts: Humane Bold, ROUND8-FOUR
- Built for future light mode

---

<<<<<<< HEAD
=======
## Philosophy

Runners create meaning through effort.

The distance, the pace, the time — these aren't just numbers.
They're evidence of discipline. Of showing up. Of pushing through.

Data deserves presentation.
Performance is personal.
Design amplifies achievement.

Stride exists because the work was already done.
It just needed a frame.

---

>>>>>>> ff03bfc (Rename project from LastK to Stride)
## Tech Stack

### Architecture

View-centric SwiftUI with `@Observable` services. Views own transient state. Observable classes manage shared and persistent state. No third-party dependencies.

### State Management

| Layer | Mechanism |
|---|---|
| Auth & session | `@Observable` `StravaSession`, injected via `.environment()` |
| Feed | `@Observable` `RunFeedViewModel` with pagination |
| Photo library | `@Observable` `PhotoLibraryService`, local to picker |
| Canvas | `@State` arrays and bindings, local to editor |

### Networking

- Raw `URLSession` with `async/await`
- Static API clients (`StravaAuthService`, `StravaAPIClient`)
- OAuth2 with automatic token refresh via Keychain

### Strava API

- `ASWebAuthenticationSession` for OAuth login
- Secure token storage in Keychain (`StravaTokenStore`)
- Activity feed with polyline decoding for MapKit route rendering
- In-memory map snapshot cache to prevent scroll jitter

### Sticker Engine

```
RunFeedItem
  → .stickerData (immutable snapshot)
    → StickerLayoutType.allCases.filter(isAvailable)
      → StickerLayoutRouter (switch → view)
        → StickerOverlayView (drag, pinch, animate)
          → StickerDrawingView (export)
```

Adding a new sticker: add a case to the enum, create the view, register in the router. The picker, canvas, and export pipeline adapt automatically.

### Design Tokens

All visual constants live in `AppTheme.swift`:

- `AppColors` — backgrounds, text, accent, utility
- `AppFont` — metric, header, body, metadata, button
- `AppSpacing` — xs through xxl
- `AppRadius` — sm, md, lg, card

---

## Project Structure

```
Stride/
├── Strava/              Auth, API client, token store, models
├── Feed/                Run feed, cards, map snapshots, polyline decoder
├── Profile/             Athlete display
├── Login/               Strava OAuth screen
├── BackgroundSelection/ Photo picker, editor, canvas, export
│   └── StickerLayouts/  25 layout views, data model, router, PR system
├── Theme/               Design system
└── Resources/Fonts/     Humane-Bold, ROUND8-FOUR
```

---

## Requirements

- iOS 26+
- Strava account
- Photo library access

---

<<<<<<< HEAD
*LastK — because the run was the hard part.*
=======
## Secrets

Strava client ID and secret are never committed. They are read at runtime from environment variables (`STRAVA_CLIENT_ID`, `STRAVA_CLIENT_SECRET`) or a local `.xcconfig` added to `.gitignore`.

---

*Stride — because the run was the hard part.*
>>>>>>> ff03bfc (Rename project from LastK to Stride)
