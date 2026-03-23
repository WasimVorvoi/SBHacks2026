# Clutch — Grind To Game

**Clutch** is a gamified productivity app that turns your to-do list into a competitive game. Earn points for completing tasks, climb leaderboards, challenge friends, and unlock achievements — all powered by AI difficulty ratings.

Built for **HackSB 2026** at UC Santa Barbara.

---

## Features

### Task Management
- Create tasks with titles, descriptions, categories, deadlines, and estimated time frames
- 8 task categories: General, Homework, Exam Prep, Project, Reading, Fitness, Creative, Chores
- AI-powered difficulty rating (1–10) using GPT-4o-mini with intelligent local fallback
- Points calculated from difficulty, time bonus, and urgency

### Gamification
- **Points System** — Base points scale with difficulty, plus time and urgency bonuses (15–90+ pts per task)
- **Leveling** — Progress through Rookie, Grinder, Warrior, Elite, Legend, and Mythic tiers
- **Streaks** — Track daily completion streaks with best-streak records
- **25 Challenges** — Daily, weekly, category-specific, and milestone challenges with bonus point rewards

### Competition
- **Global Leaderboard** — Compete with all users, filterable by All Time or This Week
- **Friends** — Add friends by unique 8-character codes, send/accept/decline requests
- **Groups** — Create or join groups with 6-character codes, view group leaderboards
- **Race Mode** — First-to-reach point targets within groups

### Cross-Platform
- Native iOS app (Swift/UIKit)
- Companion web app (HTML/CSS/JavaScript)
- Real-time sync via Firebase Realtime Database

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| iOS App | Swift 5, UIKit (programmatic UI) |
| Web App | Vanilla HTML/CSS/JavaScript |
| Backend | Firebase Realtime Database (REST API) |
| AI | OpenAI GPT-4o-mini |
| Design | Dark cyberpunk theme |

---

## Architecture

```
HackSB26/
├── HackSB26/
│   ├── Models/
│   │   ├── TaskItem.swift          # Task data model with categories, scoring, status
│   │   └── UserProfile.swift       # User profile, groups, leaderboard entries
│   ├── Services/
│   │   ├── ChallengesManager.swift # 25 challenges with progress tracking
│   │   ├── ClaudeAPIService.swift  # AI difficulty rating + local fallback
│   │   ├── FirebaseService.swift   # Firebase REST API (leaderboard, friends, groups)
│   │   ├── PointsCalculator.swift  # Scoring formula and cheat detection
│   │   ├── TaskStore.swift         # Persistence (UserDefaults) + Firebase sync
│   │   └── Theme.swift             # Dark cyberpunk design system
│   └── ViewControllers/
│       ├── MainTabBarController.swift
│       ├── OnboardingViewController.swift
│       ├── TaskListViewController.swift
│       ├── AddTaskViewController.swift
│       ├── CalendarViewController.swift
│       ├── CompeteViewController.swift
│       ├── LeaderboardViewController.swift
│       ├── FriendsViewController.swift
│       ├── GroupsViewController.swift
│       ├── GroupDetailViewController.swift
│       ├── ChallengesViewController.swift
│       ├── ProfileViewController.swift
│       └── UserProfileDetailViewController.swift
├── Website/
│   ├── index.html
│   ├── script.js
│   └── style.css
└── README.md
```

---

## Scoring System

| Factor | Calculation |
|--------|------------|
| Base Points | `difficulty × 10` |
| Time Bonus | `max(1, 6 - floor(hours)) × 5` (up to 30 pts) |
| Urgency Bonus | 20 pts if < 24h, 10 pts if < 72h |
| **Total Range** | **15 – 90+ points per task** |

**Leveling:** Level = `totalPoints / 150 + 1`

| Level Range | Title |
|-------------|-------|
| 1–5 | Rookie |
| 6–10 | Grinder |
| 11–20 | Warrior |
| 21–35 | Elite |
| 36–50 | Legend |
| 51+ | Mythic |

---

## Getting Started

### iOS App
1. Open `HackSB26.xcodeproj` in Xcode 16+
2. Select an iOS 18+ simulator or device
3. Build and run

### Website
1. Copy `config.example.js` to `config.js` and add your OpenAI API key
2. Open `index.html` in a browser

---

## Team

Built at HackSB 2026 — UC Santa Barbara

---

## License

This project was built for HackSB 2026.
