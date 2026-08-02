import Foundation

// MARK: - Phase 4 — Taper (Week 18, Sep 15–18)
//
// 3 sessions only (Mon, Wed, Thu race day). 40–50% volume cut, intensity preserved.

extension PlanData {

    static var phase4Templates: [SessionTemplate] {
        [
            // Mon Sep 15
            SessionTemplate(
                id: id(week: 18, type: .easyRun, slot: 0),
                weekNumber: 18, sessionType: .easyRun, slot: 0,
                title: "Easy 4 km + Strides + Light Wall Ball",
                subtitle: "Short sharp pre-taper opener",
                estimatedDurationSeconds: 45 * 60,
                targetRunDistanceMeters: 4_000,
                blocks: [
                    ExerciseBlock(title: "Run", items: [
                        ExerciseItem(name: "Easy Z2 run", sets: 1, distanceMeters: 4_000),
                        ExerciseItem(name: "Strides", sets: 5, distanceMeters: 100,
                                     qualifier: "fast but relaxed")
                    ]),
                    ExerciseBlock(title: "Wall ball — light", items: [
                        ExerciseItem(name: "Wall ball", sets: 3, reps: 10, weightKg: 6,
                                     qualifier: "form check, no fatigue")
                    ])
                ],
                notes: ["NO heavy lifting after Sep 13.",
                        "Carb-emphasis Wed/Thu (oats, rice, pasta). Reduce fiber Wed/Thu."]
            ),
            // Wed Sep 17
            SessionTemplate(
                id: id(week: 18, type: .easyRun, slot: 1),
                weekNumber: 18, sessionType: .easyRun, slot: 1,
                title: "20 min Jog + Race-Pace Strides",
                subtitle: "Final shakeout — sharpness, not fatigue",
                estimatedDurationSeconds: 30 * 60,
                targetRunDistanceMeters: 3_000,
                blocks: [
                    ExerciseBlock(title: "Shakeout", items: [
                        ExerciseItem(name: "Easy jog", sets: 1, distanceMeters: 3_000),
                        ExerciseItem(name: "Race-pace strides", sets: 3, distanceMeters: 200,
                                     qualifier: "race-pace")
                    ]),
                    ExerciseBlock(title: "Form-only station touches (5 reps each)", items: [
                        ExerciseItem(name: "Wall ball", sets: 1, reps: 5, weightKg: 6),
                        ExerciseItem(name: "Burpee broad jump", sets: 1, reps: 5),
                        ExerciseItem(name: "Sandbag lunges", sets: 1, weightKg: 20, distanceMeters: 10)
                    ])
                ],
                notes: ["Hydrate aggressively. No new foods.",
                        "Race-morning meal 2–3 hr pre-race: oats + banana + PB, or toast + jam + eggs."]
            ),
            // Thu Sep 18 — RACE DAY
            SessionTemplate(
                id: id(week: 18, type: .hyroxCircuit, slot: 2),
                weekNumber: 18, sessionType: .hyroxCircuit, slot: 2,
                title: "🏁 RACE DAY",
                subtitle: "Hyrox — Target Sub 1:30",
                estimatedDurationSeconds: 90 * 60,
                blocks: [
                    ExerciseBlock(title: "Race-day execution plan",
                                  subtitle: "See Plan tab → Race Day for per-station splits",
                                  items: [
                                    ExerciseItem(name: "Run 1", sets: 1, distanceMeters: 1_000,
                                                 qualifier: "4:45 — embarrassingly easy"),
                                    ExerciseItem(name: "Ski Erg", sets: 1, distanceMeters: 1_000,
                                                 qualifier: "4:45 (~2:22/500m)"),
                                    ExerciseItem(name: "Sled Push", sets: 1, weightKg: 152,
                                                 distanceMeters: 50, qualifier: "3:00"),
                                    ExerciseItem(name: "Sled Pull", sets: 1, weightKg: 103,
                                                 distanceMeters: 50, qualifier: "4:30"),
                                    ExerciseItem(name: "Burpee Broad Jump", sets: 1, distanceMeters: 80,
                                                 qualifier: "4:30"),
                                    ExerciseItem(name: "Row", sets: 1, distanceMeters: 1_000,
                                                 qualifier: "4:50"),
                                    ExerciseItem(name: "Farmers Carry", sets: 1, weightKg: 24,
                                                 distanceMeters: 200, qualifier: "2:20 unbroken"),
                                    ExerciseItem(name: "Sandbag Lunges", sets: 1, weightKg: 20,
                                                 distanceMeters: 100, qualifier: "4:30 unbroken"),
                                    ExerciseItem(name: "Wall Balls", sets: 1, reps: 100, weightKg: 6,
                                                 qualifier: "5:30 · 20-15-15-15-15-10-10")
                                  ])
                ],
                notes: ["Run 1 must feel embarrassingly easy.",
                        "RoxZone discipline: <10 min total transitions.",
                        "Empty the tank on Run 8."]
            )
        ]
    }
}
