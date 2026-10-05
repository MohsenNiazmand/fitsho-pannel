# Workout Plan Improvements — Admin Panel Phases (PA1–PA3)

> **For AI agents / developers:** Read this whole file before touching code. Implement the phases in ascending order, test each, tick the checklist. Never run `git commit` / `git push` yourself; report the English commit message of each phase and stop for review. Backend counterpart: `../fitsho-backend/WORKOUT_PLAN_IMPROVEMENTS.md` (phases B12–B16). The panel must not be released before backend B13 is deployed, and must be released **soon after** it (see "Why the panel matters").

## Why the panel matters

The admin panel is the only tool that edits exercise rows (`levels`, `disciplines`, `isActive`, ...). Backend phase B13 removes the `elite` level and migrates existing exercises to `advanced`. If the panel still offers `elite`:
- an admin can re-introduce `elite` into exercises after the migration, silently making them unreachable again (the backend rejects it after B13, so the admin would just see an error);
- existing rows no longer contain `elite`, so the chip would show nothing useful.

Additional panel needs coming from the audit in backend B16: visibility into exercise pool coverage so catalog gaps are noticed.

## Contract notes

- Allowed exercise levels after B13: `beginner`, `intermediate`, `advanced`. Backend `POST/PUT /admin/exercises` returns a validation error for any other value (including `elite`).
- Metadata type `difficulty_level` no longer contains `elite` (the metadata screen reads items from the API, so it needs no hard-coded change).
- Canonical disciplines remain: `bodybuilding`, `fitness`, `corrective`, `cardio`, `flexibility`.
- No new endpoints are required, except the optional one in PA3.

## Progress

| Phase | Title | Backend dependency | Status |
|-------|-------|--------------------|--------|
| PA1 | Remove `elite` from the exercise editor and level display | B13 | ☑ |
| PA2 | Warn about legacy/invalid values and empty fields in the editor | B13/B16 | ☑ |
| PA3 | (Optional) exercise pool coverage view | B16 (new read-only endpoint) | Won't do (backend endpoint not exposed) |

---

## Phase PA1 — Remove `elite` from the exercise editor

**Files:** `lib/features/exercises/presentation/screens/exercises_screen.dart` (`_levelOptions`, around line 58; level multi-select around lines 335–347; the default `selectedLevels`), `test/features/exercises/exercises_test.dart`, `ADMIN_PANEL_FEATURE.md` / `EXERCISE_CATALOG_SYNC_FEATURE.md` wording.

**Changes**
- Delete `'elite': 'حرفه‌ای'` from `_levelOptions`; the editor offers exactly beginner / intermediate / advanced.
- When opening an existing exercise whose `levels` still contains an unknown value (e.g. `elite` from stale cached data), show it as an invalid chip with a warning color and drop it on save; never send `elite` to the API.
- Any list/filter/label that renders level names must tolerate unknown values (fall back to showing the raw key instead of crashing).
- Keep the default for new exercises: `['beginner','intermediate','advanced']`.

**Tests**
- Editor renders three level options.
- Opening an exercise with `levels: ['elite']` shows a warning and saving sends `['advanced']` only after the admin confirms/selects (do not auto-submit silently).
- No `elite` string remains in `lib/` (`grep -rn elite lib` empty).

**Checklist**
- [x] `_levelOptions` cleaned
- [x] Unknown-level handling + tests
- [x] Docs updated

**Commit message**
```
refactor(exercises): remove the elite level from the exercise editor

The backend merged elite into advanced. Offer only beginner, intermediate
and advanced in the exercise editor and handle legacy values gracefully
instead of sending elite to the API.
```

---

## Phase PA2 — Editor validation and warnings

**Files:** `exercises_screen.dart`, `admin_exercise.dart` (entity helpers if useful), l10n/string constants used by the screen, tests.

**Changes**
- Client-side validation before submit: at least one level, at least one discipline, at least one location, equipment not empty (use `none`/`bodyweight` for no-equipment exercises). Show inline errors instead of relying on the backend response.
- Highlight (non-blocking warning) exercises whose `disciplines` contain values outside the five canonical ids — these are legacy values that the AI filter will not match (see backend B16 audit). Show the raw legacy value as an orange chip with a tooltip: "Legacy value — will not be matched by the workout generator."
- Exercises list: add a small badge/filter "needs attention" for rows with empty/invalid levels, disciplines, locations or equipment, so an admin can fix them in bulk.
- Keep the existing flows (create, update, activate/deactivate, GIF/media sync) unchanged.

**Tests**
- Validation blocks submit with no levels; legacy discipline shows the warning; "needs attention" filter returns the right rows.

**Checklist**
- [x] Client-side validation
- [x] Legacy-value warnings
- [x] "Needs attention" filter
- [x] Tests green

**Commit message**
```
feat(exercises): validate exercise fields and flag legacy values

Add client-side validation for levels, disciplines, locations and equipment,
show a warning for discipline values outside the canonical set, and add a
needs-attention filter so admins can find catalog rows the workout
generator cannot use.
```

---

## Phase PA3 — (Optional) Exercise pool coverage view

Only implement after backend B16 exposes a read-only endpoint, e.g. `GET /api/v1/admin/exercises/coverage`, returning `[ { discipline, level, location, mainExercises } ]` (counts of active main exercises, excluding `mobility` / `flexibility` categories). If the backend does not add it, skip this phase and mark it "won't do".

**Files:** `lib/core/network/admin_api_service.dart` (+ regenerate `.g.dart`), a new provider + screen/section under `lib/features/exercises/`, tests.

**Changes**
- Add a "Coverage" tab or dialog: a grid discipline × level (and a location toggle) with the exercise count; cells below 8 are shown in red/orange ("catalog gap").
- Tapping a cell opens the exercise list pre-filtered by that discipline and level.
- Read-only: this screen never edits data.

**Tests:** provider parsing, threshold coloring, filter navigation.

**Checklist**
- [ ] API method + model
- [ ] Coverage UI
- [ ] Tests green

**Commit message**
```
feat(exercises): add exercise pool coverage view

Show a discipline by level grid of active exercise counts so admins can spot
catalog gaps that would produce empty or weak workout plans.
```

---

## Release and QA notes

- Release order: backend B13 migration → panel PA1 (and PA2) → optional PA3 after backend endpoint.
- Manual QA: open an existing advanced exercise, edit and save; create a new exercise with the default levels; try to save with no levels; open an exercise with a legacy discipline and confirm the warning; confirm the metadata screen no longer lists `elite` under `difficulty_level`.
- Run `flutter analyze` and `flutter test`; regenerate code with `dart run build_runner build --delete-conflicting-outputs` when models/API change. Report failures honestly.

## Guardrails

- Do not hard-code a different list of levels anywhere else in the panel; if a level label map is needed, keep it in one place.
- Never auto-modify exercises in bulk from the panel without an explicit admin action.
- Do not change authentication, dashboard, users or quota screens in this work.
