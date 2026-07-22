# 🕵️ 英语侦探社 — English Detective Agency

面向小学三四年级学生的 iPad 英语学习工具。  
以"侦探破案"为核心叙事，将听说读写包装为破案流程。

> **当前状态**: Prototype（SwiftUI 交互原型）

---

## 🚀 运行（Mac 上 3 步）

**前提**：App Store 搜 Xcode 安装（免费）

```bash
git clone git@github.com:bzqihi-collab/english-detective.git
cd english-detective
xed .
```

然后插上 iPad，选你的设备，点 ▶️ 运行。

> 字体 Fredoka/Nunito 可选安装，不装也能跑。

---

## 📁 项目结构

```
EnglishDetective/
├── EnglishDetectiveApp.swift      # @main 入口
├── Theme/
│   └── DesignTokens.swift          # 颜色/字体/圆角/间距
├── Models/
│   ├── Word.swift                  # 单词模型 + 掌握程度枚举
│   ├── Case.swift                  # 案件模型 + 流程步骤枚举
│   ├── GameState.swift             # 全局状态 (ObservableObject)
│   └── MockData.swift              # 硬编码数据 (PEP三上Unit 4)
└── Views/
    ├── MainOfficeView.swift        # 🏢 事务所主界面
    ├── CaseBriefingView.swift      # 📋 接案（密函动画）
    ├── InvestigationView.swift     # 🔍 搜证现场
    ├── InterrogationView.swift     # 🎤 审讯对话
    ├── CaseReportView.swift        # ✍️ 结案报告
    ├── CelebrationView.swift       # 🏆 庆祝结算
    ├── CaseFlowView.swift          # 流程容器（切换步骤）
    ├── ColdCaseView.swift          # 📂 冷案档案室
    └── Components/
        ├── WordCard.swift          # 单词卡片
        ├── ProgressBar.swift       # 进度条
        ├── StatusTag.swift         # 状态标签
        └── DetectiveButton.swift   # 主题按钮
```

---

## 🎨 设计系统

| 角色 | 色值 |
|------|------|
| 奶油背景 | `#FFFBEB` |
| 深棕墨水 | `#44403C` |
| 琥珀金 | `#D97706` |
| 松石绿 | `#65A30D` |
| 暖红 | `#DC2626` |

- 标题字体: Fredoka Bold
- 正文字体: Nunito Regular
- 圆角: 10-18px
- 设计语言: 暖调案卷风

---

## 📝 Prototype 边界

本 prototype 仅验证核心交互与视觉：

- ✅ 完整五步破案流程（接案→搜证→审讯→结案→庆祝）
- ✅ 事务所主界面 + 冷案档案室
- ✅ 接案密函动画 + 庆祝烟花
- ✅ 点击模拟语音（搜证+跟读）
- ❌ 真实语音识别（后续）
- ❌ 教材切换、家长功能、数据持久化（后续）
- ❌ 艾宾浩斯算法、完整游戏化系统（后续）

---

## 📄 相关文档

- [产品设计文档](docs/specs/2026-07-21-english-detective-design.md)
- [Prototype 实现计划](docs/superpowers/plans/2026-07-21-prototype-plan.md)

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
