import SwiftUI
import AppKit

// Mock of the main ContentView for rendering
struct MockMainView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create Link from Clipboard")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("URL / Path:")
                    .font(.subheadline).foregroundColor(.secondary)
                Text("https://github.com/anthropics/claude-code")
                    .padding(.horizontal, 6)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Link Name:")
                    .font(.subheadline).foregroundColor(.secondary)
                Text("github.com \u{2013} claude-code")
                    .padding(.horizontal, 6)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }

            HStack(spacing: 4) {
                Image(systemName: "folder")
                    .foregroundColor(.secondary)
                Text("~/Downloads")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Created github.com \u{2013} claude-code.url")
                    .foregroundColor(.green)
                    .font(.callout)
                Spacer()
                Text("Create Link")
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.accentColor)
                    .cornerRadius(6)
            }
        }
        .padding(20)
        .frame(width: 440)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// Mock settings view
struct MockSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toolbar area
            HStack {
                Spacer()
                Text("Settings")
                    .font(.headline)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color(nsColor: .windowBackgroundColor))

            // Grouped form content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Save folder:")
                        .foregroundColor(.secondary)
                    HStack {
                        Text("~/Downloads")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Choose\u{2026}")
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    }
                }
                .padding(12)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)

                Text("Reset to Downloads")
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }
            .padding(20)
        }
        .frame(width: 460)
        .background(Color(nsColor: .underPageBackgroundColor))
    }
}

// Window chrome wrapper
struct WindowChrome<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            ZStack {
                // Traffic lights
                HStack(spacing: 8) {
                    Circle().fill(Color(red: 1.0, green: 0.38, blue: 0.35)).frame(width: 12, height: 12)
                    Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.18)).frame(width: 12, height: 12)
                    Circle().fill(Color(red: 0.15, green: 0.8, blue: 0.26)).frame(width: 12, height: 12)
                    Spacer()
                }
                .padding(.horizontal, 12)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(height: 38)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
        .padding(30)
    }
}

@main
struct ScreenshotRenderer {
    @MainActor static func main() {
        let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

        // Render main window
        let mainView = WindowChrome(title: "LinkDrop") {
            MockMainView()
        }
        renderToFile(view: mainView, filename: "\(outputDir)/screenshot-main.png", scale: 2)

        // Render settings window
        let settingsView = WindowChrome(title: "Settings") {
            MockSettingsView()
        }
        renderToFile(view: settingsView, filename: "\(outputDir)/screenshot-settings.png", scale: 2)

        print("Screenshots rendered.")
    }

    @MainActor static func renderToFile<V: View>(view: V, filename: String, scale: CGFloat) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        if let image = renderer.nsImage {
            if let tiff = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiff),
               let png = bitmap.representation(using: .png, properties: [:]) {
                let url = URL(fileURLWithPath: filename)
                try? png.write(to: url)
                print("  Wrote \(filename) (\(png.count) bytes)")
            }
        }
    }
}
