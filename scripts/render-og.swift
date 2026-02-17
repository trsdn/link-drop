import SwiftUI
import AppKit

struct OGImage: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.17, green: 0.35, blue: 0.63), Color(red: 0.29, green: 0.56, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 60) {
                // Left: text
                VStack(alignment: .leading, spacing: 16) {
                    Text("LinkDrop")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)

                    Text("Save clipboard links\nas files on macOS.")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)

                    HStack(spacing: 20) {
                        StatPill(value: "224 KB", label: "binary")
                        StatPill(value: "213", label: "lines")
                        StatPill(value: "0", label: "deps")
                    }
                    .padding(.top, 8)
                }

                // Right: mock window
                VStack(alignment: .leading, spacing: 8) {
                    // Title bar
                    HStack(spacing: 6) {
                        Circle().fill(Color.red.opacity(0.8)).frame(width: 10, height: 10)
                        Circle().fill(Color.yellow.opacity(0.8)).frame(width: 10, height: 10)
                        Circle().fill(Color.green.opacity(0.8)).frame(width: 10, height: 10)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("URL / Path:")
                            .font(.system(size: 11)).foregroundColor(.gray)
                        Text("https://github.com/...")
                            .font(.system(size: 13))
                            .padding(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(4)

                        Text("Link Name:")
                            .font(.system(size: 11)).foregroundColor(.gray)
                        Text("github.com \u{2013} claude-code")
                            .font(.system(size: 13))
                            .padding(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
                .frame(width: 280)
                .background(Color(white: 0.96))
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
            }
            .padding(60)
        }
        .frame(width: 1200, height: 630)
    }
}

struct StatPill: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 12)).foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
}

@main
struct OGRenderer {
    @MainActor static func main() {
        let view = OGImage()
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        if let image = renderer.nsImage,
           let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let png = bitmap.representation(using: .png, properties: [:]) {
            let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "og-image.png"
            try? png.write(to: URL(fileURLWithPath: path))
            print("Wrote \(path)")
        }
    }
}
