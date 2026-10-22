import AppKit
import SwiftUI

@main
struct BrokerExplorerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ExplorerStore()

    var body: some Scene {
        Window("Broker Explorer", id: "explorer") {
            ContentView()
                .environmentObject(store)
        }
        .defaultSize(width: 1100, height: 700)
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Broker Explorer") {
                    let info = Bundle.main.infoDictionary ?? [:]
                    let version = info["CFBundleShortVersionString"] as? String ?? "1.0"
                    let timestamp = info["ExplorerBuildTimestamp"] as? String ?? ""
                    NSApp.orderFrontStandardAboutPanel(options: [
                        .applicationVersion: "Version \(version)\nBuild \(timestamp)",
                        .version: "",
                    ])
                }
            }
            CommandGroup(replacing: .help) {
                Button("Broker Explorer Help") {
                    let alert = NSAlert()
                    alert.messageText = "Broker Explorer Help is a work in progress."
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
            CommandGroup(after: .newItem) {
                Button("New Connection…", action: store.newConnection)
                    .keyboardShortcut("n")
                Menu("Open Recent") {
                    ForEach(Array(store.recentConnections.enumerated()), id: \.offset) { _, connection in
                        Button(connection.recentLabel) { store.connect(to: connection) }
                    }
                }
                .disabled(store.recentConnections.isEmpty)
                Divider()
                Button("Disconnect", action: store.disconnect)
                    .disabled(store.openConnection == nil)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}
