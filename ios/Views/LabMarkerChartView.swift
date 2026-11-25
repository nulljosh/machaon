import SwiftUI
import Charts

struct LabMarkerChartView: View {
    let history: [(date: Date, marker: LabMarker)]
    let markerName: String

    private var refLow: Double? { history.first?.marker.refLow }
    private var refHigh: Double? { history.first?.marker.refHigh }
    private var unit: String { history.first?.marker.unit ?? "" }

    private var spokenSummary: String {
        guard let last = history.last else { return "No results" }
        var parts = ["\(history.count) results", "latest \(last.marker.value.formatted()) \(unit) on \(last.date.formatted(date: .abbreviated, time: .omitted))"]
        if let lo = refLow, let hi = refHigh { parts.append("normal range \(lo.formatted()) to \(hi.formatted())") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(markerName)
                .font(.headline)
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)

            Chart {
                // Reference band
                if let lo = refLow, let hi = refHigh {
                    RectangleMark(
                        xStart: .value("Start", history.first!.date),
                        xEnd: .value("End", history.last!.date),
                        yStart: .value("Low", lo),
                        yEnd: .value("High", hi)
                    )
                    .foregroundStyle(Color.green.opacity(0.08))
                }

                // Reference lines
                if let hi = refHigh {
                    RuleMark(y: .value("Upper", hi))
                        .foregroundStyle(.red.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                if let lo = refLow {
                    RuleMark(y: .value("Lower", lo))
                        .foregroundStyle(.orange.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                // Value line
                ForEach(history, id: \.date) { row in
                    LineMark(
                        x: .value("Date", row.date),
                        y: .value("Value", row.marker.value)
                    )
                    .foregroundStyle(Color.blue)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", row.date),
                        y: .value("Value", row.marker.value)
                    )
                    .foregroundStyle(pointColor(row.marker.flag))
                    .symbolSize(60)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks { AxisValueLabel().font(.caption2) }
            }
            .frame(height: 200)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(markerName) history")
            .accessibilityValue(spokenSummary)
        }
        .padding()
        .background(Color.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func pointColor(_ flag: MarkerFlag) -> Color {
        switch flag {
        case .normal: return .blue
        case .low, .high: return .orange
        case .critical: return .red
        }
    }
}
