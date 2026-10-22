# Broker Explorer — Mac App Store preparation

Verified locally on 2026-10-17. No upload or App Store submission is authorized.

## Configuration

- Project / scheme: `broker-explorer.xcodeproj` / `broker-explorer`.
- App: Broker Explorer; identifier: `se.egelberg.broker-explorer`.
- Team: `52A6FA9VB5`; version/build: `1.0 (3)`.
- Minimum macOS: 14.0. The earlier 26.5 target was inherited from the project
  template; no source API or package requirement justified it.
- Universal Release archive: arm64 and x86_64, hardened runtime.
- Sandbox capabilities: App Sandbox and outgoing network client only. The unused
  user-selected-file entitlement has been removed. Application/team identifiers
  are added by distribution signing; no extra application permissions are needed.
- All ten Mac app icon PNG dimensions checked, including 1024×1024.
- App privacy manifest declares UserDefaults reason CA92.1, no tracking and no
  developer-collected data. The package also contains dependency privacy manifests.
- Existing GUI and networking implementation were not changed in this task.

## Build, archive and export

Use Xcode Product > Archive, or:

```sh
xcodebuild -project broker-explorer.xcodeproj -scheme broker-explorer \
  -configuration Release -destination 'generic/platform=macOS' \
  -archivePath /tmp/BrokerExplorer.xcarchive archive
xcodebuild -exportArchive -archivePath /tmp/BrokerExplorer.xcarchive \
  -exportOptionsPlist Distribution/ExportOptions.plist \
  -exportPath /tmp/BrokerExplorer-AppStore
```

The export plist explicitly selects `destination=export`; it does not upload.
Automatic signing successfully used existing App Store signing assets, including
an Xcode-managed Mac Installer Distribution identity. Do not replace this with a
manually signed profile: the existing profile is Xcode-managed.

Prepared artifacts on Magnus's Mac:

- Archive: `/Users/magnus/Library/Developer/Xcode/Archives/2026-10-17/BrokerExplorer-1.0-3.xcarchive`
- Signed installer: `/Users/magnus/Documents/GitHub/codex-chat/sandbox/broker-distribution-20261017/AppStoreExport-1.0-3/Broker Explorer.pkg`
- Installer signature and the distribution-signed app inside it both verified.
- Export summary: the same AppStoreExport-1.0-3 folder, `DistributionSummary.plist`.

Apple validation: Organizer successfully validated version 1.0 build 3 using the
initial build-2 archive with automatic version management. The project was then
aligned to build 3 to avoid a mismatch between the local package and validation.
Final fixed-build-number validation: **PASSED** in Xcode Organizer at 21:19
Europe/Stockholm on 2026-10-17. The final archive is 1.0 (3), automatic build-number
management was unchecked, the signing summary showed 1.0 (3), and Apple returned
"Your app successfully passed all validation checks." Organizer records
"Validation succeeded", build number 3. No new build was uploaded to the app record.

## Actual runtime verification

Tests used the development-signed, sandboxed Release app from the initial build-2 archive
on the current Apple Silicon Mac. Final build 3 has the same application source; only the build-number setting was
changed after those runtime tests. The exported store-signed package was inspected
and signature-verified; it was not installed over the user's application.

An isolated Python MQTT fixture listened only on `127.0.0.1:18884`; production
retained messages were never modified. Wire logs were used to verify publishing
semantics rather than relying only on the GUI status.

Verified:

- Connection and receipt/display of the local retained JSON sample.
- JSON syntax highlighting, editing, undo, and topic editing.
- Publish with QoS 0, 1 and 2; QoS 2 PUBREC/PUBREL/PUBCOMP exchange supported by
  fixture. Retain on and off; after reconnect, only retained topics reappeared.
- Refresh reconnect and explicit Connect after a forced socket closure.
- Forced connection loss produced a closed-connection status and preserved topics.
- Delete with confirmation sent three zero-length retained publishes and the
  branch remained absent after a new subscription.
- Positive TLS connection and message receipt to `test.mosquitto.org:8886`, using
  its publicly trusted certificate, with no publishing or deletion.
- TLS connection to that test service's deliberately expired-certificate port
  8887 was rejected with an NIOSSL error; no certificate checks were bypassed.
- Original saved connections/preferences restored after tests; fixture stopped.

Not established by these tests:

- Runtime on an actual macOS 14 installation or Intel hardware; build and archive
  support both architectures, but do not substitute for those runtime tests.
- Automatic reconnect triggered by macOS app activation was not conclusively
  exercised; manual reconnect after interruption passed.
- TLS with a private CA, client certificates, or every MQTT provider/authentication
  policy. No new support for these was added.
- Full MQTT server conformance: the local fixture is deliberately small. TestFlight
  against a dedicated real broker is still recommended before release.

## App Store Connect and remaining decisions

No App Store Connect app metadata has been changed. The locally visible Organizer
history confirms an earlier build 1 upload; the web app record has not been audited
in this task. Confirm build 3 is unused immediately before uploading.

Can be prepared locally: signed archive/package, icon checks, screenshots with safe
sample data, description/review-note drafts, and privacy/data-flow inventory.

Owner decisions and account checks still needed:

- Price, countries/regions, release method and final store wording.
- Support URL, privacy-policy URL and final App Privacy answers.
- Age-rating questionnaire and any outstanding account agreements/status.
- Encryption export answers: MQTT TLS links NIOSSL/BoringSSL, so this is NOT just
  encryption supplied by Apple's operating system. Do not automatically set
  `ITSAppUsesNonExemptEncryption=NO` or choose an OS-only declaration. Determine
  applicable exemption/documentation and availability decisions with Apple's
  encryption questionnaire before distribution.
- Review access: provide a dedicated broker with safe data and separate review
  credentials/instructions; never expose Magnus's production MQTT credentials.
- The existing Help action displays a work-in-progress message. It was deliberately
  left unchanged to respect the no-GUI/no-functionality scope; review it before
  submitting a finished product for App Review.

## Finish uploading — only after Magnus approves

1. In Xcode Window > Organizer, select broker-explorer **1.0 (3)** dated
   2026-10-17, and confirm the bundle identifier.
2. Use **Validate App** if the archive does not already show a successful result.
3. After approval, choose **Distribute App > App Store Connect > Upload**.
   Use custom options if needed and leave Manage version and build number
   unchecked to preserve this validated build 3. Inspect the signing summary.
   Do not upload a different archive.
4. Wait for processing, then inspect build warnings, encryption questions and
   TestFlight status in App Store Connect.
5. Stop there. Do not select Submit for Review or release/publish the app.

Alternatively, after approval upload the signed `.pkg` with Apple's Transporter.
The export itself is not an upload, and upload is not App Review submission.

Final exported package SHA-256:
`820a5cacf2d12e71bfa20a72dc74694b3cab280b016c8736a472aaa52312b960`

## Date-based builds — 2026-10-17

Subsequent Xcode builds use the same scheme as PanoWizard: a build phase generates
CFBundleVersion as YYYYMMDDHHmm and ExplorerBuildTimestamp as YYYY-MM-DD HH:mm
using the build Mac's local time. The standard About panel displays Version and
Build on separate lines. Info.plist preprocessing embeds both values before signing.
No source files are rewritten by the build. Export options keep automatic version
management disabled. In Organizer, also disable Manage version and build number.
Archive once and export/upload that archive to preserve its identity. Two builds
in the same minute have the same number; wait until the next minute before a new
upload candidate. Keep the Mac clock correct. Existing archives/uploads are unchanged.
Date-based builds have been built locally; Apple validation/upload must be done
for the new archive, not inferred from the earlier build 3 validation.

## Date build upload — 2026-10-17

User authorized upload of the latest date-based build. Native Release archive
1.0 (202610172210) passed strict signature verification and uploaded successfully
via xcodebuild with automatic signing and manageAppVersionAndBuildNumber=false.
Apple upload receipt: 2026-10-17 22:12:08 Europe/Stockholm, Upload succeeded.
Archive: /Users/magnus/Library/Developer/Xcode/Archives/2026-10-17/BrokerExplorer-1.0-202610172210.xcarchive.
No review submission or publication requested or performed.
Apple processing completed and build 202610172210 appeared in TestFlight.
Export compliance answered identically to build 3: standard cryptography beyond
Apple OS (NIOSSL/BoringSSL), France excluded per the user's prior decision.
Final TestFlight status verified: Ready to Submit. No review submission performed.

## Store metadata completion — 2026-10-17

User approved free pricing, all permitted countries and publication of a privacy
policy on GitHub. Only PRIVACY.md was committed/pushed (9cfcb92); app changes
remain uncommitted. Public policy verified at GitHub main and URL saved in ASC.
Privacy label Data Not Collected published after explicit action-time approval.
Free pricing confirmed for all currencies. Availability set to 174 storefronts,
France excluded consistently with prior export compliance. Future storefronts
use Apple's default inclusion. App remains manually released, unsubmitted.
Age questionnaire completed (no social/web/chat/advertising features or mature
content): calculated rating 4+. Review contact supplied by the user and saved.
Content Rights set to no third-party content: generic MQTT tool, no bundled or
curated third-party content/catalog. All metadata saved; no Add for Review or
review submission performed. Actual review acceptance is not guaranteed.
