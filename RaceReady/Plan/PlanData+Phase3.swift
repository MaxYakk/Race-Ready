import Foundation

// MARK: - Phase 3 — Peak & Race Simulation (Weeks 13–17)
//
// Weekly template: Mon Push (MED) + wallball EMOM · Tue Race-pace 1km + station insertion
//                  · Wed Pull (MED) · Thu Easy + mobility · Fri Legs light
//                  · Sat Sled/Ski full or 3/4 sim · Sun rest
// 5 × 6 = 30 templates.

extension PlanData {

    static var phase3Templates: [SessionTemplate] {
        (13...17).flatMap { week -> [SessionTemplate] in
            [
                phase3Push(week: week),
                phase3RacePace(week: week),
                phase3Pull(week: week),
                phase3EasyRun(week: week),
                phase3Legs(week: week),
                phase3Saturday(week: week)
            ]
        }
    }

    // MARK: Mon — Push (MED) + 10:00 Wall Ball EMOM

    private static func phase3Push(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .pushDay, slot: 0),
            weekNumber: week, sessionType: .pushDay, slot: 0,
            title: "Push (MED) + Wall Ball EMOM",
            subtitle: "Minimum effective dose — 40 min lift",
            estimatedDurationSeconds: 60 * 60,
            blocks: [
                ExerciseBlock(
                    title: "Push — minimum effective dose",
                    items: [
                        ExerciseItem(name: "Bench press", sets: 3, reps: 6, qualifier: "RPE 7"),
                        ExerciseItem(name: "Incline DB press", sets: 3, reps: 8),
                        ExerciseItem(name: "Lateral raise", sets: 3, reps: 12),
                        ExerciseItem(name: "Tricep pulldown", sets: 3, reps: 12)
                    ]
                ),
                ExerciseBlock(
                    title: "Wall-ball EMOM (10 min)",
                    items: [
                        ExerciseItem(name: "Wall ball EMOM", sets: 10, reps: 15, weightKg: 6,
                                     qualifier: "every minute on the minute",
                                     cue: "Practice your race break strategy under fatigue.")
                    ]
                )
            ],
            notes: ["You're not building muscle in Phase 3 — you're maintaining and freshening legs."]
        )
    }

    // MARK: Tue — Race-pace with station insertion

    private static func phase3RacePace(week: Int) -> SessionTemplate {
        let prescription: IntervalPrescription
        var title = "Race-Pace 1 km Repeats"
        var blocks: [ExerciseBlock] = []
        let totalKm: Double

        switch week {
        case 13:
            prescription = .init(reps: 6, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 240, description: "6 × 1 km @ 4:45, 4 min rest (Dearden)")
            totalKm = 8
        case 14:
            prescription = .init(reps: 4, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 0, description: "4 × (1 km @ 4:45 + 25 wall balls)")
            title = "Race-Pace + Wall Ball Insertion"
            blocks.append(ExerciseBlock(
                title: "Station insertion (after each rep)",
                items: [
                    ExerciseItem(name: "Wall ball", sets: 1, reps: 25, weightKg: 6,
                                 cue: "Straight into next 1 km.")
                ]
            ))
            totalKm = 6
        case 15:
            prescription = .init(reps: 8, repDistanceMeters: 800, repTargetPaceSecondsPerKm: 287,
                                 restSeconds: 120, description: "8 × 800 m @ ~3:50, 2 min rest")
            totalKm = 8
        case 16:
            prescription = .init(reps: 5, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 280,
                                 restSeconds: 180, description: "5 × 1 km @ 4:40, 3 min rest")
            totalKm = 7
        case 17:
            prescription = .init(reps: 3, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 120, description: "3 × 1 km @ 4:45, 2 min rest (deload)")
            totalKm = 5
        default:
            prescription = .init(reps: 4, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 120, description: "")
            totalKm = 6
        }

        return SessionTemplate(
            id: id(week: week, type: .thresholdRun, slot: 1),
            weekNumber: week, sessionType: .thresholdRun, slot: 1,
            title: title,
            subtitle: prescription.description,
            estimatedDurationSeconds: 60 * 60,
            intervalPrescription: prescription,
            targetRunDistanceMeters: totalKm * 1_000,
            blocks: blocks
        )
    }

    // MARK: Wed — Pull (MED), occasional 1 km row TT every other week

    private static func phase3Pull(week: Int) -> SessionTemplate {
        let includeRowTT = (week % 2 == 1) // Wk 13, 15, 17

        var blocks: [ExerciseBlock] = [
            ExerciseBlock(
                title: "Pull — minimum effective dose",
                items: [
                    ExerciseItem(name: "Lat pulldown", sets: 3, reps: 8),
                    ExerciseItem(name: "T-bar row", sets: 3, reps: 6),
                    ExerciseItem(name: "DB curl", sets: 3, reps: 10)
                ]
            )
        ]
        if includeRowTT {
            blocks.append(ExerciseBlock(
                title: "1 km Row Time Trial",
                items: [
                    ExerciseItem(name: "Row 1000 m", sets: 1, distanceMeters: 1_000,
                                 cue: "All out — log time in notes.")
                ]
            ))
        }

        return SessionTemplate(
            id: id(week: week, type: .pullDay, slot: 2),
            weekNumber: week, sessionType: .pullDay, slot: 2,
            title: includeRowTT ? "Pull (MED) + 1 km Row TT" : "Pull (MED)",
            subtitle: "40 min — maintain only",
            estimatedDurationSeconds: includeRowTT ? 50 * 60 : 40 * 60,
            blocks: blocks
        )
    }

    // MARK: Thu — Easy run + mobility

    private static func phase3EasyRun(week: Int) -> SessionTemplate {
        let km: Double = [13: 6, 14: 7, 15: 8, 16: 7, 17: 6][week] ?? 7
        return SessionTemplate(
            id: id(week: week, type: .easyRun, slot: 3),
            weekNumber: week, sessionType: .easyRun, slot: 3,
            title: "Easy Run + Mobility",
            subtitle: String(format: "%.0f km Z2 + 10 min mobility", km),
            estimatedDurationSeconds: Int(km * 6 * 60) + 10 * 60,
            targetRunDistanceMeters: km * 1_000
        )
    }

    // MARK: Fri — Legs (light) + sandbag lunge volume

    private static func phase3Legs(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .legsDay, slot: 4),
            weekNumber: week, sessionType: .legsDay, slot: 4,
            title: "Legs (Light) + Sandbag Lunges",
            subtitle: "Freshen legs, don't fatigue them",
            estimatedDurationSeconds: 50 * 60,
            blocks: [
                ExerciseBlock(
                    title: "Legs — maintenance",
                    items: [
                        ExerciseItem(name: "Pendulum squat or hip thrust", sets: 3, reps: 6),
                        ExerciseItem(name: "Bulgarian split squat", sets: 2, reps: 8, qualifier: "each leg"),
                        ExerciseItem(name: "Leg curl", sets: 3, reps: 10),
                        ExerciseItem(name: "Calf raise", sets: 3, reps: 15)
                    ]
                ),
                ExerciseBlock(
                    title: "Sandbag lunge volume",
                    items: [
                        ExerciseItem(name: "Sandbag lunges", sets: 3, weightKg: 20, distanceMeters: 30,
                                     cue: "Race-weight, unbroken.")
                    ]
                )
            ]
        )
    }

    // MARK: Sat — Simulation day (varies by week)

    private static func phase3Saturday(week: Int) -> SessionTemplate {
        switch week {
        case 13:
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "5-Station Simulation",
                subtitle: "Goal: 45 min",
                estimatedDurationSeconds: 60 * 60,
                blocks: [
                    ExerciseBlock(title: "Ski 1000m → 1km → Push 50m → 1km → Pull 50m → 1km → BBJ 80m → 1km → Row 1000m", items: [
                        ExerciseItem(name: "Ski Erg", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Sled Push", sets: 1, weightKg: 152, distanceMeters: 50),
                        ExerciseItem(name: "Run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Sled Pull", sets: 1, weightKg: 103, distanceMeters: 50),
                        ExerciseItem(name: "Run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Burpee Broad Jump", sets: 1, distanceMeters: 80),
                        ExerciseItem(name: "Run", sets: 1, distanceMeters: 1_000),
                        ExerciseItem(name: "Row", sets: 1, distanceMeters: 1_000)
                    ])
                ]
            )
        case 14:
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "7/8 Hyrox Simulation (skip row)",
                subtitle: "Goal: 60 min",
                estimatedDurationSeconds: 70 * 60,
                blocks: [
                    ExerciseBlock(title: "All stations except row, race order", items: [
                        ExerciseItem(name: "Run + Ski Erg 1000 m", sets: 1, distanceMeters: 2_000),
                        ExerciseItem(name: "Run + Sled Push 50 m", sets: 1, weightKg: 152, distanceMeters: 1_050),
                        ExerciseItem(name: "Run + Sled Pull 50 m", sets: 1, weightKg: 103, distanceMeters: 1_050),
                        ExerciseItem(name: "Run + BBJ 80 m", sets: 1, distanceMeters: 1_080),
                        ExerciseItem(name: "Run + Farmers Carry 200 m", sets: 1, weightKg: 24, distanceMeters: 1_200),
                        ExerciseItem(name: "Run + Sandbag Lunges 100 m", sets: 1, weightKg: 20, distanceMeters: 1_100),
                        ExerciseItem(name: "Run + Wall Balls 100", sets: 1, weightKg: 6, distanceMeters: 1_000)
                    ])
                ]
            )
        case 15:
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "FULL HYROX SIMULATION",
                subtitle: "Time-trial — Goal: 1:30:00 or faster",
                estimatedDurationSeconds: 100 * 60,
                blocks: [
                    ExerciseBlock(title: "Race-day order, full distance, race weights", items: [
                        ExerciseItem(name: "Run 1 + Ski Erg 1000 m", sets: 1, distanceMeters: 2_000),
                        ExerciseItem(name: "Run 2 + Sled Push 50 m", sets: 1, weightKg: 152, distanceMeters: 1_050),
                        ExerciseItem(name: "Run 3 + Sled Pull 50 m", sets: 1, weightKg: 103, distanceMeters: 1_050),
                        ExerciseItem(name: "Run 4 + Burpee Broad Jump 80 m", sets: 1, distanceMeters: 1_080),
                        ExerciseItem(name: "Run 5 + Row 1000 m", sets: 1, distanceMeters: 2_000),
                        ExerciseItem(name: "Run 6 + Farmers Carry 200 m", sets: 1, weightKg: 24, distanceMeters: 1_200),
                        ExerciseItem(name: "Run 7 + Sandbag Lunges 100 m", sets: 1, weightKg: 20, distanceMeters: 1_100),
                        ExerciseItem(name: "Run 8 + Wall Balls 100", sets: 1, weightKg: 6, distanceMeters: 1_000)
                    ])
                ],
                notes: ["Test shoes (cross-trainers), wall-ball break strategy, and pacing.",
                        "Hit 1:30–1:35 here → race day likely 5–10% faster.",
                        "Log time in Analytics → Benchmarks → Full Hyrox Sim."]
            )
        case 16:
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "4-Station Race-Intensity Practice",
                subtitle: "BBJ · Lunges · Wall Balls · Sled Push",
                estimatedDurationSeconds: 50 * 60,
                blocks: [
                    ExerciseBlock(title: "Race intensity, full station distance", items: [
                        ExerciseItem(name: "Burpee Broad Jump", sets: 1, distanceMeters: 80),
                        ExerciseItem(name: "Sandbag Lunges", sets: 1, weightKg: 20, distanceMeters: 100),
                        ExerciseItem(name: "Wall Balls", sets: 1, reps: 100, weightKg: 6),
                        ExerciseItem(name: "Sled Push", sets: 1, weightKg: 152, distanceMeters: 50)
                    ])
                ]
            )
        default: // Week 17 — deload taper-prep
            return SessionTemplate(
                id: id(week: week, type: .hyroxCircuit, slot: 5),
                weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
                title: "Easy 6 km + Light Station Practice",
                subtitle: "Deload — sharpen, don't fatigue",
                estimatedDurationSeconds: 50 * 60,
                targetRunDistanceMeters: 6_000,
                blocks: [
                    ExerciseBlock(title: "Easy run", items: [
                        ExerciseItem(name: "Easy run Z2", sets: 1, distanceMeters: 6_000)
                    ]),
                    ExerciseBlock(title: "Form-only station touches", items: [
                        ExerciseItem(name: "Wall ball", sets: 2, reps: 15, weightKg: 6, qualifier: "form only"),
                        ExerciseItem(name: "Burpee broad jump", sets: 2, distanceMeters: 20, qualifier: "form only"),
                        ExerciseItem(name: "Sandbag lunges", sets: 2, weightKg: 20, distanceMeters: 20, qualifier: "form only")
                    ])
                ]
            )
        }
    }
}
