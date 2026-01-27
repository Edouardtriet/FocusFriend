# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FocusFriend is a macOS menu bar Pomodoro-style task timer app built with SwiftUI. It allows users to manage up to 3 focus tasks at a time with timer functionality and a floating timer window.

**Platform**: macOS 13.0+
**Language**: Swift/SwiftUI
**Dependencies**: None (uses only Apple frameworks: Foundation, SwiftUI, Combine, AppKit, ServiceManagement)

## Build Commands

```bash
# Build from command line
xcodebuild -scheme FocusFriend -configuration Debug build

# Build and run
xcodebuild -scheme FocusFriend -configuration Debug build && open ./build/Debug/FocusFriend.app

# Or open in Xcode
open FocusFriend.xcodeproj
```

## Architecture

**MVVM Pattern** with three core managers:

- **TaskManager**: CRUD for tasks, max 3 tasks enforced, history tracking, persists to UserDefaults
- **TimerManager**: Combine-based timer (100ms tick rate), handles start/pause/resume/stop/restart
- **SettingsManager**: App preferences, integrates with ServiceManagement for launch-at-login

**Key architectural boundaries**:
- Most of the app is SwiftUI, but `FloatingWindowController` uses AppKit `NSWindow` for the floating timer
- All persistence uses UserDefaults with Codable/JSON serialization
- App runs as menu bar only (LSUIElement=true, no dock icon)

## UserDefaults Keys

- `focusfriend.tasks` - Current task list
- `focusfriend.completedTasks` - Task history
- `focusfriend.settings` - User preferences
- `focusfriend.floatingWindowPosition` - Floating window position

## Design Constants

Located in `Utilities/Constants.swift`:
- Dark theme with cyan accent (#4ECDC4), amber for active (#FFD93D), green for complete (#95D5B2)
- Panel size: 320x400px
- Animation duration: 0.15-0.2s
