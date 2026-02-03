# ViewModel Reorganization

**Date:** 2026-01-27
**Change Type:** Architectural Refactoring
**Status:** ✅ Complete

## Summary

Moved all ViewModels from the centralized `Presentation/ViewModels/` folder to their respective feature folders to better align with the feature-based architecture pattern.

## Changes Made

### ViewModels Moved

All 5 ViewModels were moved using `git mv` to preserve file history:

1. ✅ `Presentation/ViewModels/HomeViewModel.swift` → `Features/Home/HomeViewModel.swift`
2. ✅ `Presentation/ViewModels/SearchViewModel.swift` → `Features/Search/SearchViewModel.swift`
3. ✅ `Presentation/ViewModels/UpcomingViewModel.swift` → `Features/Upcoming/UpcomingViewModel.swift`
4. ✅ `Presentation/ViewModels/DownloadViewModel.swift` → `Features/Downloads/DownloadViewModel.swift`
5. ✅ `Presentation/ViewModels/MediaDetailViewModel.swift` → `Features/MediaDetail/MediaDetailViewModel.swift`

### Folders Removed

- `BlossomMovie/Presentation/ViewModels/` (empty after moves)
- `BlossomMovie/Presentation/` (empty after ViewModels removal)

### Documentation Updated

Updated `CLAUDE.md` to reflect the new structure:

**File Organization Diagram:**
- Removed: `├── Presentation/ViewModels/ - Centralized ViewModels`
- Added: `│       ├── ViewModel.swift` under each feature folder

**Presentation Layer Section:**
- Changed: "ViewModels in `Presentation/ViewModels/`"
- To: "ViewModels are located within their respective feature folders"

**Features Layer Section:**
- Added: `├── {Feature}ViewModel.swift - Feature-specific ViewModel with business logic`

**Adding a New Feature Section:**
- Moved ViewModel creation step to #3 (earlier in process)
- Changed path from `Presentation/ViewModels/` to `Features/{FeatureName}/`
- Renumbered subsequent steps

## New Feature Structure

Each feature now follows this self-contained structure:

```
Features/{FeatureName}/
├── {FeatureName}FeatureView.swift    - Entry point
├── {FeatureName}ViewModel.swift      - Business logic (NEW LOCATION)
├── Views/
│   ├── {FeatureName}View.swift       - Main view
│   ├── {FeatureName}ContentView.swift - Content/loading states
│   └── Components/                    - UI components
```

## Benefits

### 1. Feature Cohesion
Each feature is now completely self-contained with all its logic in one place:
- Views
- ViewModels
- Components

### 2. Better Navigation
Developers can find all feature-related code in a single directory without jumping between `Features/` and `Presentation/` folders.

### 3. Easier Feature Development
When working on a feature, all relevant files are co-located:
```
Features/Home/
├── HomeFeatureView.swift     - Entry point
├── HomeViewModel.swift        - Business logic
└── Views/                     - UI implementation
```

### 4. Clearer Dependencies
Makes it explicit which ViewModels belong to which features, reducing cognitive load.

### 5. Deletion Safety
If a feature needs to be removed, all related code is in one folder (true modularity).

### 6. Aligns with Best Practices
Matches modern iOS architecture patterns where features are treated as independent modules:
- [Modular Feature Architecture in SwiftUI](https://dev.to/sebastienlato/modular-feature-architecture-in-swiftui-55bi)
- [Modularizing iOS Applications with SwiftUI and SPM](https://nimblehq.co/blog/modern-approach-modularize-ios-swiftui-spm)

## Before vs After

### Before (Centralized)
```
BlossomMovie/
├── Presentation/
│   └── ViewModels/
│       ├── HomeViewModel.swift
│       ├── SearchViewModel.swift
│       ├── UpcomingViewModel.swift
│       ├── DownloadViewModel.swift
│       └── MediaDetailViewModel.swift
└── Features/
    ├── Home/
    │   └── Views/...
    ├── Search/
    │   └── Views/...
    └── ...
```

### After (Feature-Based)
```
BlossomMovie/
└── Features/
    ├── Home/
    │   ├── HomeFeatureView.swift
    │   ├── HomeViewModel.swift      ← Moved here
    │   └── Views/...
    ├── Search/
    │   ├── SearchFeatureView.swift
    │   ├── SearchViewModel.swift    ← Moved here
    │   └── Views/...
    ├── Upcoming/
    │   ├── UpcomingFeatureView.swift
    │   ├── UpcomingViewModel.swift  ← Moved here
    │   └── Views/...
    ├── Downloads/
    │   ├── DownloadsFeatureView.swift
    │   ├── DownloadViewModel.swift  ← Moved here
    │   └── Views/...
    └── MediaDetail/
        ├── MediaDetailFeatureView.swift
        ├── MediaDetailViewModel.swift ← Moved here
        └── Views/...
```

## Verification

### Build Status
✅ Project builds successfully
```bash
mcp-cli call XcodeBuildMCP/build_sim '{}'
# Result: ✅ iOS Simulator Build build succeeded
```

### Git History Preserved
✅ All moves tracked as renames (RM) rather than delete+add:
```bash
git status --short | grep "RM.*ViewModel"
# Shows: RM BlossomMovie/Presentation/ViewModels/{Name}ViewModel.swift ->
#           BlossomMovie/Features/{Feature}/{Name}ViewModel.swift
```

### File Structure Verified
✅ All features contain their ViewModels:
```
Home: HomeFeatureView.swift, HomeViewModel.swift
Search: SearchFeatureView.swift, SearchViewModel.swift
Upcoming: UpcomingFeatureView.swift, UpcomingViewModel.swift
Downloads: DownloadsFeatureView.swift, DownloadViewModel.swift
MediaDetail: MediaDetailFeatureView.swift, MediaDetailViewModel.swift
```

## Impact Assessment

### Breaking Changes
None - The move doesn't affect import statements or functionality since Xcode automatically updates project references.

### Migration Required
None - This is a pure organizational change.

### Testing Required
- ✅ Project builds successfully
- ✅ All ViewModels accessible in their new locations
- Recommended: Manual testing of each feature to ensure functionality

## Related Documentation

- [typealias-feature-pattern.md](./typealias-feature-pattern.md) - Feature organization patterns
- [CLAUDE.md](../CLAUDE.md) - Updated project architecture documentation

## Future Considerations

### Potential Next Steps

1. **Extract to Swift Packages**
   - Each feature could become its own Swift Package
   - ViewModels are already co-located for easy extraction

2. **Feature Interfaces**
   - Define public interfaces for each feature
   - Use typealiases as facade (already implemented)

3. **Dependency Rules**
   - Enforce that features don't depend on each other
   - Only shared infrastructure dependencies allowed

4. **Feature Flags**
   - With self-contained features, easier to implement feature toggles
   - Can disable entire feature modules

## Conclusion

This reorganization improves code organization and maintainability by fully embracing the feature-based architecture pattern. Each feature is now a cohesive, self-contained module with all its components (views, view models, and UI components) located together.

The change aligns with modern iOS development best practices and sets the foundation for future modularization efforts using Swift Package Manager.

---

**Author:** Claude Code
**Reviewed By:** [Pending]
**Approved By:** [Pending]
