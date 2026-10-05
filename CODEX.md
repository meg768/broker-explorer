# Broker Explorer project context

## Current foundation

Canonical repository: https://github.com/meg768/broker-explorer

Broker Explorer is a native macOS SwiftUI Xcode application. Use
`broker-explorer.xcodeproj`, scheme `broker-explorer`. The app product is
`Broker Explorer.app`; its Swift module remains `broker_explorer`.

- Bundle identifier: `se.egelberg.broker-explorer`.
- Apple Developer team: `52A6FA9VB5` (Magnus Egelberg).
- Release version/build: `1.0 (1)` in the Xcode configuration.
- Category: `public.app-category.developer-tools`.
- Deployment target: macOS 26.5, inherited from the new project.
- App Sandbox and outgoing network client access are enabled.
- The existing MQTT-purple icon is preserved, including all Mac App Store sizes.

The clean Xcode foundation previously built, archived, passed App Store Connect
validation, and uploaded version 1.0 (1). Its checkpoint is
`v26.10.04.22.24`. The restored application has subsequently built and archived,
but has not been uploaded or revalidated in App Store Connect. A future upload
will need a new build number; this migration deliberately preserved versioning.

Do not introduce an application Package.swift, custom build scripts, manually
assembled app bundles, or a new signing architecture. Use normal Xcode builds,
archives, signing, asset catalogs, and Swift Package integration.

## Restoration from the old app

The old implementation is read-only reference material:
https://github.com/meg768/broker-explorer-old

The complete app was restored from old commit
`7e0b1a9bb64548f8fa9974cae5ea3fb0c7a971b0`.
The sibling `../broker-explorer-old` was absent during restoration, so a temporary
read-only Git clone was used. Never modify the old repository.

The nine old Swift source files now live in `broker-explorer/`:

- `BrokerExplorerApp.swift`: single window, menus, app lifecycle.
- `ContentView.swift`: complete original interface.
- `ExplorerStore.swift`: observable app state and connection coordination.
- `MQTTService.swift`: MQTT actor and endpoint handling.
- `Models.swift`: connection/message/tree models.
- `SettingsStore.swift`: UserDefaults persistence.
- `AppearanceSettings.swift`: existing appearance preferences.
- `JSONTextEditor.swift`: original AppKit payload editor.
- `TopicTextField.swift`: original AppKit topic field.

The starter app entry point and temporary MQTT diagnostic interface were replaced.
The old privacy manifest was copied to `broker-explorer/PrivacyInfo.xcprivacy`;
Xcode bundles it normally. It declares UserDefaults access reason CA92.1.

The old UI and behavior are the reference: do not freelance, redesign, add
features, or refactor during migration. Required source differences were limited
to explicit Combine imports and nonisolated declarations for compatibility with
the new project's actor isolation/import visibility settings. Product naming and
the local-network usage description were configured through Xcode build settings.
Signing, sandbox, icon, category, identifier, deployment target, and versioning
were preserved.

## Dependencies

Native Xcode Swift Package references:

- mqtt-nio: minimum 2.13.0, product MQTTNIO.
- swift-nio: minimum 2.80.0, products NIOCore and NIOPosix.

The checked-in lock file is
`broker-explorer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
The restoration resolved mqtt-nio 2.13.0, swift-nio 2.101.0, swift-nio-ssl 2.37.1,
swift-nio-transport-services 1.28.0, swift-atomics 1.3.0, swift-collections 1.6.0,
swift-log 1.13.2, and swift-system 1.7.2.

## Preserve these behaviors

KISS: one app, one window, one logical open broker, no tabs, no connection manager.
The menu bar is Broker Explorer | Connection | Edit | Help. Connection contains
New Connection…, Open Recent, and Close Connection.

Remember at most five MRU connections in UserDefaults using Codable, including
passwords. Absolutely no Keychain for MQTT credentials. Identity is host/URL,
port, and username; changing a password updates the existing entry. Remember a
connection after MQTT login succeeds, independently of subscription success.

Launch automatically opens the first recent connection. With no recents, show
No Connection Open. Explicit Close Connection preserves recents but closes the
connection for the current session. Unexpected network loss preserves the logical
connection and existing reconnect behavior. A fresh New Connection draft leaves
the active connection unchanged until Connect; Cancel changes nothing.

Keep generation guards and serialized connection switching so callbacks from an
old client cannot affect a new connection. Preserve MQTT subscription, publishing,
retained-message deletion, QoS cycling, Retain, and Text/JSON behavior.

Preserve the original topic tree, split container, toolbar, search, status area,
connection sheet, and right-hand editing form. Use native macOS/system appearance,
not tennis/web styling. Preserve the rounded field boundaries and native focus
indication. The Topic control has fixed 36-point height and stable centered text.
Keep the AppKit payload editor, syntax highlighting, undo, scrolling, selection,
formatting, substitutions settings, reset identity, and accessibility behavior.
Existing F3/F6 appearance interactions remain as in the old app.

## Build and verification

From the repository root:

```sh
xcodebuild -project broker-explorer.xcodeproj -scheme broker-explorer \
  -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath /tmp/broker-explorer-build build
open '/tmp/broker-explorer-build/Build/Products/Debug/Broker Explorer.app'
```

Archive with the same project/scheme, Release configuration,
`-destination 'generic/platform=macOS'`, and an explicit `-archivePath`.

Restoration verification completed before this checkpoint:

- Debug build and Release archive succeeded using Xcode 26.5.
- Archive is universal arm64/x86_64 and passes strict codesign verification.
- Archive signing used Apple Development: Magnus Egelberg, team 52A6FA9VB5.
  App Store distribution export/upload has not been performed for this restoration.
- Seven old connection regression tests passed against the new app's actual debug
  library. Temporary test harnesses stayed outside the repository.
- The sandboxed app connected, subscribed to #, and received retained messages
  from a local MQTT fixture through the normal connection sheet.
- Publishing at QoS 1/2, Retain, JSON formatting, undo, filtering, branch deletion,
  Cancel, explicit Close, and MRU opening after relaunch were checked.
- Wire-level fixture logs confirmed subscriptions and publish/delete semantics.
- The final app was launched for user review. Only temporary test recents were
  removed; no user connection was deleted.

Public-broker testing previously established an outgoing sandboxed connection,
but public server subscription policies prevented reliable message verification;
message reception was actually verified using the local fixture.

## Git checkpoints

When requested, save context here, commit, and create an annotated local-time tag
using `vYY.MM.DD.HH.mm` in Europe/Stockholm, annotation `Broker Explorer <tag>`.
Push main and the specific tag; verify remote hashes and a clean working tree.
Do not commit or push without the user's instruction.
