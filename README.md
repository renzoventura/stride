# Stride

**Your performance is art. Stride is the brush.**

Transforms Strava API run data into premium, share-ready graphics: choose a run, add data-driven stickers, overlay on a photo, and export to Instagram or your camera roll.

`SwiftUI` `@Observable` `MapKit` `Strava API` `Interactive Photo Editor` `Gestures & Stickers` `async/await` `Keychain` `iOS 26+`

# Stride Demo
https://github.com/user-attachments/assets/33605762-77ba-4292-964b-517586f2a8a4

# Stride Screenshots
<img width="563" height="1218" alt="8" src="https://github.com/user-attachments/assets/6017073e-2c00-4f4a-a265-d0c7abea4cd9" />
<img width="563" height="1218" alt="7" src="https://github.com/user-attachments/assets/97b69dae-2903-4433-8af2-107c11dff4de" />
<img width="563" height="1218" alt="6" src="https://github.com/user-attachments/assets/d42142d5-6f8f-40d5-b5b4-184c88062106" />
<img width="563" height="1218" alt="5" src="https://github.com/user-attachments/assets/08d40b5e-ee57-4b69-a5f3-08e1376b10f4" />
<img width="563" height="1218" alt="4" src="https://github.com/user-attachments/assets/d81e3672-24d0-43b3-9918-661389d1cb1a" />
<img width="563" height="1218" alt="3" src="https://github.com/user-attachments/assets/c7cbf4a3-d53c-41d3-af19-c8ca14acb86c" />
<img width="563" height="1218" alt="2" src="https://github.com/user-attachments/assets/8741b1ef-d779-46ec-a4a3-c6ba29a7297b" />
<img width="563" height="1218" alt="1" src="https://github.com/user-attachments/assets/94c0ff69-9398-48fc-81e1-3c5a22565137" />

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

---

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
