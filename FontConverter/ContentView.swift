import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    enum Target: String, CaseIterable, Identifiable {
        case ios16 = "锁屏16系统"
        case ios17 = "锁屏17系统"
        case ios18 = "锁屏18/26系统"
        case sfui = "数英（全系统通用）"
        var id: String { rawValue }
        var template: String {
            switch self {
            case .ios16: return "16系统.ttc"
            case .ios17: return "17系统.ttc"
            case .ios18: return "18、26系统.ttc"
            case .sfui: return "SFUI.ttf"
            }
        }
        var isTTC: Bool { self != .sfui }
        var suffix: String { self == .ios16 ? "ADTTime.ttc" : (self == .sfui ? "SFUI.ttf" : "ADTNumeric.ttc") }
    }

    @State private var target: Target = .ios17
    @State private var scale = "1.0"
    @State private var sourceURL: URL?
    @State private var isPickerPresented = false
    @State private var isWorking = false
    @State private var status = "请选择字体文件"
    @State private var exportURL: URL?
    @State private var showExporter = false

    var body: some View {
        NavigationStack {
            Form {
                Section("目标模板") {
                    Picker("系统", selection: $target) {
                        ForEach(Target.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section("字体文件") {
                    Button(sourceURL?.lastPathComponent ?? "选择 TTF / TTC / OTF / OTC") { isPickerPresented = true }
                }
                Section("微调比例") {
                    TextField("1.0", text: $scale).keyboardType(.decimalPad)
                }
                Section {
                    Button {
                        startConversion()
                    } label: {
                        HStack {
                            Spacer()
                            if isWorking { ProgressView() } else { Text("开始转换") }
                            Spacer()
                        }
                    }
                    .disabled(sourceURL == nil || isWorking)
                }
                Section("状态") { Text(status).font(.footnote) }
            }
            .navigationTitle("字体转换工具")
            .fileImporter(isPresented: $isPickerPresented,
                          allowedContentTypes: [.font, .data],
                          allowsMultipleSelection: false) { result in
                if case .success(let urls) = result { sourceURL = urls.first; status = "已选择：\(urls.first?.lastPathComponent ?? "")" }
            }
            .fileExporter(isPresented: $showExporter,
                          document: ExportDocument(url: exportURL),
                          contentType: target.isTTC ? .font : .font,
                          defaultFilename: exportURL?.lastPathComponent ?? "converted-font") { result in
                if case .success = result { status = "已导出" }
            }
        }
    }

    private func startConversion() {
        guard let sourceURL, let manualScale = Double(scale), manualScale > 0 else { status = "微调比例必须是大于 0 的数字"; return }
        guard let templateURL = Bundle.main.url(forResource: "Templates/\(target.template)", withExtension: nil) else { status = "找不到模板：\(target.template)"; return }
        let granted = sourceURL.startAccessingSecurityScopedResource()
        defer { if granted { sourceURL.stopAccessingSecurityScopedResource() } }
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let base = sourceURL.deletingPathExtension().lastPathComponent
        let output = dir.appendingPathComponent("❤️\(base)_\(target.suffix)")
        isWorking = true; status = "转换中…"
        FontPythonBridge.convertSource(sourceURL.path, templatePath: templateURL.path, outputPath: output.path, ttcMode: target.isTTC, manualScale: manualScale) { ok, error in
            isWorking = false
            if ok { exportURL = output; status = "转换成功：\(output.lastPathComponent)"; showExporter = true }
            else { status = "转换失败：\(error ?? "未知错误")" }
        }
    }
}

struct ExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.font, .data] }
    let url: URL?
    init(url: URL?) { self.url = url }
    init(configuration: ReadConfiguration) throws { url = nil }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let url, let data = try? Data(contentsOf: url) else { throw CocoaError(.fileNoSuchFile) }
        return FileWrapper(regularFileWithContents: data)
    }
}
