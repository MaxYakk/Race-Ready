import Foundation

// MARK: - Phase 1 — Base Build (Weeks 1–6)
//
// Weekly template: Mon Push+skill · Tue Easy run · Wed Pull+row · Thu Tempo/interval
//                  · Fri Legs · Sat Long run + ski/sled · Sun rest
// 6 sessions × 6 weeks = 36 templates.

extension PlanData {

    static var phase1Templates: [SessionTemplate] {
        (1...6).flatMap { week -> [SessionTemplate] in
            [
                phase1Push(week: week),
                phase1EasyRun(week: week),
                phase1Pull(week: week),
                phase1Threshold(week: week),
                phase1Legs(week: week),
                phase1HyroxCircuit(week: week)  // Saturday "long run + ski/sled"
            ]
        }
    }

    // MARK: Mon — Push + skill

    private static func phase1Push(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .pushDay, slot: 0),
            weekNumber: week, sessionType: .pushDay, slot: 0,
            title: "Push + Wall-Ball Skill",
            subtitle: "Skill primer while fresh",
            estimatedDurationSeconds: 75 * 60,
            blocks: [
                pushMain(),
                ExerciseBlock(
                    title: "Skill block — Wall-ball technique",
                    subtitle: "15 min",
                    items: [
                        ExerciseItem(name: "Wall ball technique",
                                     sets: 3, reps: 15, weightKg: 6,
                                     restSeconds: 60,
                                     qualifier: "to 10 ft target",
                                     cue: "Hip drive, arm's length from wall.")
                    ]
                ),
                lowerLegFinisher
            ],
            notes: ["Lift first when paired with running later in the day (>6h gap ideal)."]
        )
    }

    // MARK: Tue — Easy run (Z2)

    private static func phase1EasyRun(week: Int) -> SessionTemplate {
        let kmByWeek: [Int: Double] = [1: 4, 2: 5, 3: 5, 4: 4, 5: 6, 6: 6]
        let km = kmByWeek[week] ?? 5
        return SessionTemplate(
            id: id(week: week, type: .easyRun, slot: 1),
            weekNumber: week, sessionType: .easyRun, slot: 1,
            title: "Easy Run · Z2",
            subtitle: String(format: "%.0f km @ talk-test pace (~5:30–6:00/km)", km),
            estimatedDurationSeconds: Int(km * 6 * 60),
            targetRunDistanceMeters: km * 1_000,
            notes: ["≤75% max HR. Full sentences while running.",
                    "Most aerobic gains are lost when Z2 is run too fast."]
        )
    }

    // MARK: Wed — Pull + row finisher

    private static func phase1Pull(week: Int) -> SessionTemplate {
        SessionTemplate(
            id: id(week: week, type: .pullDay, slot: 2),
            weekNumber: week, sessionType: .pullDay, slot: 2,
            title: "Pull + Grip + 500 m Row",
            subtitle: "Sled-pull insurance",
            estimatedDurationSeconds: 60 * 60,
            blocks: [pullMainPhase1, pullFinisher, lowerLegFinisher]
        )
    }

    // MARK: Thu — Tempo / Interval

    private static func phase1Threshold(week: Int) -> SessionTemplate {
        let prescription: IntervalPrescription
        let totalKm: Double
        switch week {
        case 1:
            prescription = .init(reps: 4, repDistanceMeters: 400, repTargetPaceSecondsPerKm: 263,
                                 restSeconds: 90,
                                 description: "4 × 400 m @ 5K pace, 90 s rest (warm/cool incl.)")
            totalKm = 3.5
        case 2:
            prescription = .init(reps: 3, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 285,
                                 restSeconds: 90,
                                 description: "3 × 1 km @ ~4:45, 90 s rest")
            totalKm = 5
        case 3:
            prescription = .init(reps: 5, repDistanceMeters: 400, repTargetPaceSecondsPerKm: 263,
                                 restSeconds: 105,
                                 description: "5 × 400 m @ ~1:45, 90 s rest")
            totalKm = 5
        case 4:
            prescription = .init(reps: 1, repDistanceMeters: 2_000, repTargetPaceSecondsPerKm: 270,
                                 restSeconds: 0,
                                 description: "2 km tempo @ ~4:30 + 1 km easy (deload)")
            totalKm = 4
        case 5:
            prescription = .init(reps: 4, repDistanceMeters: 1_000, repTargetPaceSecondsPerKm: 280,
                                 restSeconds: 120,
                                 description: "4 × 1 km @ ~4:40, 2 min rest")
            totalKm = 6
        case 6:
            prescription = .init(reps: 6, repDistanceMeters: 400, repTargetPaceSecondsPerKm: 250,
                                 restSeconds: 90,
                                 description: "6 × 400 m @ ~1:40, 90 s rest")
            totalKm = 5
        default:
            prescription = .init(reps: 4, repDistanceMeters: 400, repTargetPaceSecondsPerKm: 270,
                                 restSeconds: 90, description: "")
            totalKm = 4
        }
        return SessionTemplate(
            id: id(week: week, type: .thresholdRun, slot: 3),
            weekNumber: week, sessionType: .thresholdRun, slot: 3,
            title: "Threshold / Intervals",
            subtitle: prescription.description,
            estimatedDurationSeconds: 45 * 60,
            intervalPrescription: prescription,
            targetRunDistanceMeters: totalKm * 1_000,
            notes: ["Warm up 10 min easy + 4 × 30 s strides before first rep."]
        )
    }

    // MARK: Fri — Legs (alternating quad/posterior)

    private static func phase1Legs(week: Int) -> SessionTemplate {
        let isQuadBias = (week % 2 == 1) // Weeks 1, 3, 5 → quad; 2, 4, 6 → posterior
        let wallBallVolume = [1: 100, 2: 150, 3: 200, 4: 150, 5: 250, 6: 300][week] ?? 200

        let mainBlock: ExerciseBlock
        if isQuadBias {
            mainBlock = ExerciseBlock(
                title: "Legs — quad bias",
                subtitle: "60 min",
                items: [
                    ExerciseItem(name: "Pendulum (or hack) squat", sets: 4, repsLow: 8, repsHigh: 10),
                    ExerciseItem(name: "Bulgarian split squat", sets: 3, repsLow: 8, repsHigh: 8, qualifier: "each leg"),
                    ExerciseItem(name: "Leg extension", sets: 3, reps: 12),
                    ExerciseItem(name: "Standing calf raise", sets: 4, reps: 12)
                ]
            )
        } else {
            mainBlock = ExerciseBlock(
                title: "Legs — posterior / glute",
                subtitle: "60 min",
                items: [
                    ExerciseItem(name: "Hip thrust (or glute press)", sets: 4, reps: 10),
                    ExerciseItem(name: "Romanian DB deadlift", sets: 4, repsLow: 8, repsHigh: 10),
                    ExerciseItem(name: "Lying leg curl", sets: 3, reps: 12),
                    ExerciseItem(name: "Hip abductor", sets: 3, reps: 15),
                    ExerciseItem(name: "Seated calf raise", sets: 4, reps: 15),
                    ExerciseItem(name: "Walking lunges", sets: 4, weightKg: 20, distanceMeters: 20,
                                 qualifier: "DBs in front rack")
                ]
            )
        }

        let wallBallBlock = ExerciseBlock(
            title: "Wall-ball volume (10 min)",
            subtitle: "Total: \(wallBallVolume) reps",
            items: [
                ExerciseItem(name: "Wall ball", sets: 5, reps: wallBallVolume / 5,
                             weightKg: 6, restSeconds: 60,
                             cue: "Pace breaks, don't go to failure.")
            ]
        )

        return SessionTemplate(
            id: id(week: week, type: .legsDay, slot: 4),
            weekNumber: week, sessionType: .legsDay, slot: 4,
            title: isQuadBias ? "Legs (Quad) + Wall-Ball Volume" : "Legs (Posterior) + Wall-Ball Volume",
            subtitle: "Leg hypertrophy + skill",
            estimatedDurationSeconds: 70 * 60,
            blocks: [mainBlock, wallBallBlock, lowerLegFinisher]
        )
    }

    // MARK: Sat — Long run + Ski/Sled

    private static func phase1HyroxCircuit(week: Int) -> SessionTemplate {
        let longRunKm: Double = [1: 6, 2: 7, 3: 8, 4: 6, 5: 9, 6: 10][week] ?? 8

        var stations: [ExerciseItem] = []

        // Ski Erg progression
        if week <= 2 {
            stations.append(ExerciseItem(
                name: "Ski Erg — learning", sets: 5, distanceMeters: 250,
                restSeconds: 60,
                cue: "Full hip hinge, lats-not-arms, exhale on the pull."))
        } else {
            stations.append(ExerciseItem(
                name: "Ski Erg — base", sets: 4, distanceMeters: 500,
                restSeconds: 90,
                qualifier: "~2:10/500m",
                cue: "Pacing > power."))
        }

        // Sled push progression
        let pushKg: Double = [1: 70, 2: 70, 3: 90, 4: 90, 5: 110, 6: 120][week] ?? 90
        let pushMeters: Double = week <= 4 ? 25 : 50
        stations.append(ExerciseItem(
            name: "Sled Push", sets: 4, weightKg: pushKg, distanceMeters: pushMeters,
            restSeconds: 90,
            cue: "Stay low, arms locked, hips below shoulders, short fast steps."))

        // Sled pull progression
        let pullKg: Double = [1: 50, 2: 50, 3: 70, 4: 70, 5: 90, 6: 90][week] ?? 70
        let pullMeters: Double = week <= 2 ? 25 : 50
        stations.append(ExerciseItem(
            name: "Sled Pull", sets: 4, weightKg: pullKg, distanceMeters: pullMeters,
            restSeconds: 90,
            cue: "Hand-over-hand, drive heels into floor."))

        return SessionTemplate(
            id: id(week: week, type: .hyroxCircuit, slot: 5),
            weekNumber: week, sessionType: .hyroxCircuit, slot: 5,
            title: "Long Run + Ski/Sled",
            subtitle: String(format: "%.0f km Z2 then station work", longRunKm),
            estimatedDurationSeconds: 90 * 60,
            targetRunDistanceMeters: longRunKm * 1_000,
            blocks: [
                ExerciseBlock(
                    title: "Long run",
                    items: [
                        ExerciseItem(name: "Easy Z2 run", sets: 1,
                                     distanceMeters: longRunKm * 1_000,
                                     cue: "10 min warmup → drive to facility.")
                    ]
                ),
                ExerciseBlock(title: "Ski / Sled block", items: stations)
            ],
            notes: week == 6 ? ["Week 6 ends with benchmark tests — see Plan tab."] : []
        )
    }
}
