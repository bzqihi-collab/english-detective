import Foundation

// MARK: - Mock Data: PEP 三年级上 Unit 4: Animals

struct MockData {

    // MARK: Words (5 words)

    static let wordCat = Word(
        english: "cat",
        phonetic: "/kæt/",
        chinese: "猫",
        emoji: "🐱",
        exampleSentence: "I have a cat."
    )

    static let wordDog = Word(
        english: "dog",
        phonetic: "/dɒɡ/",
        chinese: "狗",
        emoji: "🐶",
        exampleSentence: "The dog is big."
    )

    static let wordBird = Word(
        english: "bird",
        phonetic: "/bɜːd/",
        chinese: "鸟",
        emoji: "🐦",
        exampleSentence: "I can see a bird."
    )

    static let wordFish = Word(
        english: "fish",
        phonetic: "/fɪʃ/",
        chinese: "鱼",
        emoji: "🐟",
        exampleSentence: "The fish is in the pond."
    )

    static let wordRabbit = Word(
        english: "rabbit",
        phonetic: "/ˈræbɪt/",
        chinese: "兔子",
        emoji: "🐰",
        exampleSentence: "The rabbit is cute."
    )

    static let unit4Words: [Word] = [
        wordCat, wordDog, wordBird, wordFish, wordRabbit
    ]

    // MARK: Sentences (3 sentences for interrogation)

    static let unit4Sentences: [String] = [
        "I saw a big brown dog near the gate.",
        "The cat is under the tree.",
        "How many birds can you see?",
    ]

    // MARK: Case

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

    // MARK: Cold Case Sample Data

    static let wordMouth = Word(
        english: "mouth",
        phonetic: "/maʊθ/",
        chinese: "嘴",
        emoji: "👄",
        exampleSentence: "Open your mouth."
    )

    static let wordBrown = Word(
        english: "brown",
        phonetic: "/braʊn/",
        chinese: "棕色",
        emoji: "🟤",
        exampleSentence: "The dog is brown."
    )

    static let coldCaseSample: [(Word, WordProficiency)] = [
        (wordBird, .forgotten),
        (wordMouth, .weak),
        (wordBrown, .weak),
    ]

    // MARK: Report Blanks

    static let reportBlanks: [(id: String, prompt: String, answer: String)] = [
        (id: "blank_fish", prompt: "The _____ is in the pond.", answer: "fish"),
        (id: "blank_rabbit", prompt: "The _____ is in the grass.", answer: "rabbit"),
    ]
}
