import Foundation

/// Static race-day execution plan, transcribed from the PDF (pp. 10–11).
/// Surfaced in the Plan tab via `RaceDayPlanView`.
public enum RaceDayPlan {

    public struct Split: Identifiable, Hashable {
        public var id: String { name }
        public let name: String
        /// Target seconds for this segment.
        public let targetSeconds: Int
        /// Pace target (seconds per km) for run segments; nil for stations.
        public let paceSecondsPerKm: Int?
        /// Coaching cue.
        public let cue: String?
    }

    /// 8 runs + 8 stations in race order. Target total = 1:30:00.
    public static let splits: [Split] = [
        .init(name: "Run 1 (1 km)", targetSeconds: 285,    paceSecondsPerKm: 285,
              cue: "Embarrassingly easy — controlled jog."),
        .init(name: "Ski Erg (1000 m)", targetSeconds: 285, paceSecondsPerKm: nil,
              cue: "Lats and hips, not shoulders. Don't sprint the first 200 m."),
        .init(name: "Run 2 (1 km)", targetSeconds: 300,    paceSecondsPerKm: 300,
              cue: "Arms will be warm."),
        .init(name: "Sled Push (50 m)", targetSeconds: 180, paceSecondsPerKm: nil,
              cue: "Two 25 m segments with 5 s reset. Stay low, short fast steps."),
        .init(name: "Run 3 (1 km)", targetSeconds: 305,    paceSecondsPerKm: 305,
              cue: nil),
        .init(name: "Sled Pull (50 m)", targetSeconds: 270, paceSecondsPerKm: nil,
              cue: "Sit back, hand-over-hand, drive heels."),
        .init(name: "Run 4 (1 km)", targetSeconds: 310,    paceSecondsPerKm: 310,
              cue: nil),
        .init(name: "Burpee Broad Jump (80 m)", targetSeconds: 270, paceSecondsPerKm: nil,
              cue: "Consistent 8 s reps beat a fast start and death-march finish."),
        .init(name: "Run 5 (1 km)", targetSeconds: 310,    paceSecondsPerKm: 310,
              cue: nil),
        .init(name: "Row (1000 m)", targetSeconds: 290,    paceSecondsPerKm: nil,
              cue: "Long strokes, leg drive."),
        .init(name: "Run 6 (1 km)", targetSeconds: 310,    paceSecondsPerKm: 310,
              cue: nil),
        .init(name: "Farmers Carry (200 m)", targetSeconds: 140, paceSecondsPerKm: nil,
              cue: "Don't put the kettlebells down."),
        .init(name: "Run 7 (1 km)", targetSeconds: 315,    paceSecondsPerKm: 315,
              cue: nil),
        .init(name: "Sandbag Lunges (100 m)", targetSeconds: 270, paceSecondsPerKm: nil,
              cue: "Attack — data confirms it doesn't cost Run 8."),
        .init(name: "Run 8 (1 km)", targetSeconds: 320,    paceSecondsPerKm: 320,
              cue: "Empty the tank."),
        .init(name: "Wall Balls (100 reps)", targetSeconds: 330, paceSecondsPerKm: nil,
              cue: "Break 20-15-15-15-15-10-10. Stand 30–50 cm from wall."),
    ]

    public static let transitionTargetSeconds: Int = 600 // <10 min total
    public static let totalTargetSeconds: Int = 5_400    // 1:30:00

    public static let commonMistakes: [String] = [
        "Going out too hot on Run 1 — single biggest race-killer.",
        "Standing still in the RoxZone — costs 5–12 min.",
        "Wall balls to failure — once you set the ball down out of plan, you're cooked.",
        "Wrong shoes — wear cross-trainers, not road runners.",
        "Pacing Ski Erg by feel — adrenaline makes 2:00/500m feel like 2:20.",
        "Not practicing transitions in training — practice every Saturday simulation."
    ]
}
