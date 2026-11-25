import SwiftUI

struct FacemaxxingView: View {
    @State private var filter: String = "All"
    @AppStorage("facemaxxing.checked") private var checkedRaw: String = "{}"

    private var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private var checked: [String: [String: Bool]] {
        guard let data = checkedRaw.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: [String: Bool]].self, from: data)
        else { return [:] }
        return dict
    }

    private var todayChecks: [String: Bool] { checked[todayKey] ?? [:] }
    private var completedToday: Int { todayChecks.values.filter { $0 }.count }
    private var totalCount: Int { FacemaxxingData.protocols.count }
    private var percent: Int { Int(Double(completedToday) / Double(totalCount) * 100) }

    private var visible: [FacemaxxingProtocol] {
        filter == "All" ? FacemaxxingData.protocols
            : FacemaxxingData.protocols.filter { $0.category == filter }
    }

    var body: some View {
        List {
            headerSection
            chipsSection
            protocolsSection
        }
        .navigationTitle("Facemaxxing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(completedToday) of \(totalCount) logged")
                        .font(.subheadline)
                }
                Spacer()
                Text("\(percent)%")
                    .font(.title2.bold())
                    .foregroundStyle(.tint)
            }
        }
    }

    private var chipsSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    chip("All")
                    ForEach(FacemaxxingData.categories, id: \.self) { cat in
                        chip(cat)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var protocolsSection: some View {
        Section {
            ForEach(visible) { p in
                protocolRow(p)
            }
        }
    }

    private func protocolRow(_ p: FacemaxxingProtocol) -> some View {
        NavigationLink {
            FacemaxxingDetailView(item: p)
        } label: {
            HStack(spacing: 12) {
                let isChecked = todayChecks[p.id] == true
                Button {
                    toggle(p.id)
                } label: {
                    Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isChecked ? Color.accentColor : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isChecked ? "Done today, \(p.title)" : "Mark done today, \(p.title)")

                VStack(alignment: .leading, spacing: 2) {
                    Text(p.title).font(.body)
                    Text("\(p.category) -- \(p.difficulty)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func chip(_ c: String) -> some View {
        Button {
            filter = c
        } label: {
            Text(c)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(filter == c ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundStyle(filter == c ? Color.white : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ id: String) {
        var dict = checked
        var today = dict[todayKey] ?? [:]
        today[id] = !(today[id] ?? false)
        dict[todayKey] = today
        if let data = try? JSONEncoder().encode(dict),
           let str = String(data: data, encoding: .utf8) {
            checkedRaw = str
        }
    }
}

struct FacemaxxingDetailView: View {
    let item: FacemaxxingProtocol

    var body: some View {
        List {
            summarySection
            stepsSection
            pslSection
            notesSection
            disclaimerSection
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summarySection: some View {
        Section {
            Text(item.summary).font(.body)
            HStack {
                Label(item.category, systemImage: "tag")
                Spacer()
                Label(item.difficulty, systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var stepsSection: some View {
        Section("Protocol") {
            ForEach(Array(item.steps.enumerated()), id: \.offset) { i, s in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(i + 1).")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Text(s)
                }
                .font(.callout)
            }
        }
    }

    private var pslSection: some View {
        Section("PSL Impact") {
            HStack {
                ForEach(item.psl, id: \.self) { dim in
                    Text(dim)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            Text(item.notes)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var disclaimerSection: some View {
        Section {
            Text("Not medical advice.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
