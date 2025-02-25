# Changelog
## [1.3.0] - 2025-02-25
### Added
- Updated the README.md

## [1.2.0] - 2025-02-25
### Added
- Updated the README.md to provide clearer examples and enhanced documentation regarding the package features.

## [1.1.0] - 2025-02-25
### Added
- Added `generateID` function to generate random and unique IDs for records.
- Added `saveDataWithGeneratedID` function to save data with an automatically generated ID.
- Add the UPDATE method `saveData, deleteData, UPDATE` 
- Improve key security
- Enhance encryption methods `change sha256 to symmetric AES (Advanced Encryption Standard)`


### Changed
- Updated the `saveData` method to allow for automatic ID generation when saving new records.
- Refactored encryption and decryption logic to use AES for improved security.

## [0.0.1] - 2025-02-10
- Flutter by using SHA-256 encryption to protect information in the database.
- Encryption of data before storing it in the SQLite database.
- Protection against data extraction on rooted/jailbroken devices.
- Support for storing simple data (like String) or objects (like serialized classes).
