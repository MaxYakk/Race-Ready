import Foundation

// MARK: - Phase 2 — Race-Specific Build (Weeks 7–12)
//
// Weekly template: Mon Push (reduced) + 15 min wall ball · Tue Threshold 1 km repeats
//                  · Wed Hyrox circuit + compressed pull · Thu Easy run
//                  · Fri Legs + lunges · Sat Sled/ski sim + medium run · Sun rest
// 6 × 6 = 36 templates.

extension PlanData {

    static var phase2Templates: [SessionTemplate] {
        (7...12).flatMap { week -> [SessionTemplate] in
            [
                phase2Push(week: week),
                phase2Threshold(week: week),
                phase2Circuit(week: week),
                phase2EasyRun(week: week),
                phase2Legs(week: week),
                phase2SledSim(week: week)
            ]
        }
    }

    // MARK: Mon — Push (reduced) + 15 min wall ball

    private static func phase2Push(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .pushDay, slot: 0),
            weekNumber: week, sessionType: .pushDay, slot: 0,
            title: "Push (reduced) + Wall Ball",
            subtitle: "45 min lift, 15 min wall ball",
            estimatedDurationSeconds: 60 * 60,
            blocks: [
                pushMain(setsTopRange: 3, repRange: 6...8),
                ExerciseBlock(
                    title: "Wall-ball block",
                    subtitle: "15 min",
                    items: [
                        ExerciseItem(name: "Wall ball", sets: 5, reps: 25, weightKg: 6,
                                     restSeconds: 60,
                                     cue: "Race-weight, race-target height.")
                    ]
                ),
                lowerLegFinisher
            ]
        )
    }

    // MARK: Tue — Threshold 1 km repeats (Dearden signature)

    private static func phase2Threshold(week: Int) -> SessionTemplate {
        let prescription: IntervalPrescription
        let totalKm: Double
        switch week {
        case 7:
            prescription = .init(reps: 4, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 90, description: "4 × 1 km @ 4:45, 90 s rest")
            totalKm = 6
        case 8:
            prescription = .init(reps: 3, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 290,
                                 restSeconds: 120, description: "3 × 1 km @ 4:50, 2 min rest (deload)")
            totalKm = 5
        case 9:
            prescription = .init(reps: 5, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 90, description: "5 × 1 km @ 4:45, 90 s rest")
            totalKm = 7
        case 10:
            prescription = .init(reps: 6, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 90, description: "6 × 1 km @ 4:45, 90 s rest (Dearden session)")
            totalKm = 8
        case 11:
            prescription = .init(reps: 4, repDistanceMeters: 1_500, repTargetPaceSecondsPerKm: 290,
                                 restSeconds: 120, description: "4 × 1.5 km @ ~7:15, 2 min rest")
            totalKm = 8
        case 12:
            prescription = .init(reps: 3, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 270,
                                 restSeconds: 120, description: "3 × 1 km @ 4:30, 2 min rest (deload)")
            totalKm = 5
        default:
            prescription = .init(reps: 4, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 90, description: "")
            totalKm = 6
        }
        return SessionTemplate(
            id: id(week: week, type: .thresholdRun, slot: 1),
            weekNumber: week, sessionType: .thresholdRun, slot: 1,
            title: "Threshold — 1 km Repeats",
            subtitle: prescription.description,
            estimatedDurationSeconds: 55 * 60,
            intervalPrescription: prescription,
            targetRunDistanceMeters: totalKm * 1_000
        )
    }

    // MARK: Wed — Hyrox circuit + compressed pull

    private static func phase2Circuit(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .hyroxCircuit, slot: 2),
            weekNumber: week, sessionType: .hyroxCircuit, slot: 2,
            title: "Hyrox Circuit + Compressed Pull",
            subtitle: "The new key session — 45 min",
            estimatedDurationSeconds: 75 * 60,
            blocks: [
                ExerciseBlock(
                    title: "Circuit — 4 rounds, 2 min rest between",
                    items: [
                        ExerciseItem(name: "Run", sets: 1, distanceMeters: 800,
                                     qualifier: "~4:30 pace"),
                        ExerciseItem(name: "Wall ball", sets: 1, reps: 20, weightKg: 6),
                        ExerciseItem(name: "Burpee broad jumps", sets: 1, reps: 15, distanceMeters: 25),
                        ExerciseItem(name: "Sandbag lunges", sets: 1, weightKg: 20, distanceMeters: 30)
                    ]
                ),
                ExerciseBlock(
                    title: "Compressed pull (25 min)",
                    items: [
                        ExerciseItem(name: "Lat pulldown", sets: 3, reps: 10),
                        ExerciseItem(name: "T-bar row", sets: 3, reps: 8),
                        ExerciseItem(name: "DB curl", sets: 3, reps: 12),
                        ExerciseItem(name: "Hammer curl", sets: 3, reps: 12)
                    ]
                )
            ]
        )
    }

    // MARK: Thu — Easy run Z2

    private static func phase2EasyRun(week: Int) -> SessionTemplate {
        let km: Double = [7: 6, 8: 5, 9: 7, 10: 7, 11: 8, 12: 6][week] ?? 6
        return SessionTemplate(
            id: id(week: week, type: .easyRun, slot: 3),
            weekNumber: week, sessionType: .easyRun, slot: 3,
            title: "Easy Run · Z2",
            subtitle: String(format: "%.0f km @ talk-test pace", km),
            estimatedDurationSeconds: Int(km * 6 * 60),
            targetRunDistanceMeters: km * 1_000,
            notes: ["Recovery between Tue threshold and Sat sim."]
        )
    }

    // MARK: Fri — Legs (alternating) + lunge volume

    private static func phase2Legs(week: Int) -> SessionTemplate {
        let isQuadBias = (week % 2 == 1) // Wk 7, 9, 11 → quad; 8, 10, 12 → posterior

        let mainBlock: ExerciseBlock
        if isQuadBias {
            mainBlock = ExerciseBlock(
                title: "Legs — quad bias (reduced)",
                items: [
                    ExerciseItem(name: "Pendulum squat", sets: 3, repsLow: 6, repsHigh: 8),
                    ExerciseItem(name: "Bulgarian split squat", sets: 3, reps: 8, qualifier: "each leg"),
                    ExerciseItem(name: "Leg extension", sets: 3, reps: 12),
                    ExerciseItem(name: "Standing calf raise", sets: 3, reps: 12)
                ]
            )
        } else {
            mainBlock = ExerciseBlock(
                title: "Legs — posterior (reduced)",
                items: [
                    ExerciseItem(name: "Hip thrust", sets: 3, reps: 8),
                    ExerciseItem(name: "Romanian DB deadlift", sets: 3, reps: 8),
                    ExerciseItem(name: "Lying leg curl", sets: 3, reps: 12),
                    ExerciseItem(name: "Seated calf raise", sets: 3, reps: 15)
                ]
            )
        }

        let lungeBlock = ExerciseBlock(
            title: "Sandbag/DB lunge volume",
            items: [
                ExerciseItem(name: "Front-rack DB lunges", sets: 4, weightKg: 20,
                             distanceMeters: 20, restSeconds: 90)
            ]
        )

        return SessionTemplate(
            id: id(week: week, type: .legsDay, slot: 4),
            weekNumber: week, sessionType: .legsDay, slot: 4,
            title: isQuadBias ? "Legs (Quad) + Lunges" : "Legs (Posterior) + Lunges",
            subtitle: "Maintain overload, accept slower gains",
            estimatedDurationSeconds: 60 * 60,
            blocks: [mainBlock, lungeBlock, lowerLegFinisher]
        )
    }

    // MARK: Sat — Sled/Ski simulation + medium run

    private static func phase2SledSim(week: Int) -> SessionTemplate {
        let longKm: Double = [7: 8, 8: 8, 9: 10, 10: 12, 11: 0, 12: 10][week] ?? 10
        let isHalfSimWeek = week == 11

        if isHalfSimWeek {
            // Week 11 = Half-Hyrox simulation
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "Half-Hyrox Simulation",
                subtitle: "Target: <40:00",
                estimatedDurationSeconds: 60 * 60,
                blocks: [
                    ExerciseBlock(
                        title: "4 × (1 km run + 1 station) at race weights",
                        items: [
                            ExerciseItem(name: "1 km run + Ski Erg 1000 m", sets: 1, distanceMeters: 2_000),
                            ExerciseItem(name: "1 km run + Sled Push 50 m", sets: 1,
                                         weightKg: 152, distanceMeters: 1_050),
                            ExerciseItem(name: "1 km run + Sled Pull 50 m", sets: 1,
                                         weightKg: 103, distanceMeters: 1_050),
                            ExerciseItem(name: "1 km run + Burpee Broad Jumps 40 m", sets: 1,
                                         distanceMeters: 1_040)
                        ]
                    )
                ],
                notes: ["Under 40:00 = on pace for 1:30.",
                        "40–45 min = on pace for 1:35–1:40, still doable.",
                        "Log result via Analytics → Benchmarks."]
            )
        }

        return SessionTemplate(
            id: id(week: week, type: .hyroxCircuit, slot: 5),
            weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
            title: "Sled/Ski Day — Race-Specific Block",
            subtitle: String(format: "~70 min with %.0f km easy run integrated", longKm),
            estimatedDurationSeconds: 70 * 60,
            targetRunDistanceMeters: longKm * 1_000,
            blocks: [
                ExerciseBlock(
                    title: "Warmup",
                    items: [ExerciseItem(name: "Easy run warmup", sets: 1, distanceMeters: 2_000)]
                ),
                ExerciseBlock(
                    title: "Station block (race weights)",
                    items: [
                        ExerciseItem(name: "Ski Erg", sets: 1, distanceMeters: 1_000,
                                     qualifier: "~4:45 goal pace"),
                        ExerciseItem(name: "Easy run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Sled Push", sets: 2, weightKg: 152, distanceMeters: 50,
                                     restSeconds: 120),
                        ExerciseItem(name: "Sled Pull", sets: 2, weightKg: 103, distanceMeters: 50),
                        ExerciseItem(name: "Easy run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Row", sets: 1, distanceMeters: 1_000, qualifier: "~4:50")
                    ]
                )
            ]
        )
    }
}
