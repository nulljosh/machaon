import SwiftUI

private let allZones = footZones + handZones
private let allPoints = getAllPoints()
private let zoneLookup = Dictionary(uniqueKeysWithValues: (footZones + handZones).map { ($0.id, $0) })
private let pointLookup = Dictionary(uniqueKeysWithValues: getAllPoints().map { ($0.point.id, $0) })

struct SymptomFinderView: View {
    @State private var query = ""
    @State private var selected: Symptom?
    @State private var placeholderIndex = 0

    private let placeholders = [
        "What hurts?",
        "What's sore?",
        "Where does it ache?",
        "What's bothering you?",
        "What needs relief?",
    ]

    private var filtered: [Symptom] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return symptoms }
        return symptoms.filter {
            $0.name.lowercased().contains(q) ||
            $0.selfCare.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField(placeholders[placeholderIndex], text: $query)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                if let first = filtered.first { selected = first }
                            }
                        if !query.isEmpty {
                            Button { query = ""; selected = nil } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                                    .accessibilityLabel("Clear search")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .liquidGlass(in: Capsule(), interactive: true, fallback: .ultraThinMaterial)
                    .padding(.horizontal)

                    if let s = selected {
                        VStack(alignment: .leading, spacing: 16) {
                            Button {
                                withAnimation { selected = nil }
                            } label: {
                                Label("Back", systemImage: "chevron.left").font(.caption)
                            }

                            Text(s.name).font(.title).fontWeight(.bold)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("WHAT TO DO")
                                    .font(.caption).fontWeight(.semibold).tracking(1.2).foregroundStyle(.secondary)
                                Text(s.selfCare)
                                    .font(.subheadline)
                                    .lineSpacing(3)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("PRESSURE ZONES")
                                    .font(.caption).fontWeight(.semibold).tracking(1.2).foregroundStyle(.secondary)
                                ForEach(s.reflexZones, id: \.self) { zId in
                                    if let zone = zoneLookup[zId] {
                                        HStack(alignment: .top, spacing: 10) {
                                            Circle().fill(zone.system.color).frame(width: 8, height: 8).padding(.top, 5)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(zone.name).font(.subheadline).fontWeight(.medium)
                                                Text(zone.technique).font(.caption).foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("ACUPUNCTURE POINTS")
                                    .font(.caption).fontWeight(.semibold).tracking(1.2).foregroundStyle(.secondary)
                                ForEach(s.acuPoints, id: \.self) { pId in
                                    if let match = pointLookup[pId] {
                                        HStack(alignment: .top, spacing: 10) {
                                            Text(match.point.id).font(.caption).fontWeight(.bold).foregroundStyle(match.color).padding(.top, 2)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(match.point.name).font(.subheadline).fontWeight(.medium)
                                                Text(match.point.location).font(.caption).foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(filtered) { s in
                                Button {
                                    withAnimation(.spring(response: 0.3)) { selected = s }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: s.icon).font(.title3)
                                        Text(s.name)
                                            .font(.caption).fontWeight(.medium)
                                            .multilineTextAlignment(.center).lineLimit(2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)

                        if filtered.isEmpty {
                            Text("No matches. Try a different term.")
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(placeholders[placeholderIndex])
            .onChange(of: query) { selected = nil }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(3))
                    guard !Task.isCancelled else { break }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        placeholderIndex = (placeholderIndex + 1) % placeholders.count
                    }
                }
            }
        }
    }
}
