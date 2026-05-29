# Changelog

## [0.2.0] - 2026-05-29
### Added
- Automated deployment verification pipeline (`Install-SeniorDevBuddy.ps1`).
- Execution privilege and native dependency checks (Chocolatey availability).
- Detailed user-remediation workflows within console outputs for environments failing compliance.
- Pester regression suite (`tests\ChocoFailure.Tests.ps1`) targeting negative environmental constraints via functional mocking.
- Strict isolation of operational execution scopes to remain fully Pester 5 compliant.

### Fixed
- Misplaced .NET SuppressMessage parser attributes within Windows PowerShell 5.1 runtime scopes.
- Unintentional session terminations (`exit` trapping) inside active testing frameworks.
