import Foundation
import Danger
import DangerShellExecutor

// MARK: - Properties

let danger = Danger()
let shell = ShellExecutor()

let maxAllowedAdditions: Int = 500
let additions = danger.github.pullRequest.additions ?? 0
let deletions = danger.github.pullRequest.deletions ?? 0
let changedFiles = danger.github.pullRequest.changedFiles ?? 0
let allEditedFiles = danger.git.modifiedFiles + danger.git.createdFiles
let allEditedSwiftFiles = allEditedFiles.filter { $0.fileType == .swift }
let hasEditedChangelog = allEditedFiles.contains("CHANGELOG.md")
let isSkippingChangelog = danger.github.pullRequest.body?.contains("#no_changelog") ?? false

let bitriseBuildNumberVar = "$BITRISE_BUILD_NUMBER"
let bitriseBuildNumber = shell.execute("echo \(bitriseBuildNumberVar)", arguments: [])
let bitriseBuildURLVar = "$BITRISE_BUILD_URL"
let bitriseBuildURL = shell.execute("echo \(bitriseBuildURLVar)", arguments: [])

// MARK: - PR

// gatekeeping pr size
if additions > maxAllowedAdditions {
    warn("This PR is considered `big`. Try to keep the number of additions below \(maxAllowedAdditions).")
}

// gatekeeping pr WIP
if danger.github.pullRequest.title.contains("WIP") {
    warn("This PR is classed as Work in Progress (WIP).")
}

// MARK: - Changelog

if !isSkippingChangelog, !hasEditedChangelog, !allEditedSwiftFiles.isEmpty {
    fail("CHANGELOG entry required. Please add a description of changes made to this project to `CHANGELOG.md` or `#no_changelog` to the PRs body and rerun the CI.")
} else if isSkippingChangelog {
    message("Skipping Changelog")
}

// MARK: - Bitrise Information

message("Build #\(bitriseBuildNumber) completed.")
message("[Bitrise Build logs](\(bitriseBuildURL))")

// MARK: - General

message("🎉 The PR added \(additions) and removed \(deletions) lines. 🗂 \(changedFiles) files changed.")

// MARK: - SwiftLint

SwiftLint.lint(inline: true)
