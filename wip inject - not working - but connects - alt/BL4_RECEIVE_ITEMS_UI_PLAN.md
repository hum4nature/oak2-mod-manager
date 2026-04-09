# BL4 Receive Items UI Plan

## Goal

Build a local, BL3-style "Receive Items" experience for Borderlands 4 where a user can:

1. Launch a local helper.
2. Open a local browser page.
3. Paste one or more `@U...` serial codes.
4. Click a button.
5. Have those items appear live in the in-game backpack.

This should feel similar to the old BL3 Hotfix WebUI "Receive Items" tab, but the BL4 implementation will use live memory injection instead of BL3 mail/hotfix delivery.

## Product Shape

The intended user experience is:

1. User runs `BL4_Injector.exe` as Administrator.
2. The injector starts a local-only server on `127.0.0.1`.
3. The injector optionally opens the browser automatically to a local page.
4. User pastes one or more `@U...` codes into a "Receive Items" page.
5. User clicks `Inject` or `Inject All`.
6. The local helper injects the items into the live BL4 backpack.
7. The page shows success, errors, and current connection status.

This tool should work fully locally. No public site dependency should be required for the core flow.

## Non-Goals For V1

- No `oak2-mod-manager` integration yet.
- No full item editor UI.
- No full inventory manager.
- No advanced save editing in this screen.
- No remote hosting requirement.
- No replacement for the core injector logic.

## Sources And Reference Materials

This plan is based on:

- the current BL4 injector source files in this repo
- the current BL4 injector markdown notes in this repo
- the current web integration files in this repo
- the BL3 "Receive Items" browser workflow as the conceptual UI target

### External Conceptual Reference

#### BL3 Hotfix WebUI "Receive Items"

Conceptual source:

- `https://github.com/c0dycode/BL3HotfixWebUI/wiki/Receive-Items`

Why it matters:

- It is the clearest reference for the user experience we want to mimic.
- It shows a browser page where users paste serial numbers, manage a list, and receive items through a local helper/mod path.
- It is useful as a UI model even though the BL4 implementation will use direct backpack injection instead of BL3's mail delivery flow.

Important conceptual difference:

- BL3 "Receive Items" exposed items via the in-game mail window after the helper/mod pipeline processed them.
- BL4 will instead inject items directly into the live backpack array in memory.

### Core BL4 Injector Source Files

#### `injector/bl4_app.py`

Primary source for current live injection behavior.

Why it matters:

- contains the `GameState` class
- attaches to the game process
- resolves `GEngine`
- resolves `PlayerState`
- reads backpack contents
- injects a single serial
- injects batches of serials
- includes current drop helpers
- shows the current WebSocket-facing command surface

#### `injector/bl4_scanner.py`

Primary source for low-level memory logic.

Why it matters:

- process discovery
- memory read/write helpers
- PE section parsing
- pointer walking
- array allocation helpers
- backpack layout assumptions
- item slot size and field layout assumptions

#### `injector/find_gengine_direct.py`

Primary source for current `GEngine` discovery.

Why it matters:

- implements the current scan-based `GEngine` lookup
- validates candidates through the live backpack pointer chain
- is required context for reliable attach and injection behavior

### Secondary BL4 Injector Source Files

#### `injector/bl4_bridge.py`

Useful as an alternate or older bridge implementation.

Why it matters:

- documents the current bridge action model
- shows the existing browser-to-helper message flow
- helps if we keep WebSocket or want to map it to a local HTTP API

Caveat:

- it should not be treated as the main architectural foundation because it duplicates lower-level logic and is less clean than `bl4_app.py`

#### `injector/loot_lobby.py`

Useful for understanding broader injection capabilities.

Why it matters:

- shows that the injector logic can target more than a single local backpack write
- helps inform possible future API capabilities

#### `injector/loot_drop.py`

Useful for understanding inject-then-drop workflows.

Why it matters:

- demonstrates batch injection followed by player-facing drop behavior
- useful for future adjacent UX even though it is not required for Receive Items V1

#### `injector/dump_all.py`

Useful for backpack reading and dump-related behavior.

Why it matters:

- helps with possible later "read backpack" or "dump inventory" features

### Important Markdown Context In This Repo

#### `injector/README.md`

Important operational context.

Why it matters:

- explains current injector behavior
- documents current offsets
- documents update and troubleshooting steps after BL4 patches
- identifies which injector files currently own which responsibilities

#### `injector/IMPLEMENTATION_PLAN.md`

Important product-shape and packaging context.

Why it matters:

- documents the intended desktop-app vision
- documents the current WebSocket bridge concept
- documents packaging expectations such as PyInstaller
- helps explain how the current project imagined the local EXE flow

### Future Alternative Delivery Path Reference

#### `Backpack Item Importer/Matt MBs Reward management.txt`

Useful as future research in addition to the current live backpack injection method.

Why it matters:

- it suggests BL4 may expose reward-grant behavior through game-side runtime functions
- it references reward-related calls such as `GiveReward`, `GiveRewardAllPlayers`, and package-based reward delivery
- it may become useful later if the project explores a more native SDK/mod-based delivery path instead of or alongside direct memory injection

How to treat it:

- not a primary source for Receive Items V1
- not a replacement for current `@U...` backpack injection
- useful as a future alternative delivery path in addition to the current method

### Current Web Integration Sources

#### `web/src/lib/injectorBridge.ts`

Primary source for the current browser-side transport contract.

Why it matters:

- documents the current actions:
  - `attach`
  - `status`
  - `read_backpack`
  - `inject`
  - `batch_inject`
  - `drop_all`
- shows status transitions expected by the UI
- helps if we translate the current WebSocket model to a local HTTP API

#### `web/src/components/InjectorSetupModal.tsx`

Primary source for current injector onboarding UX.

Why it matters:

- shows how the web app explains setup to users
- shows existing assumptions:
  - Windows only
  - Administrator rights
  - local helper process
  - localhost-only communication
- useful for instructional copy and setup flow

#### `web/public/downloads/BL4_Injector.exe`

Current packaged artifact location.

Why it matters:

- shows where the final helper binary is currently hosted for download
- useful for packaging and distribution context

Caveat:

- this is a build artifact, not source

## Architecture

### Core Principle

HTML/JS alone cannot inject into the BL4 process. A local helper is always required to do process attach, memory scanning, and backpack writes.

The correct split is:

- Local UI: browser page running from local host.
- Local backend: helper process exposing a local API.
- Injector core: Python memory logic that attaches to BL4 and injects items.

### Proposed Layers

1. `injector core`
   Handles:
   - process attach
   - `GEngine` discovery
   - `PlayerState` and backpack resolution
   - backpack reading
   - single inject
   - batch inject
   - optional drop helpers

2. `local server`
   Handles:
   - serving the local UI
   - exposing local-only API endpoints
   - status reporting
   - request validation

3. `receive items ui`
   Handles:
   - serial input
   - queue/list management
   - connection status
   - command buttons
   - result log

## Recommended Runtime Model

### Preferred V1

Run one local process that:

1. Starts the injector backend.
2. Serves the local HTML page.
3. Exposes API routes on the same local host.

Example:

- UI: `http://127.0.0.1:27015/`
- API: `http://127.0.0.1:27015/api/*`

This is better than opening a raw `file:///` HTML page because:

- browser security behavior is more predictable
- no CORS issues between file origin and local API
- packaging is easier later
- one port and one process is simpler to explain

### Acceptable Alternative

Keep the current WebSocket model for compatibility:

- UI: `http://127.0.0.1:8080/receive-items.html`
- backend: `ws://127.0.0.1:27015`

This works, but for a dedicated local Receive Items tool, local HTTP is simpler than a custom WebSocket protocol.

## Transport Options

### Option A: Keep WebSocket

Pros:

- Reuses existing `injectorBridge.ts` ideas.
- Supports live status push naturally.
- Requires less change if current injector already speaks WebSocket.

Cons:

- More awkward for a tiny standalone page.
- Harder to debug than explicit HTTP routes.
- Message protocol is more ad hoc.

### Option B: Local HTTP API

Pros:

- Simple to reason about.
- Easy to call from plain HTML/JS.
- Easier to debug in the browser dev tools.
- Easier to document.

Cons:

- Status updates may require polling unless SSE or WebSocket is added later.

### Recommendation

For this Receive Items project, use local HTTP for commands first.

If needed later:

- add polling for status, or
- add a small WebSocket channel only for live events

## UI Scope For V1

The page should intentionally be narrow and focused.

### Main Functions

1. Add one serial code.
2. Paste many serial codes at once.
3. Show a queue/list of pending items.
4. Remove selected entries.
5. Clear all entries.
6. Inject one selected item.
7. Inject all items.
8. Show local connection and game status.
9. Show recent success/error messages.

### Nice-To-Have But Not Required In V1

- Save/load queue from a local text file.
- Copy export list.
- Read backpack and display count.
- Auto-remove successful items from queue.
- Per-item labels or notes.

## UX Specification

### Layout

Single-page layout modeled after the BL3 receive-items concept:

1. Top status bar
   - helper status
   - game status
   - attach status
   - backpack summary

2. Main list panel
   - scrollable queue of serials
   - optional per-row status

3. Serial input row
   - textbox
   - `Add` button
   - `Delete Selected` button

4. Batch input area
   - multiline textarea
   - `Add Pasted Lines` button

5. Action row
   - `Inject Selected`
   - `Inject All`
   - `Clear List`
   - optional `Read Backpack`

6. Log panel
   - recent actions
   - errors
   - attach info

### Status States

The UI should clearly distinguish these states:

- backend offline
- backend online, game not found
- backend online, game found, not fully attached
- backend online, attached, backpack ready
- inject in progress
- inject success
- inject failed

### Validation Rules

When adding serials:

- trim whitespace
- ignore blank lines
- only accept strings starting with `@U`
- de-duplicate exact duplicates in the queue if desired
- show invalid line count when batch pasting

When injecting:

- refuse if backend is offline
- refuse if game is not attached
- refuse empty queue
- show per-item error for invalid serials

## API Specification

### Recommended HTTP Endpoints

#### `GET /api/status`

Returns backend and game state.

Example response:

```json
{
  "ok": true,
  "backend": "online",
  "game_found": true,
  "attached": true,
  "gengine": "0x1234567890",
  "backpack_count": 127,
  "backpack_max": 144,
  "backpack_max_size": 144
}
```

#### `POST /api/attach`

Attempts to attach to BL4 and resolve backpack state.

Example response:

```json
{
  "ok": true,
  "attached": true,
  "pid": 12345,
  "gengine": "0x1234567890"
}
```

#### `POST /api/inject`

Injects a single serial.

Request:

```json
{
  "serial": "@U..."
}
```

Response:

```json
{
  "ok": true,
  "slot": 128,
  "message": "Injected to slot 128"
}
```

#### `POST /api/batch-inject`

Injects many serials.

Request:

```json
{
  "serials": ["@U...", "@U..."]
}
```

Response:

```json
{
  "ok": true,
  "injected": 25,
  "message": "Injected 25 items"
}
```

#### `GET /api/backpack`

Returns current backpack summary and optionally item list.

#### `POST /api/drop-all`

Optional, not required for V1 receive-items.

## Current Code Reuse

### Best Reuse Candidates

#### `injector/bl4_app.py`

Most useful current base because it already contains:

- `GameState`
- attach flow
- backpack read flow
- single injection
- batch injection
- optional drop support

This file should become the source for extracting a real reusable service layer.

#### `injector/bl4_scanner.py`

Best source for:

- process attach helpers
- memory read/write helpers
- PE parsing
- pointer chain walking
- array allocation helpers

#### `injector/find_gengine_direct.py`

Best source for:

- current `GEngine` auto-discovery logic
- runtime scan/validation assumptions

### Files That Help But Should Not Be The Main Foundation

#### `injector/bl4_bridge.py`

Useful as protocol inspiration, but not ideal as the main backend because it duplicates lower-level logic and appears older and less complete than `bl4_app.py`.

#### `web/src/lib/injectorBridge.ts`

Useful as a reference for UI-to-backend commands and status handling. Good input for endpoint naming and UI state changes.

#### `web/src/components/InjectorSetupModal.tsx`

Useful only for setup/onboarding ideas. Not core to the local Receive Items tool.

#### `web/public/downloads/BL4_Injector.exe`

This is a hosted build artifact, not source. It does not help define architecture except as a packaging target.

## Proposed Refactor Layout

Recommended file layout for the new local tool:

```text
injector/
  core/
    constants.py
    scanner.py
    service.py
    models.py
  server/
    app.py
    routes.py
  static/
    receive-items.html
    receive-items.css
    receive-items.js
  launcher.py
```

### Responsibilities

#### `injector/core/constants.py`

- all known offsets
- item slot size
- memory structure constants
- retry limits

#### `injector/core/scanner.py`

- process discovery
- read/write helpers
- `GEngine` scan
- pointer walk helpers

#### `injector/core/service.py`

- `attach()`
- `status()`
- `read_backpack()`
- `inject(serial)`
- `batch_inject(serials)`

This is the most important boundary.

#### `injector/server/app.py`

- local HTTP server entrypoint
- static file serving
- API registration

#### `injector/server/routes.py`

- `/api/status`
- `/api/attach`
- `/api/inject`
- `/api/batch-inject`
- `/api/backpack`

#### `injector/static/receive-items.html`

- the dedicated BL3-style receive-items page

#### `injector/static/receive-items.js`

- queue logic
- form validation
- fetch requests
- UI status rendering

#### `injector/static/receive-items.css`

- visual layout and styling

#### `injector/launcher.py`

- starts local server
- optionally opens browser
- optionally retries attach in background

## Suggested V1 Interaction Flow

1. User launches helper.
2. Helper starts local server.
3. Helper opens browser to local page.
4. UI polls `/api/status`.
5. If game not attached, UI shows "Waiting for BL4".
6. User pastes serials into textarea.
7. User clicks `Add`.
8. Queue populates.
9. User clicks `Inject All`.
10. UI sends `POST /api/batch-inject`.
11. Backend injects serials into backpack.
12. UI shows result and refreshes status.

## Detailed V1 UI Behavior

### Add One Serial

1. User types one `@U...` code.
2. Clicks `Add`.
3. If valid, row is appended to the list.
4. If invalid, show inline error.

### Add Many Serials

1. User pastes many lines into textarea.
2. Clicks `Add Pasted Lines`.
3. Each valid `@U...` line becomes a row.
4. Invalid lines are rejected and counted.

### Inject Selected

1. User selects one row.
2. Clicks `Inject Selected`.
3. UI calls single-item endpoint.
4. UI marks the row success or failure.

### Inject All

1. User clicks `Inject All`.
2. UI sends queue to batch endpoint.
3. Backend injects in order.
4. UI shows count injected and any failures.

### Refresh Status

UI should poll every 2 to 5 seconds for:

- backend availability
- game attach state
- backpack count

## Error Cases To Handle

### Backend Not Running

Show:

- "Local helper not running"
- instructions to start `BL4_Injector.exe`

### Game Not Running

Show:

- "Borderlands 4 not found"

### In Main Menu / PlayerState Missing

Show:

- "Game found, but character/backpack not ready. Load into a character."

### Backpack Resolution Failure

Show:

- "Could not find backpack. Offsets may be outdated."

### High Backpack Count

If backpack count is already very high:

- show count in status
- inject as normal if backend allows it
- surface backend warnings if resize occurs

### Batch Partial Failure

If only some items inject:

- report total requested
- total injected
- first failure reason

## High Backpack Count Notes

This UI does not solve high-count behavior by itself. The backend still owns safety checks.

The backend should:

- read `count`, `max`, and `max_size`
- warn when backpack count is abnormally high
- log when array extension occurs
- refuse only when injection would be clearly unsafe or blocked by current guards

UI can display:

- current count
- current max
- warning badge if count is above a threshold such as 200 or 300

## Logging

The backend should log:

- startup
- attach attempts
- attach success
- `GEngine` resolution
- backpack counts
- inject requests
- batch request sizes
- memory resize actions
- failures

The UI log panel should show:

- last attach result
- last inject result
- last batch inject result
- last error

## Packaging Plan

### Dev Mode

Run a local Python server directly.

### Packaged Mode

Package a single executable that:

- contains or ships with the static UI
- starts the local server
- optionally opens browser automatically

### Build Target

Short-term target remains:

- `BL4_Injector.exe`

But the packaged app should now be:

- backend + local UI host
- not just a bridge for a remote website

## Proposed Implementation Phases

### Phase 1: Core Cleanup

1. Extract reusable service from `bl4_app.py`.
2. Centralize offsets/constants.
3. Remove duplicated bridge logic.

### Phase 2: Local API

1. Add local HTTP server.
2. Add `status`, `attach`, `inject`, `batch-inject`, `backpack` endpoints.
3. Add basic JSON validation and logging.

### Phase 3: Receive Items Page

1. Build local HTML page.
2. Add queue UI.
3. Add status polling.
4. Add single and batch inject buttons.

### Phase 4: Integration

1. Serve the page from the local backend.
2. Add browser auto-open on launch.
3. Test with live BL4.

### Phase 5: Packaging

1. Bundle static assets.
2. Build EXE.
3. Verify local-only flow on a clean machine.

## Recommended V1 Technical Choices

### Backend

Use a small Python web server. Keep it simple.

Good candidates:

- standard library `http.server` plus custom handlers
- Flask
- FastAPI

For speed of implementation, any lightweight solution is acceptable. Flask is likely the most straightforward if dependencies are acceptable.

### Frontend

Use plain HTML, CSS, and JS for the first version.

Reasons:

- minimal build overhead
- easy to package
- easy to edit quickly
- sufficient for a single focused page

### Communication

Use local HTTP first.

### Host Binding

Bind only to:

- `127.0.0.1`

Do not expose to LAN in V1.

## Success Criteria

V1 is successful when:

1. User can run one local helper.
2. User can open one local page.
3. User can paste one or more `@U...` serials.
4. User can inject them into BL4 without using the public website.
5. The page clearly shows attach and error status.

## Stretch Goals After V1

- import/export queue files
- read live backpack list
- per-item result tracking
- local search/filter
- simple item history
- drag-and-drop text files with serials
- tray app mode
- later `oak2` bridge option

## Immediate Next Step

The first implementation step should be:

1. extract the injector core from `bl4_app.py`
2. expose a minimal local API
3. build a plain `receive-items.html` page against that API

Do not start by redesigning the entire web app. Start with the narrow local path that proves the BL3-style workflow works in BL4.

## Source Index

Directly relevant sources for this plan:

- [bl4_app.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\bl4_app.py)
- [bl4_scanner.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\bl4_scanner.py)
- [find_gengine_direct.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\find_gengine_direct.py)
- [bl4_bridge.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\bl4_bridge.py)
- [loot_lobby.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\loot_lobby.py)
- [loot_drop.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\loot_drop.py)
- [dump_all.py](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\dump_all.py)
- [README.md](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\README.md)
- [IMPLEMENTATION_PLAN.md](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\injector\IMPLEMENTATION_PLAN.md)
- [injectorBridge.ts](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\web\src\lib\injectorBridge.ts)
- [InjectorSetupModal.tsx](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\web\src\components\InjectorSetupModal.tsx)
- [downloads](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\BL4-SaveEditor-main\web\public\downloads)
- BL3 conceptual UI reference: https://github.com/c0dycode/BL3HotfixWebUI/wiki/Receive-Items
- Optional for later: [Matt MBs Reward management.txt](C:\Users\NotUp\Pictures\Robert-Kinoplex-Save-Editor\Backpack%20Item%20Importer\Matt%20MBs%20Reward%20management.txt)