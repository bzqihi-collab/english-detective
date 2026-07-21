# 英语侦探社 — Prototype 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个可在 iPad 上运行的交互 prototype，验证"侦探破案"核心玩法循环和暖调案卷风视觉设计。

**Architecture:** SwiftUI 原生 iPad App，MVVM 模式。单屏导航（NavigationStack 驱动五步流程），无后端、无持久化、语音交互用点击模拟。所有数据硬编码一个完整的教材单元（PEP 三上 Unit 4: Animals）。

**Tech Stack:** SwiftUI, Swift 5.9+, Xcode 15+, iOS 17+ (iPadOS 17+)

**Scope (prototype — what's IN):**
- 🏢 主界面（事务所大厅）：角色卡 + 今日任务 + 案件入口 + 悬赏令
- 📋→🔍→🎤→✍️→🏆 完整五步破案流程（一个 Case 的 happy path）
- 📂 冷案档案室（静态展示，可点击触发简单复习动画）
- 🎨 完整视觉设计落地（颜色/字体/圆角/卡片风格）
- 🎬 3 个关键动画：接案密函 → 证物收集 → 庆祝烟花
- 📦 硬编码数据：人教版 PEP 三年级上 Unit 4 Animals（5 个单词 + 3 个句子）

**Out of scope (for later):**
- 真实语音识别（用点击按钮模拟"说出单词"）
- 教材切换、家长功能、数据持久化
- 艾宾浩斯算法、每日任务刷新、经验/金币系统
- 徽章收藏册、装备系统、越狱 Boss 战完整逻辑
- iPad 横竖屏自适应（先固定横屏）

---

## 文件结构

```
english-detective/
├── EnglishDetective.xcodeproj
├── EnglishDetective/
│   ├── EnglishDetectiveApp.swift         # @main 入口
│   ├── Theme/
│   │   └── DesignTokens.swift            # 颜色/字体/圆角常量
│   ├── Models/
│   │   ├── Word.swift                    # 单词数据模型
│   │   ├── Case.swift                    # 案件 + 句子数据模型
│   │   ├── GameState.swift               # @ObservableObject 全局状态
│   │   └── MockData.swift               # 硬编码 PEP 三上 Unit 4 数据
│   ├── Views/
│   │   ├── MainOfficeView.swift          # 事务所主界面
│   │   ├── CaseBriefingView.swift        # 步骤 1：接案密函
│   │   ├── InvestigationView.swift       # 步骤 2：搜证现场
│   │   ├── InterrogationView.swift       # 步骤 3：审讯对话
│   │   ├── CaseReportView.swift          # 步骤 4：结案报告
│   │   ├── CelebrationView.swift         # 步骤 5：庆祝结算
│   │   ├── ColdCaseView.swift            # 冷案档案室
│   │   └── Components/
│   │       ├── WordCard.swift            # 单词展示卡片
│   │       ├── ProgressBar.swift         # 进度条
│   │       ├── StatusTag.swift           # 状态标签（绿/琥珀/红）
│   │       └── DetectiveButton.swift     # 主题按钮（主/次/强调）
│   └── Assets.xcassets/                  # 颜色 + 图片资源
```

---

## 数据模型设计

### Word.swift

```swift
struct Word: Identifiable, Equatable {
    let id = UUID()
    let english: String      // "cat"
    let phonetic: String     // "/kæt/"
    let chinese: String      // "猫"
    let emoji: String        // "🐱"
    let exampleSentence: String // "I have a cat."
}

enum WordProficiency {
    case mastered     // 绿色 - 已掌握
    case weak         // 琥珀 - 需要练习
    case forgotten    // 红色 - 危险遗忘
}
```

### Case.swift

```swift
struct DetectiveCase: Identifiable {
    let id = UUID()
    let caseNumber: Int           // 4
    let title: String             // "失踪的动物园动物"
    let subtitle: String          // "Unit 4: Animals"
    let briefing: String          // 案情描述段落
    let words: [Word]             // 5 个单词
    let sentences: [String]       // 3 个跟读句子
    let sceneEmojis: [String]     // 搜证场景中的动物 emoji 列表
    let isUnlocked: Bool
}
```

### GameState.swift

```swift
class GameState: ObservableObject {
    @Published var detectiveName: String = "小明"
    @Published var detectiveRank: String = "初级侦探"
    @Published var experience: Int = 650
    @Published var maxExperience: Int = 1000
    @Published var coins: Int = 385
    @Published var currentCase: DetectiveCase?
    @Published var currentStep: CaseStep = .briefing
    @Published var foundEvidence: [Word] = []       // 搜证已找到的
    @Published var spokenSentences: [Int: Bool] = [:]  // 审讯: 句子index→完成
    @Published var coldCaseWords: [(Word, WordProficiency)] = []
    @Published var todayTasks: (newWords: Int, totalNewWords: Int,
                                 coldReview: Int, totalCold: Int,
                                 readSentences: Int, totalSentences: Int) = (4,5,6,8,1,3)
}

enum CaseStep: String, CaseIterable {
    case briefing       // 接案
    case investigation  // 搜证
    case interrogation  // 审讯
    case report         // 结案报告
    case celebration    // 庆祝
}
```

### MockData.swift

```swift
struct MockData {
    static let unit4Words = [
        Word(english: "cat", phonetic: "/kæt/", chinese: "猫", emoji: "🐱",
             exampleSentence: "I have a cat."),
        Word(english: "dog", phonetic: "/dɒɡ/", chinese: "狗", emoji: "🐶",
             exampleSentence: "The dog is big."),
        Word(english: "bird", phonetic: "/bɜːd/", chinese: "鸟", emoji: "🐦",
             exampleSentence: "I can see a bird."),
        Word(english: "fish", phonetic: "/fɪʃ/", chinese: "鱼", emoji: "🐟",
             exampleSentence: "The fish is in the pond."),
        Word(english: "rabbit", phonetic: "/ˈræbɪt/", chinese: "兔子", emoji: "🐰",
             exampleSentence: "The rabbit is cute."),
    ]

    static let unit4Sentences = [
        "I saw a big brown dog near the gate.",
        "The cat is under the tree.",
        "How many birds can you see?",
    ]

    static let unit4Case = DetectiveCase(
        caseNumber: 4,
        title: "失踪的动物园动物",
        subtitle: "Unit 4: Animals",
        briefing: """
        动物园的 5 只动物不见了！
        园长求助福克斯探长：
        "请帮我们找到这些动物，并确认它们的英文名字！"
        """,
        words: unit4Words,
        sentences: unit4Sentences,
        sceneEmojis: ["🐱", "🐶", "🐦", "🐟", "🐰"],
        isUnlocked: true
    )

    static let coldCaseSample: [(Word, WordProficiency)] = [
        (Word(english: "bird", phonetic: "/bɜːd/", chinese: "鸟", emoji: "🐦",
              exampleSentence: "I can see a bird."), .forgotten),
        (Word(english: "mouth", phonetic: "/maʊθ/", chinese: "嘴", emoji: "👄",
              exampleSentence: "Open your mouth."), .weak),
        (Word(english: "brown", phonetic: "/braʊn/", chinese: "棕色", emoji: "🟤",
              exampleSentence: "The dog is brown."), .weak),
    ]
}
```

---

## 任务分解

### Task 1: 项目脚手架 + 设计 Token

**Files:**
- Create: `EnglishDetective/EnglishDetectiveApp.swift`
- Create: `EnglishDetective/Theme/DesignTokens.swift`

- [ ] **Step 1: 创建 Xcode 项目**

在 Xcode 中新建 iOS App 项目：
- Template: App
- Name: EnglishDetective
- Interface: SwiftUI
- Language: Swift
- Minimum Deployment: iOS 17.0

- [ ] **Step 2: 定义 DesignTokens.swift**

```swift
// Theme/DesignTokens.swift
import SwiftUI

enum DetectiveColors {
    static let warmBackground = Color(hex: "FFFBEB")
    static let ink = Color(hex: "44403C")
    static let accent = Color(hex: "D97706")
    static let accentLight = Color(hex: "FEF3C7")
    static let success = Color(hex: "65A30D")
    static let danger = Color(hex: "DC2626")
    static let paper = Color.white
    static let muted = Color(hex: "F5F0E8")
    static let border = Color(hex: "E7E0D5")
    static let textMuted = Color(hex: "A8A29E")
    static let textSecondary = Color(hex: "78716C")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum DetectiveTypography {
    static let titleLarge = Font.custom("Fredoka-Bold", size: 32)
    static let titleMedium = Font.custom("Fredoka-SemiBold", size: 20)
    static let titleSmall = Font.custom("Fredoka-SemiBold", size: 16)
    static let body = Font.custom("Nunito-Regular", size: 14)
    static let bodySmall = Font.custom("Nunito-Regular", size: 11)
    static let label = Font.custom("Nunito-Bold", size: 10)
}

enum DetectiveRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 18
}

enum DetectiveSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
}
```

- [ ] **Step 3: 创建 EnglishDetectiveApp.swift**

```swift
// EnglishDetectiveApp.swift
import SwiftUI

@main
struct EnglishDetectiveApp: App {
    @StateObject private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainOfficeView()
            }
            .environmentObject(gameState)
            .preferredColorScheme(.light) // 强制浅色模式
        }
    }
}
```

- [ ] **Step 4: 验证**

在 Xcode 中 Build (⌘B)，确认编译通过，模拟器显示空白页面。

- [ ] **Step 5: Commit**

```bash
git init
git add .
git commit -m "feat: project scaffold + design tokens"
```

---

### Task 2: 数据模型 + Mock 数据

**Files:**
- Create: `EnglishDetective/Models/Word.swift`
- Create: `EnglishDetective/Models/Case.swift`
- Create: `EnglishDetective/Models/GameState.swift`
- Create: `EnglishDetective/Models/MockData.swift`

- [ ] **Step 1: 创建 Word.swift**

```swift
// Models/Word.swift
import Foundation

struct Word: Identifiable, Equatable {
    let id = UUID()
    let english: String
    let phonetic: String
    let chinese: String
    let emoji: String
    let exampleSentence: String
}

enum WordProficiency: CaseIterable {
    case mastered
    case weak
    case forgotten

    var label: String {
        switch self {
        case .mastered: return "已掌握"
        case .weak: return "需复习"
        case .forgotten: return "高危"
        }
    }

    var color: Color {
        switch self {
        case .mastered: return DetectiveColors.success
        case .weak: return DetectiveColors.accent
        case .forgotten: return DetectiveColors.danger
        }
    }

    var emoji: String {
        switch self {
        case .mastered: return "✅"
        case .weak: return "🟡"
        case .forgotten: return "🔴"
        }
    }
}
```

- [ ] **Step 2: 创建 Case.swift**

```swift
// Models/Case.swift
import Foundation

struct DetectiveCase: Identifiable {
    let id = UUID()
    let caseNumber: Int
    let title: String
    let subtitle: String
    let briefing: String
    let words: [Word]
    let sentences: [String]
    let sceneEmojis: [String]
    var isUnlocked: Bool = true
}

enum CaseStep: String, CaseIterable, Equatable {
    case briefing
    case investigation
    case interrogation
    case report
    case celebration

    var stepNumber: Int {
        switch self {
        case .briefing: return 1
        case .investigation: return 2
        case .interrogation: return 3
        case .report: return 4
        case .celebration: return 5
        }
    }

    var title: String {
        switch self {
        case .briefing: return "接案"
        case .investigation: return "搜证"
        case .interrogation: return "审讯"
        case .report: return "结案报告"
        case .celebration: return "庆祝"
        }
    }

    var icon: String {
        switch self {
        case .briefing: return "📋"
        case .investigation: return "🔍"
        case .interrogation: return "🎤"
        case .report: return "✍️"
        case .celebration: return "🏆"
        }
    }
}
```

- [ ] **Step 3: 创建 GameState.swift**

```swift
// Models/GameState.swift
import SwiftUI

class GameState: ObservableObject {
    @Published var detectiveName: String = "小明"
    @Published var detectiveRank: String = "初级侦探"
    @Published var experience: Int = 650
    @Published var maxExperience: Int = 1000
    @Published var coins: Int = 385

    // Current case flow
    @Published var currentCase: DetectiveCase?
    @Published var currentStep: CaseStep = .briefing
    @Published var foundEvidence: Set<UUID> = []
    @Published var spokenSentences: [Int: Bool] = [:]  // index -> completed
    @Published var reportBlanksFilled: [String: Bool] = [:]

    // Daily tasks
    @Published var todayTasks: (newWords: Int, totalNewWords: Int,
                                 coldReview: Int, totalCold: Int,
                                 readSentences: Int, totalSentences: Int)
        = (4, 5, 6, 8, 1, 3)

    // Cold case
    @Published var coldCaseWords: [(word: Word, proficiency: WordProficiency)] = []

    var experienceProgress: Double {
        Double(experience) / Double(maxExperience)
    }

    func startCase(_ detectiveCase: DetectiveCase) {
        currentCase = detectiveCase
        currentStep = .briefing
        foundEvidence = []
        spokenSentences = [:]
        reportBlanksFilled = [:]
    }

    func advanceStep() {
        guard let currentIndex = CaseStep.allCases.firstIndex(of: currentStep),
              currentIndex < CaseStep.allCases.count - 1 else { return }
        currentStep = CaseStep.allCases[currentIndex + 1]
    }

    func findEvidence(_ wordId: UUID) {
        foundEvidence.insert(wordId)
    }

    func completeSentence(_ index: Int) {
        spokenSentences[index] = true
    }
}
```

- [ ] **Step 4: 创建 MockData.swift**

内容与上面 `MockData.swift` 设计一致（见数据模型设计章节），此处省略重复。

- [ ] **Step 5: Build 验证**

```bash
# 在 Xcode 中 ⌘B
```

- [ ] **Step 6: Commit**

```bash
git add EnglishDetective/Models/
git commit -m "feat: data models + mock data for Unit 4 Animals"
```

---

### Task 3: 基础组件库

**Files:**
- Create: `EnglishDetective/Views/Components/WordCard.swift`
- Create: `EnglishDetective/Views/Components/ProgressBar.swift`
- Create: `EnglishDetective/Views/Components/StatusTag.swift`
- Create: `EnglishDetective/Views/Components/DetectiveButton.swift`

- [ ] **Step 1: WordCard.swift**

```swift
// Views/Components/WordCard.swift
import SwiftUI

struct WordCard: View {
    let word: Word
    var status: WordProficiency?
    var onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 6) {
            Text(word.emoji)
                .font(.system(size: 36))
            Text(word.english)
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
            Text(word.phonetic)
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)
        }
        .padding(14)
        .background(DetectiveColors.paper)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.medium)
                .stroke(statusColor, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .onTapGesture { onTap?() }
        .overlay(alignment: .topTrailing) {
            if let status = status {
                Image(systemName: statusIcon)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(status.color)
                    .clipShape(Circle())
                    .offset(x: 6, y: -6)
            }
        }
    }

    private var statusColor: Color {
        guard let status = status else { return DetectiveColors.border }
        return status.color
    }

    private var statusIcon: String {
        guard let status = status else { return "" }
        switch status {
        case .mastered: return "checkmark"
        case .weak: return "exclamationmark"
        case .forgotten: return "xmark"
        }
    }
}
```

- [ ] **Step 2: ProgressBar.swift**

```swift
// Views/Components/ProgressBar.swift
import SwiftUI

struct ProgressBar: View {
    let progress: Double  // 0.0 ... 1.0
    var color: Color = DetectiveColors.success
    var height: CGFloat = 6
    var showLabel: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(DetectiveColors.border)
                    .frame(height: height)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * progress, height: height)
            }
        }
        .frame(height: height)
    }
}
```

- [ ] **Step 3: StatusTag.swift**

```swift
// Views/Components/StatusTag.swift
import SwiftUI

struct StatusTag: View {
    enum TagStyle {
        case success, warning, danger, neutral
    }

    let text: String
    var style: TagStyle = .neutral

    var body: some View {
        Text(text)
            .font(DetectiveTypography.label)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var backgroundColor: Color {
        switch style {
        case .success: return Color(hex: "F0FDF4")
        case .warning: return DetectiveColors.accentLight
        case .danger: return Color(hex: "FEF2F2")
        case .neutral: return DetectiveColors.muted
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .success: return Color(hex: "3F6212")
        case .warning: return Color(hex: "92400E")
        case .danger: return Color(hex: "991B1B")
        case .neutral: return DetectiveColors.textSecondary
        }
    }
}
```

- [ ] **Step 4: DetectiveButton.swift**

```swift
// Views/Components/DetectiveButton.swift
import SwiftUI

struct DetectiveButton: View {
    enum ButtonStyle {
        case primary, secondary, accent
    }

    let title: String
    var icon: String?
    var style: ButtonStyle = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon { Text(icon) }
                Text(title)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.small)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return DetectiveColors.ink
        case .secondary: return DetectiveColors.paper
        case .accent: return DetectiveColors.accent
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .accent: return .white
        case .secondary: return DetectiveColors.ink
        }
    }

    private var borderColor: Color {
        style == .secondary ? DetectiveColors.border : .clear
    }

    private var borderWidth: CGFloat {
        style == .secondary ? 1.5 : 0
    }
}
```

- [ ] **Step 5: Build 验证**

- [ ] **Step 6: Commit**

```bash
git add EnglishDetective/Views/Components/
git commit -m "feat: base component library (WordCard, ProgressBar, StatusTag, DetectiveButton)"
```

---

### Task 4: 事务所主界面

**Files:**
- Create: `EnglishDetective/Views/MainOfficeView.swift`

- [ ] **Step 1: 实现 MainOfficeView.swift**

```swift
// Views/MainOfficeView.swift
import SwiftUI

struct MainOfficeView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                mainContent
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                Text("🔍").font(.title3)
                Text("英语侦探社")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)
            }
            Spacer()
            HStack(spacing: 8) {
                StatusTag(text: "📚 PEP三上", style: .neutral)
                StatusTag(text: "⭐ 385", style: .warning)
                Text("🦊").font(.title2)
            }
        }
        .padding(.horizontal, DetectiveSpacing.md)
        .padding(.vertical, 10)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) {
            Divider().overlay(DetectiveColors.border)
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        HStack(alignment: .top, spacing: DetectiveSpacing.md) {
            leftPanel
            centerPanel
            rightPanel
        }
        .padding(DetectiveSpacing.md)
    }

    // MARK: - Left Panel
    private var leftPanel: some View {
        VStack(spacing: DetectiveSpacing.sm) {
            // Character card
            VStack(spacing: 6) {
                Text("🦊").font(.system(size: 44))
                Text("福克斯探长")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)
                Text("你的导师")
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.textMuted)
                StatusTag(text: "🔰 初级侦探", style: .neutral)
                    .padding(.top, 2)
                ProgressBar(progress: gameState.experienceProgress, color: DetectiveColors.accent)
                    .frame(width: 120)
                Text("\(gameState.experience)/\(gameState.maxExperience)")
                    .font(.system(size: 9))
                    .foregroundColor(DetectiveColors.textMuted)
            }
            .padding(DetectiveSpacing.md)
            .cardStyle()

            // Navigation
            DetectiveButton(title: "受理新案件", icon: "📁", style: .primary) {
                gameState.startCase(MockData.unit4Case)
            }
            DetectiveButton(title: "冷案档案室", icon: "📂", style: .secondary) { }
            DetectiveButton(title: "徽章收藏册", icon: "🏆", style: .secondary) { }
            DetectiveButton(title: "设置", icon: "⚙️", style: .secondary) { }
        }
        .frame(width: 200)
    }

    // MARK: - Center Panel
    private var centerPanel: some View {
        VStack(spacing: DetectiveSpacing.sm) {
            // Today's tasks
            VStack(alignment: .leading, spacing: 8) {
                Text("📋 今日任务")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)

                taskRow(icon: "●", color: DetectiveColors.success,
                        label: "学习新单词", done: gameState.todayTasks.newWords,
                        total: gameState.todayTasks.totalNewWords,
                        progress: Double(gameState.todayTasks.newWords) / Double(gameState.todayTasks.totalNewWords))

                taskRow(icon: "●", color: DetectiveColors.success,
                        label: "复习冷案", done: gameState.todayTasks.coldReview,
                        total: gameState.todayTasks.totalCold,
                        progress: Double(gameState.todayTasks.coldReview) / Double(gameState.todayTasks.totalCold))

                taskRow(icon: "●", color: DetectiveColors.accent,
                        label: "跟读句子", done: gameState.todayTasks.readSentences,
                        total: gameState.todayTasks.totalSentences,
                        progress: Double(gameState.todayTasks.readSentences) / Double(gameState.todayTasks.totalSentences),
                        highlight: true)
            }
            .padding(DetectiveSpacing.md)
            .cardStyle()

            // Case cards
            HStack(spacing: DetectiveSpacing.sm) {
                activeCaseCard
                lockedCaseCard
            }
        }
    }

    private var activeCaseCard: some View {
        NavigationLink(destination: CaseBriefingView()) {
            VStack(alignment: .leading, spacing: 4) {
                Text("进行中")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(DetectiveColors.accent)
                    .clipShape(UnevenRoundedRectangle(
                        bottomLeadingRadius: 8, bottomTrailingRadius: 8))
                Text("CASE #004")
                    .font(DetectiveTypography.label)
                    .foregroundColor(DetectiveColors.textMuted)
                Text("失踪的动物园动物")
                    .font(DetectiveTypography.titleSmall)
                    .foregroundColor(DetectiveColors.ink)
                Text("Unit 4: Animals · 5词")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(DetectiveColors.textSecondary)
                HStack(spacing: 4) {
                    StatusTag(text: "🐱 cat", style: .success)
                    StatusTag(text: "🐶 dog", style: .success)
                    StatusTag(text: "+3", style: .warning)
                }
                Text("→ 继续调查")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DetectiveColors.accent)
                    .padding(.top, 4)
            }
            .padding(DetectiveSpacing.md)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var lockedCaseCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔒 CASE #005")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)
            Text("博物馆失窃案")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.textMuted)
            Text("完成 #004 解锁")
                .font(.system(size: 9))
                .foregroundColor(Color(hex: "D6D3D1"))
        }
        .padding(DetectiveSpacing.md)
        .background(DetectiveColors.muted)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                .foregroundColor(DetectiveColors.border)
        )
        .opacity(0.7)
    }

    // MARK: - Right Panel
    private var rightPanel: some View {
        VStack(spacing: DetectiveSpacing.xs) {
            wantedPosters
            weeklyStats
        }
        .frame(width: 165)
    }

    private var wantedPosters: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🚨 悬赏令")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)
            StatusTag(text: "🔴 bird · 3天", style: .danger)
            StatusTag(text: "🟡 mouth · 2天", style: .warning)
            StatusTag(text: "🟡 brown · 2天", style: .warning)
        }
        .padding(12)
        .cardStyle()
    }

    private var weeklyStats: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("📊 本周战绩")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DetectiveColors.ink)
            statLine("结案", "3")
            statLine("词汇", "28")
            statLine("最长连对", "12")
        }
        .padding(12)
        .cardStyle()
    }

    // MARK: - Helpers
    private func taskRow(icon: String, color: Color, label: String,
                         done: Int, total: Int, progress: Double,
                         highlight: Bool = false) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text("\(label) ")
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.ink)
            Text("\(done)/\(total)")
                .font(DetectiveTypography.bodySmall)
                .fontWeight(.bold)
                .foregroundColor(DetectiveColors.ink)
            Spacer()
            ProgressBar(progress: progress, color: color)
                .frame(width: 80)
        }
        .padding(8)
        .background(highlight ? DetectiveColors.accentLight : DetectiveColors.muted)
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
        .overlay(
            highlight ?
            RoundedRectangle(cornerRadius: DetectiveRadius.small)
                .stroke(Color(hex: "FDE68A"), lineWidth: 1) : nil
        )
    }

    private func statLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.textSecondary)
            Spacer()
            Text(value)
                .font(DetectiveTypography.bodySmall)
                .fontWeight(.bold)
                .foregroundColor(DetectiveColors.ink)
        }
    }
}

// MARK: - Card Modifier
extension View {
    func cardStyle() -> some View {
        self
            .background(DetectiveColors.paper)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.large)
                    .stroke(DetectiveColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
```

- [ ] **Step 2: 在 App 入口挂载 MainOfficeView**

确认 `EnglishDetectiveApp.swift` 中 `MainOfficeView()` 正确挂载且 `.environmentObject(gameState)` 已注入。

- [ ] **Step 3: Build + 模拟器验证**

在 Xcode 中运行 (⌘R)，选择 iPad 模拟器（如 iPad Air 11-inch），确认：
- 事务所三栏布局正常显示
- 角色卡 + 今日任务 + 案件卡片 + 悬赏令
- "受理新案件"按钮可点击（先不跳转）

- [ ] **Step 4: Commit**

```bash
git add EnglishDetective/Views/MainOfficeView.swift
git commit -m "feat: main office screen with character card, tasks, case list"
```

---

### Task 5: 接案页面 + 第一步动画

**Files:**
- Create: `EnglishDetective/Views/CaseBriefingView.swift`

- [ ] **Step 1: 实现 CaseBriefingView.swift**

```swift
// Views/CaseBriefingView.swift
import SwiftUI

struct CaseBriefingView: View {
    @EnvironmentObject var gameState: GameState
    @State private var animationPhase: BriefingPhase = .entering
    @State private var envelopeOffset: CGFloat = -400
    @State private var envelopeRotation: Double = -30
    @State private var sealOpacity: Double = 1
    @State private var letterScale: CGFloat = 0.3
    @State private var letterOpacity: Double = 0
    @State private var titleReveal: Bool = false
    @State private var foxBounce: Bool = false

    enum BriefingPhase {
        case entering, opened, ready
    }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Simplified top bar
                HStack {
                    NavigationLink(destination: MainOfficeView()) {
                        Text("← 事务所")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.accent)
                    }
                    Spacer()
                    Text("CASE #004")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.textMuted)
                }
                .padding(.horizontal, DetectiveSpacing.md)
                .padding(.vertical, 10)
                .background(DetectiveColors.paper)
                .overlay(alignment: .bottom) {
                    Divider().overlay(DetectiveColors.border)
                }

                // Briefing content
                Spacer()

                VStack(spacing: 20) {
                    // Envelope animation
                    ZStack {
                        // Envelope
                        Text("✉️")
                            .font(.system(size: 64))
                            .offset(y: envelopeOffset)
                            .rotationEffect(.degrees(envelopeRotation))

                        // Letter content (revealed after "opening")
                        VStack(spacing: 12) {
                            Text("📨 新密函抵达")
                                .font(DetectiveTypography.label)
                                .foregroundColor(DetectiveColors.textMuted)

                            Text(gameState.currentCase?.title ?? "失踪的动物园动物")
                                .font(DetectiveTypography.titleLarge)
                                .foregroundColor(DetectiveColors.ink)
                                .opacity(titleReveal ? 1 : 0)
                                .animation(.easeIn(duration: 0.6).delay(0.3), value: titleReveal)

                            Text(gameState.currentCase?.briefing ?? "")
                                .font(DetectiveTypography.body)
                                .foregroundColor(DetectiveColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .opacity(letterOpacity)
                        }
                        .scaleEffect(letterScale)
                        .opacity(letterOpacity)
                    }

                    // Target words
                    if animationPhase == .ready {
                        HStack(spacing: 8) {
                            ForEach(gameState.currentCase?.words ?? []) { word in
                                StatusTag(text: "\(word.emoji) \(word.english)", style: .warning)
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                    }

                    // Start button
                    if animationPhase == .ready {
                        DetectiveButton(title: "开始调查", icon: "🔍", style: .primary) {
                            gameState.advanceStep()
                        }
                        .frame(width: 240)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                Spacer()

                // Fox character
                if foxBounce {
                    VStack(spacing: 4) {
                        Text("🦊").font(.system(size: 48))
                        Text("\"Let's solve this case!\"")
                            .font(DetectiveTypography.body)
                            .foregroundColor(DetectiveColors.ink)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear { runAnimation() }
        .toolbar(.hidden)
    }

    private func runAnimation() {
        // Phase 1: Envelope flies in (0-1.5s)
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            envelopeOffset = 0
            envelopeRotation = 0
        }

        // Phase 2: Seal melts, letter expands (1.5-3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                sealOpacity = 0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                letterScale = 1
                letterOpacity = 1
            }
        }

        // Phase 3: Title types out (3.0-4.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            titleReveal = true
        }

        // Phase 4: Fox appears (4.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                foxBounce = true
                animationPhase = .ready
            }
        }
    }
}
```

- [ ] **Step 2: 更新 MainOfficeView 中"受理新案件"按钮的导航**

确认 `MainOfficeView.swift` 中的 `DetectiveButton(title: "受理新案件", ...)` 使用 `NavigationLink` 包裹或改用 `NavigationLink`。

修改 MainOfficeView 的 leftPanel 中的第一个按钮：
```swift
// 替换原来的 DetectiveButton
NavigationLink(destination: CaseBriefingView()) {
    DetectiveButton(title: "受理新案件", icon: "📁", style: .primary) {}
}
.disabled(gameState.currentCase == nil)
```

- [ ] **Step 3: Build + 动画验证**

运行后在模拟器中点击"受理新案件"，验证：
- 密函飞入动画完整播放
- 标题+案情文字出现
- 目标单词列表和"开始调查"按钮最终显示
- 目前"开始调查"只推进到下一步（下一步还没做）

- [ ] **Step 4: Commit**

```bash
git add EnglishDetective/Views/CaseBriefingView.swift
git commit -m "feat: case briefing screen with envelope fly-in animation"
```

---

### Task 6: 搜证页面

**Files:**
- Create: `EnglishDetective/Views/InvestigationView.swift`

- [ ] **Step 1: 实现 InvestigationView.swift**

```swift
// Views/InvestigationView.swift
import SwiftUI

struct InvestigationView: View {
    @EnvironmentObject var gameState: GameState
    @State private var foundWord: Word?
    @State private var showPronunciationResult: Bool = false
    @State private var pronunciationScore: Int = 0

    private let audioClues = [
        "Find the animal that says meow...",
        "Find the animal that says woof...",
        "Find the animal that says tweet-tweet...",
        "Find the animal that swims in water...",
        "Find the animal that hops and has long ears...",
    ]
    @State private var currentClueIndex = 0

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { gameState.currentStep = .briefing }) {
                        Text("← 案情")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.accent)
                    }
                    Spacer()
                    Text("🔍 现场搜证")
                        .font(DetectiveTypography.titleSmall)
                        .foregroundColor(DetectiveColors.ink)
                    Spacer()
                    Text("已找到 \(gameState.foundEvidence.count)/\(gameState.currentCase?.words.count ?? 5)")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.ink)
                }
                .padding(.horizontal, DetectiveSpacing.md)
                .padding(.vertical, 10)
                .background(DetectiveColors.paper)
                .overlay(alignment: .bottom) {
                    Divider().overlay(DetectiveColors.border)
                }

                // Scene
                VStack(spacing: 16) {
                    Text("🔦 点击场景中的可疑目标 → 找到动物 → 说出英文名 → 收集证物")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.textMuted)
                        .padding(.top, 8)

                    // Scene area
                    VStack(spacing: 16) {
                        // Animal grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5),
                                  spacing: 12) {
                            ForEach(gameState.currentCase?.words ?? []) { word in
                                WordCard(word: word,
                                         status: gameState.foundEvidence.contains(word.id) ? .mastered : nil)
                                    .opacity(gameState.foundEvidence.contains(word.id) ? 1.0 : 0.8)
                                    .onTapGesture {
                                        if !gameState.foundEvidence.contains(word.id) {
                                            simulateDiscovery(word)
                                        }
                                    }
                            }
                        }
                        .padding(16)
                        .background(
                            LinearGradient(colors: [
                                DetectiveColors.muted,
                                Color(hex: "E8E0D3")
                            ], startPoint: .top, endPoint: .bottom)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
                        .overlay(
                            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                                .stroke(DetectiveColors.border, lineWidth: 1.5)
                        )

                        // Audio clue
                        HStack(spacing: 8) {
                            Text("🔊")
                            Text("\"\(audioClues[currentClueIndex])\"")
                                .font(DetectiveTypography.bodySmall)
                                .foregroundColor(DetectiveColors.ink)
                            Button("🔁") { nextClue() }
                                .font(.caption)
                                .foregroundColor(DetectiveColors.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(DetectiveColors.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal, 16)

                    // Pronunciation result popup
                    if showPronunciationResult, let word = foundWord {
                        pronunciationResult(word)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Evidence bag row
                    evidenceBagRow
                        .padding(.horizontal, 16)

                    // Next button
                    if gameState.foundEvidence.count == gameState.currentCase?.words.count {
                        DetectiveButton(title: "审讯证人 →", icon: "🎤", style: .primary) {
                            gameState.advanceStep()
                        }
                        .frame(width: 240)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: gameState.foundEvidence.count)
                    }
                }

                Spacer()
            }
        }
        .onAppear { nextClue() }
        .toolbar(.hidden)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: gameState.foundEvidence.count)
    }

    private func simulateDiscovery(_ word: Word) {
        foundWord = word
        pronunciationScore = Int.random(in: 3...5)   // simulate decent score
        showPronunciationResult = true

        // Add to evidence after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                gameState.findEvidence(word.id)
                showPronunciationResult = false
                nextClue()
            }
        }
    }

    private func nextClue() {
        let remaining = (gameState.currentCase?.words ?? [])
            .filter { !gameState.foundEvidence.contains($0.id) }
        if !remaining.isEmpty {
            currentClueIndex = Int.random(in: 0..<min(audioClues.count, max(1, remaining.count)))
        }
    }

    private func pronunciationResult(_ word: Word) -> some View {
        HStack(spacing: 8) {
            Text("🎤")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("你读出了 \"\(word.english)\"")
                    .font(DetectiveTypography.body)
                    .foregroundColor(DetectiveColors.ink)
                Text("发音评分: \(String(repeating: "⭐", count: pronunciationScore))")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(DetectiveColors.success)
            }
            Spacer()
            Text("证物已收集!")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.success)
        }
        .padding(12)
        .background(Color(hex: "F0FDF4"))
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
        .padding(.horizontal, 16)
    }

    private var evidenceBagRow: some View {
        HStack(spacing: 6) {
            ForEach(gameState.currentCase?.words ?? []) { word in
                if gameState.foundEvidence.contains(word.id) {
                    StatusTag(text: "🧤 \(word.english)", style: .success)
                } else {
                    StatusTag(text: "🧤 ???", style: .neutral)
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build + 交互验证**

- 场景卡片 5 个动物可点击
- 点击 → 模拟发音评分 → 证物袋更新
- 全部找到后"审讯证人"按钮出现

- [ ] **Step 3: Commit**

```bash
git add EnglishDetective/Views/InvestigationView.swift
git commit -m "feat: investigation scene with tap-to-discover + evidence collection"
```

---

### Task 7: 审讯页面

**Files:**
- Create: `EnglishDetective/Views/InterrogationView.swift`

- [ ] **Step 1: 实现 InterrogationView.swift**

```swift
// Views/InterrogationView.swift
import SwiftUI

struct InterrogationView: View {
    @EnvironmentObject var gameState: GameState
    @State private var currentSentenceIndex: Int = 0
    @State private var isRecording: Bool = false
    @State private var wordScores: [String: Int] = [:]  // word -> 0(red)/1(yellow)/2(green)
    @State private var showResult: Bool = false

    private let witnessEmoji = "🐰"
    private let witnessName = "兔子女士"
    private let witnessRole = "目击证人"

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                HStack(alignment: .top, spacing: 16) {
                    witnessPanel
                    dialoguePanel
                }
                .padding(DetectiveSpacing.md)
            }
        }
        .toolbar(.hidden)
    }

    private var topBar: some View {
        HStack {
            Button(action: { gameState.currentStep = .investigation }) {
                Text("← 搜证")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(DetectiveColors.accent)
            }
            Spacer()
            Text("🎤 审讯对话")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
            Spacer()
            Text("句子 \(currentSentenceIndex + 1)/\(gameState.currentCase?.sentences.count ?? 3)")
                .font(DetectiveTypography.bodySmall)
                .foregroundColor(DetectiveColors.ink)
        }
        .padding(.horizontal, DetectiveSpacing.md)
        .padding(.vertical, 10)
        .background(DetectiveColors.paper)
        .overlay(alignment: .bottom) {
            Divider().overlay(DetectiveColors.border)
        }
    }

    private var witnessPanel: some View {
        VStack(spacing: 12) {
            Text(witnessEmoji).font(.system(size: 64))
            Text(witnessName)
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
            Text(witnessRole)
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            if isRecording {
                StatusTag(text: "紧张中...", style: .danger)
                    .transition(.scale)
            } else if showResult {
                let allGood = wordScores.values.allSatisfy { $0 == 2 }
                StatusTag(text: allGood ? "星星眼!" : "还需要加油~", style: allGood ? .success : .warning)
            }
        }
        .frame(width: 200)
        .padding(20)
        .background(
            LinearGradient(colors: [DetectiveColors.muted, DetectiveColors.warmBackground],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(DetectiveColors.border, lineWidth: 1)
        )
    }

    private var dialoguePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            // NPC speech bubble
            VStack(alignment: .leading, spacing: 2) {
                Text("\(witnessEmoji) \(witnessName)说：")
                    .font(.system(size: 9))
                    .foregroundColor(DetectiveColors.textMuted)
                Text("\"\(gameState.currentCase?.sentences[safe: currentSentenceIndex] ?? "")\"")
                    .font(DetectiveTypography.body)
                    .fontWeight(.bold)
                    .foregroundColor(DetectiveColors.ink)
            }
            .padding(14)
            .cardStyle()

            // Recording area
            VStack(spacing: 8) {
                Text("🎤 请跟读这句话，说服她给你更多线索！")
                    .font(DetectiveTypography.bodySmall)
                    .foregroundColor(Color(hex: "92400E"))

                // Simulated waveform
                if isRecording {
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(0..<12) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill([DetectiveColors.success, DetectiveColors.accent][i % 2])
                                .frame(width: 3, height: CGFloat.random(in: 10...30))
                        }
                    }
                    .frame(height: 30)
                    .transition(.scale)
                }

                // Record button
                Button(action: toggleRecording) {
                    Text(isRecording ? "🔴 录音中...轻点停止" : "🎙️ 点我开始跟读")
                        .font(DetectiveTypography.body)
                        .foregroundColor(isRecording ? DetectiveColors.danger : DetectiveColors.ink)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isRecording ? Color(hex: "FEF2F2") : DetectiveColors.accentLight)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isRecording ? DetectiveColors.danger : Color(hex: "FDE68A"), lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(DetectiveColors.accentLight)
            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: DetectiveRadius.medium)
                    .stroke(Color(hex: "FDE68A"), lineWidth: 1.5)
            )

            // Word-by-word scores
            if showResult {
                wordScoreGrid
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Next sentence button
            if showResult {
                if currentSentenceIndex < (gameState.currentCase?.sentences.count ?? 3) - 1 {
                    DetectiveButton(title: "下一句 →", style: .secondary) {
                        nextSentence()
                    }
                    .frame(width: 200)
                } else {
                    DetectiveButton(title: "写结案报告 →", icon: "✍️", style: .primary) {
                        gameState.advanceStep()
                    }
                    .frame(width: 240)
                }
            }
        }
    }

    private var wordScoreGrid: some View {
        let words = (gameState.currentCase?.sentences[safe: currentSentenceIndex] ?? "")
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }

        return VStack(alignment: .leading, spacing: 4) {
            Text("逐词评分：")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4),
                      spacing: 6) {
                ForEach(words, id: \.self) { word in
                    let score = wordScores[word] ?? Int.random(in: 1...2)  // simulate
                    StatusTag(
                        text: "\(word) \(score == 2 ? "⭐" : "☆")",
                        style: score == 2 ? .success : .warning
                    )
                }
            }
        }
        .padding(14)
        .cardStyle()
    }

    private func toggleRecording() {
        withAnimation(.spring()) {
            if isRecording {
                // Stop recording → show results
                isRecording = false
                simulateScores()
                showResult = true
                gameState.completeSentence(currentSentenceIndex)
            } else {
                // Start recording
                isRecording = true
                showResult = false
            }
        }
    }

    private func simulateScores() {
        let words = (gameState.currentCase?.sentences[safe: currentSentenceIndex] ?? "")
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
        wordScores = [:]
        for word in words {
            // Most words "correct", 1-2 "needs work" for demo
            wordScores[word] = Bool.random() ? 2 : Int.random(in: 0...1)
        }
    }

    private func nextSentence() {
        withAnimation(.easeInOut) {
            currentSentenceIndex += 1
            isRecording = false
            showResult = false
            wordScores = [:]
        }
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
```

- [ ] **Step 2: Build + 验证**

- 证人面板 + 对话区布局
- 点击录音按钮 → 声波纹动画
- 停止 → 逐词评分显示
- 三句都完成后"写结案报告"按钮出现

- [ ] **Step 3: Commit**

```bash
git add EnglishDetective/Views/InterrogationView.swift
git commit -m "feat: interrogation screen with simulated voice recording + word scores"
```

---

### Task 8: 结案报告 + 庆祝页面

**Files:**
- Create: `EnglishDetective/Views/CaseReportView.swift`
- Create: `EnglishDetective/Views/CelebrationView.swift`

- [ ] **Step 1: 实现 CaseReportView.swift**

```swift
// Views/CaseReportView.swift
import SwiftUI

struct CaseReportView: View {
    @EnvironmentObject var gameState: GameState
    @State private var filledBlanks: [UUID: Word] = [:]
    @State private var stampOffset: CGFloat = -200
    @State private var stampVisible: Bool = false

    private let blanks: [(prompt: String, correctAnswer: String, id: UUID)] = [
        (prompt: "The _____ is in the pond.", correctAnswer: "fish", id: UUID()),
        (prompt: "The _____ is in the grass.", correctAnswer: "rabbit", id: UUID()),
    ]

    var allFilled: Bool {
        filledBlanks.count == blanks.count
    }

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { gameState.currentStep = .interrogation }) {
                        Text("← 审讯")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.accent)
                    }
                    Spacer()
                    Text("✍️ 结案报告")
                        .font(DetectiveTypography.titleSmall)
                        .foregroundColor(DetectiveColors.ink)
                    Spacer()
                    Text("填写报告")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.ink)
                }
                .padding(.horizontal, DetectiveSpacing.md)
                .padding(.vertical, 10)
                .background(DetectiveColors.paper)
                .overlay(alignment: .bottom) {
                    Divider().overlay(DetectiveColors.border)
                }

                HStack(alignment: .top, spacing: 16) {
                    // Report paper
                    reportPaper
                    // Word bank
                    wordBank
                }
                .padding(DetectiveSpacing.md)

                // Submit button
                if allFilled {
                    DetectiveButton(title: "提交报告", icon: "📋", style: .accent) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                            stampVisible = true
                            stampOffset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            gameState.advanceStep()
                        }
                    }
                    .frame(width: 240)
                    .padding(.bottom, 16)
                }
            }
        }
        .toolbar(.hidden)
    }

    private var reportPaper: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 案件结案报告 — CASE #004")
                .font(DetectiveTypography.titleSmall)
                .foregroundColor(DetectiveColors.ink)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("案发地点：动物园")
                .font(DetectiveTypography.body)
                .foregroundColor(DetectiveColors.ink)
            Text("失踪动物数量：5 只")
                .font(DetectiveTypography.body)
                .foregroundColor(DetectiveColors.ink)

            Text("已找到的动物：")
                .font(DetectiveTypography.body)
                .foregroundColor(DetectiveColors.ink)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(gameState.currentCase?.words ?? []) { word in
                    HStack {
                        Text("✅ The")
                            .font(DetectiveTypography.body)
                            .foregroundColor(DetectiveColors.ink)
                        Text(word.english)
                            .font(DetectiveTypography.body)
                            .fontWeight(.bold)
                            .foregroundColor(DetectiveColors.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DetectiveColors.accentLight)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text("is ______.")
                            .font(DetectiveTypography.body)
                            .foregroundColor(DetectiveColors.ink)
                    }
                }
                .opacity(0.6) // Already known words shown as "checked"

                // Blanks to fill
                ForEach(blanks, id: \.id) { blank in
                    HStack {
                        Text("⬜")
                            .font(DetectiveTypography.body)
                        if let filled = filledBlanks[blank.id] {
                            Text("\(filled.emoji) \(filled.english)")
                                .font(DetectiveTypography.body)
                                .fontWeight(.bold)
                                .foregroundColor(DetectiveColors.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(hex: "F0FDF4"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            Text("______")
                                .font(DetectiveTypography.body)
                                .foregroundColor(DetectiveColors.textMuted)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 2)
                                .background(DetectiveColors.muted)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                        .foregroundColor(DetectiveColors.border)
                                )
                        }
                    }
                }
            }
            .padding(.leading, 16)

            // Stamp overlay
            if stampVisible {
                Text("CASE\nSOLVED")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(DetectiveColors.danger)
                    .padding(12)
                    .rotationEffect(.degrees(-12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(DetectiveColors.danger, lineWidth: 4)
                    )
                    .offset(y: stampOffset)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(
            LinearGradient(colors: [.white, DetectiveColors.warmBackground],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: DetectiveRadius.large)
                .stroke(DetectiveColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    private var wordBank: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("📦 证据池")
                .font(DetectiveTypography.label)
                .foregroundColor(DetectiveColors.textMuted)
            Text("拖入空白处")
                .font(.system(size: 9))
                .foregroundColor(DetectiveColors.textMuted)

            ForEach(blanks, id: \.id) { blank in
                if filledBlanks[blank.id] == nil,
                   let word = gameState.currentCase?.words.first(where: {
                       $0.english == blank.correctAnswer
                   }) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            filledBlanks[blank.id] = word
                        }
                    }) {
                        Text(word.english)
                            .font(DetectiveTypography.body)
                            .fontWeight(.bold)
                            .foregroundColor(DetectiveColors.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                filledBlanks.contains(where: { $0.value.english == word.english })
                                ? DetectiveColors.muted
                                : DetectiveColors.paper
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        filledBlanks.contains(where: { $0.value.english == word.english })
                                        ? DetectiveColors.border
                                        : DetectiveColors.accent,
                                        lineWidth: filledBlanks.contains(where: { $0.value.english == word.english }) ? 1 : 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 180)
    }
}
```

- [ ] **Step 2: 实现 CelebrationView.swift**

```swift
// Views/CelebrationView.swift
import SwiftUI

struct CelebrationView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showBadge: Bool = false
    @State private var badgeRotation: Double = 0
    @State private var showStats: Bool = false
    @State private var showButtons: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [DetectiveColors.warmBackground, DetectiveColors.accentLight],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Text("🎉🎉🎉")
                    .font(.largeTitle)

                Text("案件解决！")
                    .font(DetectiveTypography.titleLarge)
                    .foregroundColor(DetectiveColors.ink)

                Text("Case #004 · 失踪的动物园动物")
                    .font(DetectiveTypography.body)
                    .foregroundColor(DetectiveColors.textSecondary)

                if showStats {
                    HStack(spacing: 8) {
                        StatusTag(text: "⭐ 单词 5/5", style: .success)
                        StatusTag(text: "🎤 跟读 3/3", style: .success)
                        StatusTag(text: "📝 报告完美", style: .success)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // Badge
                if showBadge {
                    VStack(spacing: 8) {
                        Text("🏅")
                            .font(.system(size: 64))
                            .rotationEffect(.degrees(badgeRotation))
                        Text("获得新徽章：动物之友")
                            .font(DetectiveTypography.titleSmall)
                            .foregroundColor(DetectiveColors.ink)
                        Text("徽章已收入收藏册 · +120 ⚡ 经验")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.textSecondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                if showButtons {
                    HStack(spacing: 12) {
                        NavigationLink(destination: MainOfficeView()) {
                            HStack {
                                Text("🏢")
                                Text("回事务所")
                            }
                            .font(DetectiveTypography.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(DetectiveColors.ink)
                            .clipShape(RoundedRectangle(cornerRadius: DetectiveRadius.small))
                        }

                        DetectiveButton(title: "清理冷案", icon: "📂", style: .accent) { }
                            .frame(width: 160)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(40)
        }
        .toolbar(.hidden)
        .onAppear {
            // Staggered animation sequence
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                showStats = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.8)) {
                showBadge = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(1.0)) {
                badgeRotation = 360
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.5)) {
                showButtons = true
            }
        }
    }
}
```

- [ ] **Step 3: 连接完整流程**

确认 GameState 中的 `advanceStep()` 能正确驱动 `currentStep` 从 `.report` 到 `.celebration`。

需要在主流程中用一个 View 来根据 `currentStep` 切换页面。创建一个 `CaseFlowView`：

```swift
// Views/CaseFlowView.swift
import SwiftUI

struct CaseFlowView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        Group {
            switch gameState.currentStep {
            case .briefing:
                CaseBriefingView()
            case .investigation:
                InvestigationView()
            case .interrogation:
                InterrogationView()
            case .report:
                CaseReportView()
            case .celebration:
                CelebrationView()
            }
        }
    }
}
```

然后修改 `CaseBriefingView` 中的"开始调查"按钮，用 `gameState.advanceStep()` 推进到 `.investigation`。
类似地，修改 `InvestigationView` 和 `InterrogationView` 的"下一步"按钮。

**关键修改**：`MainOfficeView` 中"受理新案件"的导航终点改为 `CaseFlowView()`。

- [ ] **Step 4: Build + 全流程验证**

- 事务所 → 点击"受理新案件" → 接案动画 → 开始调查
- 搜证（点击 5 个动物）→ 审讯证人 → 审讯（录音 3 句）
- 结案报告（填 2 个空）→ 提交 → 庆祝

- [ ] **Step 5: Commit**

```bash
git add EnglishDetective/Views/CaseReportView.swift \
        EnglishDetective/Views/CelebrationView.swift \
        EnglishDetective/Views/CaseFlowView.swift
git commit -m "feat: case report + celebration + full flow navigation"
```

---

### Task 9: 冷案档案室 + 收尾

**Files:**
- Create: `EnglishDetective/Views/ColdCaseView.swift`

- [ ] **Step 1: 实现 ColdCaseView.swift**

```swift
// Views/ColdCaseView.swift
import SwiftUI

struct ColdCaseView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            DetectiveColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    NavigationLink(destination: MainOfficeView()) {
                        Text("← 事务所")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.accent)
                    }
                    Spacer()
                    Text("📂 冷案档案室")
                        .font(DetectiveTypography.titleSmall)
                        .foregroundColor(DetectiveColors.ink)
                    Spacer()
                    Text("3个待追查")
                        .font(DetectiveTypography.bodySmall)
                        .foregroundColor(DetectiveColors.ink)
                }
                .padding(.horizontal, DetectiveSpacing.md)
                .padding(.vertical, 10)
                .background(DetectiveColors.paper)
                .overlay(alignment: .bottom) {
                    Divider().overlay(DetectiveColors.border)
                }

                HStack(alignment: .top, spacing: 14) {
                    // Main: cold case list
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧊 未结冷案 — 需要重新追查")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(DetectiveColors.ink)

                        HStack(spacing: 10) {
                            ForEach(MockData.coldCaseSample, id: \.0.id) { item in
                                coldCaseCard(item.word, proficiency: item.proficiency)
                            }
                        }

                        Text("✅ 已清理冷案")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DetectiveColors.ink)
                            .padding(.top, 8)

                        HStack(spacing: 6) {
                            StatusTag(text: "🐱 cat · 已掌握", style: .success)
                            StatusTag(text: "🐶 dog · 已掌握", style: .success)
                            StatusTag(text: "👀 eye · 已掌握", style: .success)
                            StatusTag(text: "👂 ear · 已掌握", style: .success)
                        }
                    }

                    // Side: weekly challenge
                    VStack(spacing: 8) {
                        Text("🏃 本周越狱挑战")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DetectiveColors.ink)
                        Text("⏰")
                            .font(.system(size: 40))
                        Text("还剩 3 天")
                            .font(DetectiveTypography.label)
                            .foregroundColor(DetectiveColors.textMuted)
                        Text("3个冷案词即将\"越狱\"\n一次性全部抓捕！")
                            .font(DetectiveTypography.bodySmall)
                            .foregroundColor(DetectiveColors.ink)
                            .multilineTextAlignment(.center)
                        StatusTag(text: "🎁 奖励翻倍", style: .warning)
                    }
                    .padding(14)
                    .cardStyle()
                    .frame(width: 180)
                }
                .padding(DetectiveSpacing.md)
            }
        }
        .toolbar(.hidden)
    }

    private func coldCaseCard(_ word: Word, proficiency: WordProficiency) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(word.english)
                        .font(DetectiveTypography.titleSmall)
                        .foregroundColor(DetectiveColors.ink)
                    Text("\(word.phonetic) · \(word.chinese)")
                        .font(DetectiveTypography.label)
                        .foregroundColor(DetectiveColors.textMuted)
                    StatusTag(text: "\(proficiency.emoji) \(proficiency.label)",
                              style: proficiency == .forgotten ? .danger : .warning)
                        .padding(.top, 2)
                }
                Spacer()
                Text(word.emoji).font(.system(size: 32))
            }
            DetectiveButton(title: "追查", icon: "🔍",
                            style: proficiency == .forgotten ? .accent : .secondary) { }
                .padding(.top, 4)
        }
        .padding(12)
        .cardStyle()
    }
}
```

- [ ] **Step 2: 在 MainOfficeView 中连接冷案入口**

修改 MainOfficeView 中"冷案档案室"按钮为 NavigationLink：
```swift
NavigationLink(destination: ColdCaseView()) {
    DetectiveButton(title: "冷案档案室", icon: "📂", style: .secondary) { }
}
```

- [ ] **Step 3: 最终验证**

完整走一遍流程：
1. 启动 → 事务所主界面
2. 冷案档案室（查看悬赏令 + 已清理词）
3. 回事务所 → 受理新案件 → 接案动画
4. 搜证（点 5 个动物）→ 审讯（录 3 句）→ 结案报告（填 2 空）→ 庆祝
5. 回事务所

- [ ] **Step 4: Commitment**

```bash
git add EnglishDetective/Views/ColdCaseView.swift
git commit -m "feat: cold case archive screen + navigation integration"
```

---

## 交付物

完成所有 Task 后，你应该有一个可在 iPad 模拟器上完整运行的 prototype：

- ✅ 暖调案卷风视觉落地（颜色、字体、卡片、圆角）
- ✅ 事务所主界面（角色卡、任务板、案件列表、悬赏令）
- ✅ 接案动画（密函飞入、火漆融化、探长登场）
- ✅ 搜证交互（点击发现、模拟发音评分、证物收集）
- ✅ 审讯交互（模拟录音、声波纹、逐词评分）
- ✅ 结案报告（单词填空、印章动画）
- ✅ 庆祝结算（徽章旋转、统计数据）
- ✅ 冷案档案室（悬赏令 + 越狱挑战预览）
- ✅ 完整 5 步流程可走通

---

## 自审记录

- **Spec coverage**: 设计文档中 prototype scope 内的所有功能点均已覆盖。家长功能、真实语音、持久化等明确标记为 out of scope。
- **Placeholder scan**: 无 TBD/TODO/待实现。所有模拟行为（发音评分、录音）均有明确实现。
- **Type consistency**: Word, DetectiveCase, GameState, CaseStep 等类型在全部 Task 中一致使用。`gameState.currentStep` 驱动的流程切换逻辑完整。
