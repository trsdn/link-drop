import SwiftUI
import AppKit

let defaultFolder = NSHomeDirectory() + "/Downloads"

@main
struct LinkDropApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

// MARK: - Settings

struct SettingsView: View {
    @AppStorage("saveFolder") private var saveFolder: String = defaultFolder

    var body: some View {
        Form {
            LabeledContent("Save folder:") {
                HStack {
                    Text(saveFolder)
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .frame(maxWidth: 280, alignment: .leading)
                    Spacer()
                    Button("Choose\u{2026}") {
                        chooseFolder()
                    }
                }
            }

            Button("Reset to Downloads") {
                saveFolder = defaultFolder
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 140)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: saveFolder)
        if panel.runModal() == .OK, let url = panel.url {
            saveFolder = url.path
        }
    }
}

// MARK: - Main View

struct ContentView: View {
    @State private var clipboardContent = ""
    @State private var linkName = ""
    @AppStorage("saveFolder") private var saveFolder: String = defaultFolder
    @State private var statusMessage = ""
    @State private var statusIsError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create Link from Clipboard")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("URL / Path:")
                    .font(.subheadline).foregroundColor(.secondary)
                TextField("Paste or edit URL", text: $clipboardContent)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Link Name:")
                    .font(.subheadline).foregroundColor(.secondary)
                TextField("Name for the .url file", text: $linkName)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(spacing: 4) {
                Image(systemName: "folder")
                    .foregroundColor(.secondary)
                Text(abbreviatePath(saveFolder))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .truncationMode(.middle)
                    .lineLimit(1)
            }

            Divider()

            HStack {
                if !statusMessage.isEmpty {
                    Image(systemName: statusIsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(statusIsError ? .red : .green)
                    Text(statusMessage)
                        .foregroundColor(statusIsError ? .red : .green)
                        .font(.callout)
                }
                Spacer()
                Button("Create Link") {
                    createLink()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .disabled(clipboardContent.isEmpty || linkName.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 440)
        .onAppear {
            loadClipboard()
        }
    }

    private func abbreviatePath(_ path: String) -> String {
        let home = NSHomeDirectory()
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }

    private func loadClipboard() {
        let pb = NSPasteboard.general
        if let str = pb.string(forType: .string) {
            clipboardContent = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            linkName = deriveName(from: clipboardContent)
        }
    }

    private func deriveName(from raw: String) -> String {
        if let url = URL(string: raw), let host = url.host {
            let last = url.lastPathComponent
            if last != "/" && !last.isEmpty && last != host {
                return "\(host) \u{2013} \(last)"
            }
            return host
        }
        let name = (raw as NSString).lastPathComponent
        return name.isEmpty ? "Untitled" : name
    }

    private func createLink() {
        let fm = FileManager.default

        if !fm.fileExists(atPath: saveFolder) {
            do {
                try fm.createDirectory(atPath: saveFolder, withIntermediateDirectories: true)
            } catch {
                statusMessage = "Cannot create folder: \(error.localizedDescription)"
                statusIsError = true
                return
            }
        }

        let safeName = linkName
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .trimmingCharacters(in: .whitespaces)

        guard !safeName.isEmpty else {
            statusMessage = "Please enter a link name."
            statusIsError = true
            return
        }

        let filePath = (saveFolder as NSString).appendingPathComponent("\(safeName).url")

        if fm.fileExists(atPath: filePath) {
            statusMessage = "File already exists: \(safeName).url"
            statusIsError = true
            return
        }

        var urlToSave = clipboardContent

        if clipboardContent.hasPrefix("/") {
            urlToSave = URL(fileURLWithPath: clipboardContent).absoluteString
        } else if clipboardContent.hasPrefix("~") {
            let expanded = NSString(string: clipboardContent).expandingTildeInPath
            urlToSave = URL(fileURLWithPath: expanded).absoluteString
        }

        let content = "[InternetShortcut]\r\nURL=\(urlToSave)\r\n"

        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            statusMessage = "Created \(safeName).url"
            statusIsError = false
        } catch {
            statusMessage = "Failed: \(error.localizedDescription)"
            statusIsError = true
        }
    }
}
