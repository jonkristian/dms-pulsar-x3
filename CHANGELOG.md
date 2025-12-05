# Changelog

## [0.1.1] - 2025-12-05

### Changed
- Increased polling interval from 10s to 15s to reduce USB contention

### Fixed
- Added data validation to ignore garbage responses from the mouse
- Battery, DPI, and stage values are now validated before updating the display
- Prevents showing incorrect values (0% battery, invalid DPI) when USB communication fails

## [0.1.0] - 2025-11-29

### Added
- Initial release
- Battery percentage display in bar
- DPI display in bar
- Popup with quick DPI presets (400, 800, 1600, 3200)
- DPI stage selector (1-6)
- Button to open full settings GUI
