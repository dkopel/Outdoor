# Outdoor — iOS App

Phase 2 of the Outdoor build plan: an iOS shell that loads the bundled
**Camping** pack and lets you ask questions with real keyword retrieval
against the on-device FTS5 index. No LLM yet — that's Phase 3.

## Open in Xcode

The Xcode project is generated from [`project.yml`](./project.yml) using
[XcodeGen](https://github.com/yonaskolb/XcodeGen). Install once:

```bash
brew install xcodegen
```

Then from the `app/` directory:

```bash
cd app
xcodegen generate
open Outdoor.xcodeproj
```

That's it. Hit ⌘R to run on a simulator (iPhone 15 Pro recommended). Minimum
target is iOS 17.

> 🛟 Don't want to install XcodeGen? Create a new "App" project in Xcode
> with the name **Outdoor**, delete the boilerplate files, and drag the
> contents of [`Outdoor/`](./Outdoor) into the project. Add
> [`Outdoor/Resources/Packs`](./Outdoor/Resources/Packs) as a **folder
> reference** (blue folder, not yellow group) so the SQLite file is
> bundled correctly.

## What's inside

```
Outdoor/
├── App/                      Entry, root nav, app state
├── Design/                   Tokens, components, design system
├── Features/
│   ├── Chat/                 Conversational Q&A with citation chips
│   ├── Catalog/              Pack list (camping installed + future packs)
│   ├── Emergency/            Big-button emergency mode (locked procedures)
│   ├── Guide/                Browse by domain (first-aid, knots, water, …)
│   ├── Onboarding/           First-launch + "verify offline" gate
│   └── Settings/             Storage, accessibility, about
├── Core/
│   ├── Packs/                PackManager, PackInstaller, Pack models
│   ├── Retrieval/            FTS5 keyword search, hybrid ranker stub
│   ├── Safety/               Intent routing + locked procedures
│   └── Storage/              Raw SQLite C-API wrapper
└── Resources/
    ├── Assets.xcassets       Colors, app icon
    └── Packs/                Bundled .trailpack contents (camping/)
```

## Design language (short version)

- **Palette**: warm dawn / forest / ember accent (no kelly-green REI cliché)
- **Type**: SF Pro Display, generous sizes
- **Materials**: native iOS blurs, soft shadows, no gradients-on-gradients
- **Density**: airy. Touch targets sized for cold hands and wet fingers
- **Motion**: soft springs, no bounce, no flair
- **Citations**: first-class — chips with publisher attribution, tap to expand

See [`Outdoor/Design/`](./Outdoor/Design) for tokens + components.

## Roadmap

This shell is Phase 2 of [the plan](../docs/plan.md). Coming next:

- **Phase 3**: MLX-Swift on-device LLM, prompt builder, streaming answers
- **Phase 4**: Safety routing + emergency mode hardening + content expansion
- **Phase 5**: Beta + field test
- **Phase 6+**: Hiking / fishing packs, Android port, offline maps
