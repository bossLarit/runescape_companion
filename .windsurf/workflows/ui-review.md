---
description: UI review checklist before committing Flutter screen changes
---

## UI Review Checklist

Run through these checks before committing any screen/widget changes:

### Layout
- [ ] Every `Row` with variable-width children uses `Flexible` or `Expanded`
- [ ] Long horizontal content uses `SingleChildScrollView(scrollDirection: Axis.horizontal)`
- [ ] Test the screen at **minimum window size** (800x600) — no overflow
- [ ] Test with long text content (e.g. long usernames, item names)

### State Management
- [ ] Every `TextEditingController` that feeds into computed output has a `useListenable(controller)` in the build method
- [ ] Every `useState` that drives UI is actually connected to user input (not just initialized)
- [ ] Provider reads vs watches: use `ref.watch()` for reactive UI, `ref.read()` only in callbacks

### Before Push
// turbo
1. Run `flutter analyze` locally
2. Test on smallest supported window size
3. Verify all interactive inputs produce visible output changes
