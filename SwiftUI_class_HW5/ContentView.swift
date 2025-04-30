import SwiftUI

struct ContentView: View {
    @State var player1Score = 0
    @State var player2Score = 0
    @State var currentTurnScore = 0

    @State var die1a = 1
    @State var die1b = 1
    @State var die2a = 1
    @State var die2b = 1

    @State var currentPlayer = 1
    @State var gameOver = false
    @State var winnerName = ""
    @State var isVsAI = false
    @State var isTwoDiceMode = false
    @State var mustRollAgain = false

    var player1ImageName: String {
        let bestRoll = isTwoDiceMode ? max(die1a, die1b) : die1a
        return "face_\(bestRoll)"
    }

    var player2ImageName: String {
        let bestRoll = isTwoDiceMode ? max(die2a, die2b) : die2a
        return "face_\(bestRoll)"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.79, green: 0.10, blue: 0.39),// 粉紅色
                    Color(red: 1, green: 1, blue: 1),
                    Color(red: 102/255, green: 179/255, blue: 255/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                GameControlBar(isVsAI: $isVsAI, isTwoDiceMode: $isTwoDiceMode) {
                    resetAllState()
                }

                HStack(spacing: 24) {
                    PlayerView(name: "Player 1", score: player1Score, image: player1ImageName, highlight: currentPlayer == 1, progressColor: .green)
                    PlayerView(name: isVsAI ? "AI" : "Player 2", score: player2Score, image: player2ImageName, highlight: currentPlayer == 2, progressColor: .purple)
                }

                HStack(spacing: 40) {
                    DiceView(d1: die1a, d2: die1b, isTwoDice: isTwoDiceMode)
                    DiceView(d1: die2a, d2: die2b, isTwoDice: isTwoDiceMode)
                }

                Text("目前回合分數：\(currentTurnScore)").font(.headline)

                ControlPanelView(
                    currentPlayer: $currentPlayer,
                    gameOver: $gameOver,
                    mustRollAgain: $mustRollAgain,
                    isVsAI: $isVsAI,
                    currentTurnScore: $currentTurnScore,
                    player1Score: $player1Score,
                    player2Score: $player2Score,
                    die1a: $die1a,
                    die1b: $die1b,
                    die2a: $die2a,
                    die2b: $die2b,
                    winnerName: $winnerName,
                    isTwoDiceMode: $isTwoDiceMode,
                    aiAutoPlay: aiAutoPlay
                )

                if gameOver {
                    VictoryBannerView(winnerName: winnerName)
                }
            }
        }
    }

    func resetAllState() {
        player1Score = 0
        player2Score = 0
        currentTurnScore = 0
        die1a = 1
        die1b = 1
        die2a = 1
        die2b = 1
        currentPlayer = 1
        gameOver = false
        winnerName = ""
        mustRollAgain = false
    }

    func aiAutoPlay() {
        guard !gameOver && currentPlayer == 2 else { return }
        let d1 = Int.random(in: 1...6)
        let d2 = Int.random(in: 1...6)
        die2a = d1
        die2b = d2

        if isTwoDiceMode {
            if d1 == 1 && d2 == 1 {
                player2Score = 0
                currentTurnScore = 0
                currentPlayer = 1
                mustRollAgain = false
                return
            } else if d1 == 1 || d2 == 1 {
                currentTurnScore = 0
                currentPlayer = 1
                mustRollAgain = false
                return
            } else {
                currentTurnScore += d1 + d2
                mustRollAgain = d1 == d2
            }
        } else {
            if d1 == 1 {
                currentTurnScore = 0
                currentPlayer = 1
                mustRollAgain = false
                return
            } else {
                currentTurnScore += d1
                mustRollAgain = false
            }
        }

        if currentTurnScore >= 10 && !mustRollAgain {
            player2Score += currentTurnScore
            currentTurnScore = 0
            if player2Score >= 100 {
                winnerName = "AI"
                gameOver = true
            } else {
                currentPlayer = 1
                mustRollAgain = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                aiAutoPlay()
            }
        }
    }
}

struct PlayerView: View {
    let name: String
    let score: Int
    let image: String
    let highlight: Bool
    let progressColor: Color

    var body: some View {
        HStack(spacing: 8) {
            // 進度條
            VStack {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 25, height: 150)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(progressColor)
                        .frame(width: 20, height: CGFloat(min(score, 100)) / 100 * 150)
                }
                Text("\(min(score, 100))")
                    .font(.caption)
            }

            // 玩家資訊卡
            VStack {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                Text("得分: \(score)")
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .padding()
            .background(highlight ? Color.yellow.opacity(0.3) : Color.clear)
            .cornerRadius(10)
        }
        .frame(width: 160)
    }
}


struct DiceView: View {
    let d1: Int
    let d2: Int
    let isTwoDice: Bool

    var body: some View {
        HStack {
            Image(systemName: "die.face.\(d1).fill").resizable().scaledToFit().frame(width: 50, height: 50)
            if isTwoDice {
                Image(systemName: "die.face.\(d2).fill").resizable().scaledToFit().frame(width: 50, height: 50)
            }
        }
    }
}

struct ControlPanelView: View {
    @Binding var currentPlayer: Int
    @Binding var gameOver: Bool
    @Binding var mustRollAgain: Bool
    @Binding var isVsAI: Bool
    @Binding var currentTurnScore: Int
    @Binding var player1Score: Int
    @Binding var player2Score: Int
    @Binding var die1a: Int
    @Binding var die1b: Int
    @Binding var die2a: Int
    @Binding var die2b: Int
    @Binding var winnerName: String
    @Binding var isTwoDiceMode: Bool
    let aiAutoPlay: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            VStack {
                Button("Player 1 Roll") {
                    die1a = Int.random(in: 1...6)
                    die1b = Int.random(in: 1...6)
                    let d1 = die1a
                    let d2 = die1b
                    if isTwoDiceMode {
                        if d1 == 1 && d2 == 1 {
                            player1Score = 0
                            currentTurnScore = 0
                            currentPlayer = 2
                            mustRollAgain = false
                        } else if d1 == 1 || d2 == 1 {
                            currentTurnScore = 0
                            currentPlayer = 2
                            mustRollAgain = false
                        } else {
                            currentTurnScore += d1 + d2
                            mustRollAgain = d1 == d2
                        }
                    } else {
                        if d1 == 1 {
                            currentTurnScore = 0
                            currentPlayer = 2
                            mustRollAgain = false
                        } else {
                            currentTurnScore += d1
                            mustRollAgain = false
                        }
                    }
                    if isVsAI && currentPlayer == 2 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            aiAutoPlay()
                        }
                    }
                }
                .frame(width: 110)
                .disabled(currentPlayer != 1 || gameOver)
                .padding()
                .background(Color.green).foregroundColor(.white).cornerRadius(10)
                


                Button("Player 1 Hold") {
                    player1Score += currentTurnScore
                    if player1Score >= 100 {
                        winnerName = "Player 1"
                        gameOver = true
                    } else {
                        currentTurnScore = 0
                        currentPlayer = 2
                        mustRollAgain = false
                        if isVsAI {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                aiAutoPlay()
                            }
                        }
                    }
                }
                .frame(width: 110)
                .disabled(currentPlayer != 1 || mustRollAgain || gameOver)
                .padding()
                .background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }

            VStack {
                Button(isVsAI ? "AI Roll" : "Player 2 Roll") {
                    die2a = Int.random(in: 1...6)
                    die2b = Int.random(in: 1...6)
                    let d1 = die2a
                    let d2 = die2b
                    if isTwoDiceMode {
                        if d1 == 1 && d2 == 1 {
                            player2Score = 0
                            currentTurnScore = 0
                            currentPlayer = 1
                            mustRollAgain = false
                        } else if d1 == 1 || d2 == 1 {
                            currentTurnScore = 0
                            currentPlayer = 1
                            mustRollAgain = false
                        } else {
                            currentTurnScore += d1 + d2
                            mustRollAgain = d1 == d2
                        }
                    } else {
                        if d1 == 1 {
                            currentTurnScore = 0
                            currentPlayer = 1
                            mustRollAgain = false
                        } else {
                            currentTurnScore += d1
                            mustRollAgain = false
                        }
                    }
                }
                .frame(width: 110)
                .disabled(currentPlayer != 2 || gameOver || isVsAI)
                .padding()
                .background(Color.green).foregroundColor(.white).cornerRadius(10)

                Button(isVsAI ? "AI Hold" : "Player 2 Hold") {
                    player2Score += currentTurnScore
                    if player2Score >= 100 {
                        winnerName = isVsAI ? "AI" : "Player 2"
                        gameOver = true
                    } else {
                        currentTurnScore = 0
                        currentPlayer = 1
                        mustRollAgain = false
                    }
                }
                .frame(width: 110)
                .disabled(currentPlayer != 2 || mustRollAgain || gameOver || isVsAI)
                .padding()
                .background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
        }
    }
}

struct GameControlBar: View {
    @Binding var isVsAI: Bool
    @Binding var isTwoDiceMode: Bool
    let onReset: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Toggle("與電腦對戰", isOn: Binding(
                    get: { isVsAI },
                    set: {
                        isVsAI = $0
                        onReset()
                    }))
                Toggle("雙骰模式", isOn: Binding(
                    get: { isTwoDiceMode },
                    set: {
                        isTwoDiceMode = $0
                        onReset()
                    }))
            }
            Spacer()
            Button("↻ Replay", action: onReset)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct VictoryBannerView: View {
    let winnerName: String

    var body: some View {
        Text("🎉 \(winnerName) 獲勝！ 🎉")
            .font(.title2)
            .bold()
            .padding(.top, 8)
    }
}

#Preview {
    ContentView()
}
