// ============================================
// CLUTCH — FULL APPLICATION
// ============================================

const EMOJIS = [
    "⚡",
    "🔥",
    "🧠",
    "🎯",
    "💎",
    "🦊",
    "🐉",
    "👾",
    "🚀",
    "⚔️",
    "🎮",
    "🌟",
];
const CATEGORIES = [
    {
        id: "general",
        label: "General",
        icon: "📋",
        color: "#9E9E9E",
    },
    {
        id: "homework",
        label: "Homework",
        icon: "✏️",
        color: "#2196F3",
    },
    {
        id: "exam",
        label: "Exam Prep",
        icon: "🧠",
        color: "#9C27B0",
    },
    {
        id: "project",
        label: "Project",
        icon: "🔨",
        color: "#FF9800",
    },
    {
        id: "reading",
        label: "Reading",
        icon: "📖",
        color: "#4CAF50",
    },
    {
        id: "fitness",
        label: "Fitness",
        icon: "🏃",
        color: "#F44336",
    },
    {
        id: "creative",
        label: "Creative",
        icon: "🎨",
        color: "#E91E63",
    },
    { id: "chores", label: "Chores", icon: "🏠", color: "#FFEB3B" },
];
const MODES = [
    { id: "private", label: "Private", icon: "🔒" },
    { id: "friends", label: "Friends", icon: "👥" },
    { id: "global", label: "Global", icon: "🌐" },
];
const TIME_OPTIONS = [
    { l: "⚡ Instant", v: 0 },
    { l: "15m", v: 15 },
    { l: "30m", v: 30 },
    { l: "1h", v: 60 },
    { l: "2h", v: 120 },
    { l: "3h", v: 180 },
    { l: "5h", v: 300 },
];

// ============================================
// CHALLENGES CATALOG
// Each challenge: id, title, desc, icon, bonus, windowDays,
//   type: "count"|"points"|"streak"|"difficulty"|"category_points"|"category_count"|"all_categories"|"speed"
//   target: number
//   category: optional category id filter
// ============================================
const CHALLENGES = [
    // ── Daily ──────────────────────────────────
    {
        id: "daily_first",
        title: "Early Bird",
        desc: "Complete 1 task today",
        icon: "🌅",
        bonus: 25,
        windowDays: 1,
        type: "count",
        target: 1,
    },
    {
        id: "daily_three",
        title: "Hat Trick",
        desc: "Complete 3 tasks in one day",
        icon: "🎩",
        bonus: 75,
        windowDays: 1,
        type: "count",
        target: 3,
    },
    {
        id: "daily_five",
        title: "On Fire",
        desc: "Complete 5 tasks in one day",
        icon: "🔥",
        bonus: 150,
        windowDays: 1,
        type: "count",
        target: 5,
    },
    {
        id: "daily_hard",
        title: "Clutch Play",
        desc: "Complete a difficulty 8+ task today",
        icon: "⚔️",
        bonus: 100,
        windowDays: 1,
        type: "difficulty",
        target: 8,
    },
    {
        id: "daily_speed",
        title: "Speed Run",
        desc: "Complete 2 tasks within 1 hour of each other today",
        icon: "⚡",
        bonus: 80,
        windowDays: 1,
        type: "speed",
        target: 2,
    },
    // ── Weekly ─────────────────────────────────
    {
        id: "weekly_ten",
        title: "Grind Mode",
        desc: "Complete 10 tasks this week",
        icon: "💪",
        bonus: 200,
        windowDays: 7,
        type: "count",
        target: 10,
    },
    {
        id: "weekly_points",
        title: "Point Chaser",
        desc: "Earn 500 points this week",
        icon: "⭐",
        bonus: 250,
        windowDays: 7,
        type: "points",
        target: 500,
    },
    {
        id: "weekly_bigpoints",
        title: "Elite Grinder",
        desc: "Earn 1000 points this week",
        icon: "💎",
        bonus: 500,
        windowDays: 7,
        type: "points",
        target: 1000,
    },
    {
        id: "weekly_hard",
        title: "Hard Mode",
        desc: "Complete 3 difficulty 7+ tasks this week",
        icon: "🧠",
        bonus: 300,
        windowDays: 7,
        type: "difficulty",
        target: 7,
        count: 3,
    },
    {
        id: "weekly_extreme",
        title: "Extreme Run",
        desc: "Complete a difficulty 10 task this week",
        icon: "👾",
        bonus: 400,
        windowDays: 7,
        type: "difficulty",
        target: 10,
        count: 1,
    },
    {
        id: "weekly_streak",
        title: "Consistent",
        desc: "Complete at least 1 task every day for 5 days",
        icon: "📅",
        bonus: 350,
        windowDays: 7,
        type: "streak",
        target: 5,
    },
    // ── Category specific ──────────────────────
    {
        id: "cat_exam",
        title: "Study Grind",
        desc: "Earn 300 points from Exam Prep tasks this week",
        icon: "🧪",
        bonus: 200,
        windowDays: 7,
        type: "category_points",
        target: 300,
        category: "exam",
    },
    {
        id: "cat_fitness",
        title: "Fitness Freak",
        desc: "Complete 5 Fitness tasks this week",
        icon: "🏃",
        bonus: 175,
        windowDays: 7,
        type: "category_count",
        target: 5,
        category: "fitness",
    },
    {
        id: "cat_creative",
        title: "Creative Burst",
        desc: "Complete 3 Creative tasks this week",
        icon: "🎨",
        bonus: 150,
        windowDays: 7,
        type: "category_count",
        target: 3,
        category: "creative",
    },
    {
        id: "cat_project",
        title: "Project Mode",
        desc: "Earn 400 points from Project tasks this week",
        icon: "🔨",
        bonus: 250,
        windowDays: 7,
        type: "category_points",
        target: 400,
        category: "project",
    },
    // ── All-time / milestone ───────────────────
    {
        id: "milestone_10",
        title: "Getting Started",
        desc: "Complete 10 tasks total",
        icon: "🚀",
        bonus: 100,
        windowDays: 0,
        type: "count_alltime",
        target: 10,
    },
    {
        id: "milestone_50",
        title: "Committed",
        desc: "Complete 50 tasks total",
        icon: "🎯",
        bonus: 300,
        windowDays: 0,
        type: "count_alltime",
        target: 50,
    },
    {
        id: "milestone_100",
        title: "Century Club",
        desc: "Complete 100 tasks total",
        icon: "🏆",
        bonus: 750,
        windowDays: 0,
        type: "count_alltime",
        target: 100,
    },
    {
        id: "milestone_streak10",
        title: "Unbreakable",
        desc: "Reach a 10-day streak",
        icon: "🔥",
        bonus: 500,
        windowDays: 0,
        type: "streak_alltime",
        target: 10,
    },
    {
        id: "all_categories",
        title: "Renaissance",
        desc: "Complete a task in every category this week",
        icon: "🌟",
        bonus: 400,
        windowDays: 7,
        type: "all_categories",
        target: CATEGORIES.length,
    },
];
// ============================================
let state = {
    onboarded: false,
    profile: {
        name: "Player",
        emoji: "⚡",
        totalPoints: 0,
        tasksCompleted: 0,
        streak: 0,
        bestStreak: 0,
        level: 1,
    },
    tasks: [],
    groups: [],
    completedChallenges: {},
    currentTab: "tasks",
    calMonth: new Date().getMonth(),
    calYear: new Date().getFullYear(),
    calSelectedDate: new Date(),
    competeSection: "leaderboard",
    taskFilter: "active",
};

function save() {
    localStorage.setItem("clutch_state", JSON.stringify(state));
}
function load() {
    const d = localStorage.getItem("clutch_state");
    if (d) {
        try {
            state = JSON.parse(d);
        } catch (e) {}
    }
}

// ============================================
// UTILITY
// ============================================
function diffColor(d) {
    if (d <= 3) return "var(--easy)";
    if (d <= 6) return "var(--medium)";
    if (d <= 8) return "var(--hard)";
    return "var(--extreme)";
}
function diffLabel(d) {
    if (d <= 3) return "Easy";
    if (d <= 6) return "Medium";
    if (d <= 8) return "Hard";
    return "Extreme";
}
function calcPoints(d, timeMins, deadline, created) {
    const base = d * 10;
    const timeBonus = Math.max(1, 6 - Math.floor(timeMins / 60)) * 5;
    const hrs = (deadline - created) / 3600000;
    const urgency = hrs < 24 ? 20 : hrs < 72 ? 10 : 0;
    return base + timeBonus + urgency;
}
function calcLevel(pts) {
    let lv = 1,
        th = 150,
        p = pts;
    while (p >= th) {
        p -= th;
        lv++;
        th = lv * 150;
    }
    return lv;
}
function levelProgress(pts) {
    let lv = 1,
        th = 150,
        p = pts;
    while (p >= th) {
        p -= th;
        lv++;
        th = lv * 150;
    }
    return p / th;
}
function levelTitle(lv) {
    if (lv <= 5) return "Rookie";
    if (lv <= 10) return "Grinder";
    if (lv <= 20) return "Warrior";
    if (lv <= 35) return "Elite";
    if (lv <= 50) return "Legend";
    return "Mythic";
}
function timeUntil(deadline) {
    const diff = deadline - Date.now();
    if (diff < 0) return "Started";
    const h = Math.floor(diff / 3600000);
    if (h < 24) return "Starts in " + h + "h";
    return "Starts in " + Math.floor(h / 24) + "d";
}
function fmtDate(d) {
    const dt = new Date(d);
    return dt.toLocaleDateString("en-US", {
        weekday: "long",
        month: "short",
        day: "numeric",
    });
}
function fmtTime(d) {
    return new Date(d).toLocaleTimeString("en-US", {
        hour: "numeric",
        minute: "2-digit",
    });
}
function startOfDay(date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
}
function isSameDay(a, b) {
    return startOfDay(a) === startOfDay(b);
}

// ============================================
// CHALLENGE ENGINE
// ============================================
function getChallengeProgress(ch) {
    const now = Date.now();
    const windowMs = ch.windowDays > 0 ? ch.windowDays * 86400000 : Infinity;
    const since = ch.windowDays > 0 ? now - windowMs : 0;
    const windowTasks = state.tasks.filter(
        (t) => t.completed && !t.flagged && t.completedAt >= since,
    );

    switch (ch.type) {
        case "count":
            return { value: windowTasks.length, max: ch.target };
        case "count_alltime":
            return { value: state.profile.tasksCompleted || 0, max: ch.target };
        case "points":
            return {
                value: windowTasks.reduce((s, t) => s + t.points, 0),
                max: ch.target,
            };
        case "difficulty": {
            const qualified = windowTasks.filter(
                (t) => t.difficulty >= ch.target,
            );
            const needed = ch.count || 1;
            return { value: qualified.length, max: needed };
        }
        case "streak":
            // count distinct days in window with at least 1 completion
            const days = new Set(
                windowTasks.map((t) => startOfDay(t.completedAt)),
            );
            return { value: days.size, max: ch.target };
        case "streak_alltime":
            return {
                value: state.profile.bestStreak || 0,
                max: ch.target,
            };
        case "category_points":
            return {
                value: windowTasks
                    .filter((t) => t.category === ch.category)
                    .reduce((s, t) => s + t.points, 0),
                max: ch.target,
            };
        case "category_count":
            return {
                value: windowTasks.filter((t) => t.category === ch.category)
                    .length,
                max: ch.target,
            };
        case "all_categories": {
            const cats = new Set(windowTasks.map((t) => t.category));
            return { value: cats.size, max: CATEGORIES.length };
        }
        case "speed": {
            // Find any pair of completions within 60 min of each other
            const sorted = windowTasks
                .map((t) => t.completedAt)
                .sort((a, b) => a - b);
            let pairs = 0;
            for (let i = 1; i < sorted.length; i++) {
                if (sorted[i] - sorted[i - 1] <= 3600000) {
                    pairs++;
                    break;
                }
            }
            return {
                value: pairs > 0 ? 2 : windowTasks.length > 0 ? 1 : 0,
                max: 2,
            };
        }
        default:
            return { value: 0, max: ch.target };
    }
}

// Called after every task completion — awards bonus points for newly completed challenges
function evaluateChallenges() {
    if (!state.completedChallenges) state.completedChallenges = {};
    let newlyCompleted = [];

    CHALLENGES.forEach((ch) => {
        // For windowed challenges, reset completion if window has expired
        if (ch.windowDays > 0 && state.completedChallenges[ch.id]) {
            const completedAt = state.completedChallenges[ch.id].completedAt;
            if (Date.now() - completedAt > ch.windowDays * 86400000) {
                delete state.completedChallenges[ch.id];
            }
        }
        if (state.completedChallenges[ch.id]) return; // already done

        const { value, max } = getChallengeProgress(ch);
        if (value >= max) {
            state.completedChallenges[ch.id] = {
                completedAt: Date.now(),
                bonusAwarded: ch.bonus,
            };
            state.profile.totalPoints += ch.bonus;
            state.profile.level = calcLevel(state.profile.totalPoints);
            newlyCompleted.push(ch);
        }
    });

    if (newlyCompleted.length) {
        save();
        // Show a toast for each
        newlyCompleted.forEach((ch) => showChallengeToast(ch));
    }
}

function showChallengeToast(ch) {
    const toast = document.createElement("div");
    toast.className = "challenge-toast";
    toast.innerHTML = `<span style="font-size:22px;">${ch.icon}</span>
        <div>
            <div style="font-size:13px;font-weight:800;">Challenge Complete!</div>
            <div style="font-size:12px;color:var(--text-dim);">${ch.title} · <span style="color:var(--neon);font-weight:700;">+${ch.bonus} pts</span></div>
        </div>`;
    document.body.appendChild(toast);
    setTimeout(() => toast.classList.add("show"), 50);
    setTimeout(() => {
        toast.classList.remove("show");
        setTimeout(() => toast.remove(), 400);
    }, 3500);
}

// ============================================
// AI SERVICE (OpenAI API + local fallback)
// ============================================
const OPENAI_API_KEY =
    typeof CONFIG !== "undefined" && CONFIG.OPENAI_API_KEY
        ? CONFIG.OPENAI_API_KEY
        : "";
const OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions";

async function aiRateDifficulty(title, desc, timeMins, category) {
    if (!OPENAI_API_KEY) return localDifficulty(title, desc, timeMins);
    try {
        const durationLabel =
            timeMins === 0
                ? "Instant (under 5 minutes)"
                : timeMins < 60
                  ? `${timeMins} minutes`
                  : `${Math.floor(timeMins / 60)}h${timeMins % 60 ? " " + (timeMins % 60) + "m" : ""}`;

        const prompt = `You are a productivity coach rating task difficulty on a scale of 1–10.

Task name: "${title}"
${desc ? `Details: "${desc}"` : ""}
Category: ${category}
Estimated duration: ${durationLabel}

Difficulty scale:
1–2 = trivial (e.g. send a text, drink water)
3–4 = easy (e.g. reply to an email, quick chore)
5–6 = moderate (e.g. write a short essay, 1-hour study session)
7–8 = hard (e.g. debug complex code, 3-hour deep work session)
9–10 = extreme (e.g. all-day exam prep, major project milestone)

Consider BOTH the task name/nature AND the duration when rating. A 5-hour easy task is harder than a 30-minute easy task. An instant task should generally score 1–3 unless it sounds stressful.

Respond ONLY with valid JSON, no extra text:
{"difficulty":<1-10>,"reasoning":"<one concise sentence explaining the rating>","tips":"<one actionable tip to tackle this task>"}`;

        const res = await fetch(OPENAI_ENDPOINT, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${OPENAI_API_KEY}`,
            },
            body: JSON.stringify({
                model: "gpt-4o-mini",
                max_tokens: 200,
                temperature: 0.4,
                messages: [{ role: "user", content: prompt }],
            }),
        });
        const data = await res.json();
        if (data.error) throw new Error(data.error.message);
        const text = data.choices[0].message.content;
        const clean = text.replace(/```json|```/g, "").trim();
        const json = JSON.parse(clean);
        return {
            difficulty: Math.max(1, Math.min(10, Math.round(json.difficulty))),
            reasoning: json.reasoning,
            tips: json.tips,
        };
    } catch (e) {
        return localDifficulty(title, desc, timeMins);
    }
}

function localDifficulty(title, desc, timeMins) {
    const text = (title + " " + desc).toLowerCase();
    let score = 5;
    [
        "exam",
        "final",
        "thesis",
        "research",
        "presentation",
        "essay",
        "analysis",
        "complex",
        "debug",
        "deploy",
    ].forEach((k) => {
        if (text.includes(k)) score++;
    });
    [
        "clean",
        "organize",
        "email",
        "read",
        "review",
        "list",
        "simple",
        "basic",
        "quick",
    ].forEach((k) => {
        if (text.includes(k)) score--;
    });
    if (timeMins > 180) score++;
    if (timeMins < 30) score--;
    score = Math.max(1, Math.min(10, score));
    return {
        difficulty: score,
        reasoning: "Estimated from keywords & time frame",
        tips: "Break large tasks into smaller chunks",
    };
}

function checkCheat(task, completionMins) {
    // Instant tasks are never flagged — they're designed to be done immediately
    if (task.isInstant) return { suspicious: false, reason: "Instant task" };

    // For timed tasks that were started, check against actual elapsed time
    if (task.startedAt && task.timeFrameMinutes > 0) {
        const elapsedMins = (Date.now() - task.startedAt) / 60000;
        const expected = task.timeFrameMinutes;
        const ratio = elapsedMins / expected;
        // Must be at least 70% of the estimated duration
        if (ratio < 0.7) {
            return {
                suspicious: true,
                reason: `Ended after ${Math.round(elapsedMins)}m but estimated ${expected}m — too fast`,
            };
        }
        return { suspicious: false, reason: "Duration looks good" };
    }

    // Fallback: old ratio check for tasks without start tracking
    const ratio = completionMins / Math.max(1, task.timeFrameMinutes);
    const suspicious =
        (task.difficulty >= 7 && ratio < 0.1) ||
        (task.difficulty >= 5 && ratio < 0.05);
    return {
        suspicious,
        reason: suspicious
            ? "Completed unusually fast for difficulty"
            : "Seems reasonable",
    };
}

// ============================================
// ONBOARDING
// ============================================
let onbStep = 0;
let selectedEmoji = "⚡";

function initOnboarding() {
    if (state.onboarded) {
        showApp();
        return;
    }
    // Build emoji grid
    const grid = document.getElementById("emojiGrid");
    grid.innerHTML = EMOJIS.map(
        (e) =>
            `<button class="emoji-pick${e === selectedEmoji ? " selected" : ""}" data-emoji="${e}">${e}</button>`,
    ).join("");
    grid.addEventListener("click", (e) => {
        const btn = e.target.closest(".emoji-pick");
        if (!btn) return;
        selectedEmoji = btn.dataset.emoji;
        grid.querySelectorAll(".emoji-pick").forEach((b) =>
            b.classList.remove("selected"),
        );
        btn.classList.add("selected");
        document.getElementById("selectedEmojiDisplay").textContent =
            selectedEmoji;
    });
    // Dots
    renderOnbDots();
    document.getElementById("onbNext").addEventListener("click", nextOnbStep);
}

function renderOnbDots() {
    document.getElementById("onbDots").innerHTML = [0, 1, 2]
        .map((i) => `<div class="dot${i === onbStep ? " active" : ""}"></div>`)
        .join("");
}

function nextOnbStep() {
    if (onbStep < 2) {
        document
            .getElementById(`onb-step-${onbStep}`)
            .classList.remove("active");
        onbStep++;
        document.getElementById(`onb-step-${onbStep}`).classList.add("active");
        renderOnbDots();
        document.getElementById("onbNext").textContent =
            onbStep === 2 ? "Let's Go" : "Next";
    } else {
        const name = document.getElementById("onbName").value.trim();
        if (!name) {
            document.getElementById("onbName").style.borderColor =
                "var(--danger)";
            return;
        }
        state.profile.name = name;
        state.profile.emoji = selectedEmoji;
        state.onboarded = true;
        save();
        showApp();
    }
}

function showApp() {
    document.getElementById("onboarding").classList.remove("active");
    document.getElementById("screen-tasks").classList.add("active");
    document.querySelector(".tab-bar").style.display = "flex";
    syncLeaderboard();
    renderTasks();
}

// ============================================
// NAVIGATION
// ============================================
function initNav() {
    document.querySelectorAll(".tab-btn").forEach((btn) => {
        btn.addEventListener("click", () => {
            const tab = btn.dataset.tab;
            if (!tab) return;
            switchTab(tab);
        });
    });
    document.getElementById("fabAdd").addEventListener("click", openAddTask);
}

function switchTab(tab) {
    state.currentTab = tab;
    document
        .querySelectorAll(".screen")
        .forEach((s) => s.classList.remove("active"));
    document
        .querySelectorAll(".tab-btn")
        .forEach((b) => b.classList.remove("active"));
    document.getElementById(`screen-${tab}`).classList.add("active");
    document
        .querySelector(`.tab-btn[data-tab="${tab}"]`)
        .classList.add("active");
    if (tab === "tasks") renderTasks();
    else if (tab === "calendar") renderCalendar();
    else if (tab === "compete") renderCompete();
    else if (tab === "profile") renderProfile();
}

// ============================================
// TASKS SCREEN
// ============================================
function renderTasks() {
    const p = state.profile;
    if (p.streak > 0) {
        document.getElementById("streakBadge").style.display = "flex";
        document.getElementById("streakCount").textContent = p.streak;
    } else {
        document.getElementById("streakBadge").style.display = "none";
    }

    // Filters
    const filters = document.getElementById("taskFilters");
    filters.innerHTML = ["active", "today", "done"]
        .map(
            (f) =>
                `<button class="chip${state.taskFilter === f ? " active" : ""}" data-filter="${f}">${f.charAt(0).toUpperCase() + f.slice(1)}</button>`,
        )
        .join("");
    filters.addEventListener("click", (e) => {
        const btn = e.target.closest(".chip");
        if (!btn) return;
        state.taskFilter = btn.dataset.filter;
        renderTasks();
    });

    let filtered;
    if (state.taskFilter === "active")
        filtered = state.tasks
            .filter((t) => !t.completed)
            .sort((a, b) => a.deadline - b.deadline);
    else if (state.taskFilter === "today")
        filtered = state.tasks
            .filter((t) => isSameDay(t.deadline, Date.now()))
            .sort((a, b) => a.deadline - b.deadline);
    else
        filtered = state.tasks
            .filter((t) => t.completed)
            .sort((a, b) => (b.completedAt || 0) - (a.completedAt || 0));

    const active = state.tasks.filter((t) => !t.completed).length;
    document.getElementById("taskSubheader").textContent = `${active} active`;

    const list = document.getElementById("taskList");
    if (!filtered.length) {
        list.innerHTML = `<div class="empty-state"><div class="emoji">🎯</div><h3>No tasks here</h3><p>Tap + to add your first task</p></div>`;
        return;
    }

    list.innerHTML = filtered
        .map((t) => {
            const cat =
                CATEGORIES.find((c) => c.id === t.category) || CATEGORIES[0];
            const dots = Array.from(
                { length: 5 },
                (_, i) =>
                    `<span class="diff-dot" style="background:${i < Math.ceil(t.difficulty / 2) ? diffColor(t.difficulty) : "rgba(85,85,119,0.3)"}"></span>`,
            ).join("");
            return `
    <div class="task-card${t.flagged ? " flagged" : ""}" data-id="${t.id}" onclick="toggleTask('${t.id}')">
      <div class="task-main">
        <div class="task-diff-bar" style="background:${diffColor(t.difficulty)}"></div>
        <div class="task-info">
          <div class="task-title${t.completed ? " done" : ""}">${t.flagged ? "⚠️ " : ""}${esc(t.title)}</div>
          <div class="task-meta">
            <span style="color:${cat.color}">${cat.icon} ${cat.label}</span>
            <span class="${t.deadline < Date.now() && !t.completed ? "overdue" : ""}">⏱ ${timeUntil(t.deadline)}</span>
            ${t.assignedGroup ? `<span class="task-group-badge">👥 Group</span>` : ""}
          </div>
        </div>
        <div class="task-right">
          <div class="task-points">+${t.points}</div>
          <div class="task-dots">${dots}</div>
        </div>
        <span class="task-chevron">›</span>
      </div>
      <div class="task-expanded">
        ${t.description ? `<div class="task-desc">${esc(t.description)}</div>` : ""}
        <div class="task-detail-meta">
          <span>⏱ ${t.isInstant ? "⚡ Instant" : t.timeFrameMinutes >= 60 ? Math.floor(t.timeFrameMinutes / 60) + "h" + (t.timeFrameMinutes % 60 ? " " + (t.timeFrameMinutes % 60) + "m" : "") : t.timeFrameMinutes + "min"}</span>
          <span>📊 ${diffLabel(t.difficulty)}</span>
          <span>${MODES.find((m) => m.id === t.competitionMode)?.icon || "🔒"} ${MODES.find((m) => m.id === t.competitionMode)?.label || "Private"}</span>
          ${t.assignedGroup ? `<span class="task-group-badge">👥 <span class="grp-tag-${t.assignedGroup}">${t.assignedGroup}</span></span>` : ""}
        </div>
        ${t.flagged ? `<div class="flag-warning">⚠️ ${t.flagReason || "Flagged for review"} — No points awarded</div>` : ""}
        ${
            !t.completed
                ? (() => {
                      if (t.isInstant) {
                          const diff = t.deadline - Date.now();
                          const absDiff = Math.abs(diff);
                          const inWindow = absDiff <= 5 * 60 * 1000;
                          const minsUntil = Math.round(diff / 60000);
                          return `<div class="instant-banner${inWindow ? " instant-active" : ""}">
                            ${
                                inWindow
                                    ? `⚡ In window — complete now!`
                                    : diff > 0
                                      ? `⚡ Instant — opens in ${minsUntil}m`
                                      : `⚡ Instant — window closed ${Math.abs(minsUntil)}m ago`
                            }
                        </div>
                        <div class="task-actions">
                          <button class="btn-complete" onclick="event.stopPropagation();completeTask('${t.id}')">✓ Complete</button>
                          <button class="btn-delete" onclick="event.stopPropagation();deleteTask('${t.id}')">🗑 Delete</button>
                        </div>`;
                      } else if (t.timeFrameMinutes > 0) {
                          if (!t.startedAt) {
                              return `<div class="task-actions">
                              <button class="btn-start" onclick="event.stopPropagation();startTask('${t.id}')">▶ Start Task</button>
                              <button class="btn-delete" onclick="event.stopPropagation();deleteTask('${t.id}')">🗑 Delete</button>
                            </div>`;
                          } else {
                              const elapsedMs = Date.now() - t.startedAt;
                              const elapsedMins = Math.floor(elapsedMs / 60000);
                              const elapsedSecs = Math.floor(
                                  (elapsedMs % 60000) / 1000,
                              );
                              const pct = Math.min(
                                  100,
                                  (elapsedMins / t.timeFrameMinutes) * 100,
                              );
                              const onTrack =
                                  elapsedMins >=
                                  Math.floor(t.timeFrameMinutes * 0.7);
                              return `<div class="timer-display" data-task-id="${t.id}" data-started="${t.startedAt}" data-duration="${t.timeFrameMinutes}">
                                <div class="timer-row">
                                  <span class="timer-label">⏱ In progress</span>
                                  <span class="timer-clock" id="timer-${t.id}">${elapsedMins}m ${elapsedSecs}s</span>
                                </div>
                                <div class="timer-track"><div class="timer-fill" style="width:${pct}%"></div></div>
                                <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">${onTrack ? "✅ On track to complete" : `${t.timeFrameMinutes - elapsedMins}m remaining`}</div>
                            </div>
                            <div class="task-actions">
                              <button class="btn-complete${onTrack ? "" : " btn-complete-dim"}" onclick="event.stopPropagation();completeTask('${t.id}')">■ End Task</button>
                              <button class="btn-delete" onclick="event.stopPropagation();deleteTask('${t.id}')">🗑 Delete</button>
                            </div>`;
                          }
                      } else {
                          return `<div class="task-actions">
                          <button class="btn-complete" onclick="event.stopPropagation();completeTask('${t.id}')">✓ Complete</button>
                          <button class="btn-delete" onclick="event.stopPropagation();deleteTask('${t.id}')">🗑 Delete</button>
                        </div>`;
                      }
                  })()
                : ""
        }
      </div>
    </div>`;
        })
        .join("");

    // Resolve group names for task badges
    const groupCodesToResolve = [
        ...new Set(
            filtered.filter((t) => t.assignedGroup).map((t) => t.assignedGroup),
        ),
    ];
    groupCodesToResolve.forEach(async (code) => {
        try {
            const snap = await db.ref(`groups/${code}/name`).once("value");
            const name = snap.val();
            if (name) {
                document
                    .querySelectorAll(`.grp-tag-${code}`)
                    .forEach((el) => (el.textContent = name));
            }
        } catch (e) {}
    });

    // Live timer tick for in-progress tasks
    startLiveTimers();
}

let _timerInterval = null;
function startLiveTimers() {
    if (_timerInterval) clearInterval(_timerInterval);
    const hasRunning = state.tasks.some(
        (t) => !t.completed && t.startedAt && t.timeFrameMinutes > 0,
    );
    if (!hasRunning) return;
    _timerInterval = setInterval(() => {
        document.querySelectorAll(".timer-display").forEach((el) => {
            const startedAt = +el.dataset.started;
            const duration = +el.dataset.duration;
            const taskId = el.dataset.taskId;
            const elapsedMs = Date.now() - startedAt;
            const elapsedMins = Math.floor(elapsedMs / 60000);
            const elapsedSecs = Math.floor((elapsedMs % 60000) / 1000);
            const pct = Math.min(100, (elapsedMins / duration) * 100);
            const onTrack = elapsedMins >= Math.floor(duration * 0.7);
            const clock = document.getElementById(`timer-${taskId}`);
            if (clock) clock.textContent = `${elapsedMins}m ${elapsedSecs}s`;
            const fill = el.querySelector(".timer-fill");
            if (fill) fill.style.width = pct + "%";
            const hint = el.querySelector("div:last-child");
            if (hint)
                hint.textContent = onTrack
                    ? "✅ On track to complete"
                    : `${duration - elapsedMins}m remaining`;
        });
    }, 1000);
}

function toggleTask(id) {
    const el = document.querySelector(`.task-card[data-id="${id}"]`);
    if (el) el.classList.toggle("expanded");
}

function startTask(id) {
    const t = state.tasks.find((x) => x.id === id);
    if (!t || t.completed || t.startedAt) return;
    t.startedAt = Date.now();
    save();
    syncMyTasksToFirebase();
    renderTasks();
}

function completeTask(id) {
    const t = state.tasks.find((x) => x.id === id);
    if (!t || t.completed) return;

    // Instant task: must be completed within ±5 min of its deadline
    if (t.isInstant) {
        const diff = Math.abs(Date.now() - t.deadline);
        if (diff > 5 * 60 * 1000) {
            const minsOff = Math.round(diff / 60000);
            const direction =
                Date.now() < t.deadline ? "too early" : "too late";
            if (
                !confirm(
                    `⚠️ You're ${minsOff}m ${direction} for this instant task (±5 min window).\nComplete anyway without points?`,
                )
            )
                return;
            t.completed = true;
            t.completedAt = Date.now();
            t.flagged = true;
            t.flagReason = `Completed ${minsOff}m ${direction} — outside ±5 min window`;
            t.points = 0;
            save();
            syncMyTasksToFirebase();
            renderTasks();
            return;
        }
    }

    const completionMins = Math.floor((Date.now() - t.createdAt) / 60000);
    const cheat = checkCheat(t, completionMins);
    t.completed = true;
    t.completedAt = Date.now();
    if (cheat.suspicious) {
        t.flagged = true;
        t.flagReason = cheat.reason;
        t.points = 0;
        alert("⚠️ Flagged: " + cheat.reason + "\nNo points awarded.");
    } else {
        state.profile.totalPoints += t.points;
        state.profile.tasksCompleted++;
        state.profile.streak++;
        state.profile.bestStreak = Math.max(
            state.profile.bestStreak,
            state.profile.streak,
        );
        state.profile.level = calcLevel(state.profile.totalPoints);
    }
    save();
    evaluateChallenges();
    syncMyTasksToFirebase();
    renderTasks();
}

function deleteTask(id) {
    if (!confirm("Delete this task?")) return;
    state.tasks = state.tasks.filter((t) => t.id !== id);
    save();
    syncMyTasksToFirebase();
    renderTasks();
}

function esc(s) {
    const d = document.createElement("div");
    d.textContent = s;
    return d.innerHTML;
}

// ============================================
// ADD TASK MODAL
// ============================================
let addStep = 0;
let addForm = {
    title: "",
    desc: "",
    deadline: Date.now() + 86400000,
    timeMins: 60,
    isInstant: false,
    customTime: false,
    category: "general",
    mode: "private",
    assignedGroup: "",
    difficulty: 5,
    reasoning: "",
    tips: "",
};

function openAddTask() {
    addStep = 0;
    addForm = {
        title: "",
        desc: "",
        deadline: Date.now() + 86400000,
        timeMins: 60,
        isInstant: false,
        customTime: false,
        category: "general",
        mode: "private",
        assignedGroup: "",
        difficulty: 5,
        reasoning: "",
        tips: "",
    };
    renderAddModal();
    document.getElementById("addTaskModal").classList.add("open");
}
function closeAddTask() {
    document.getElementById("addTaskModal").classList.remove("open");
}

// Reads live text/date fields from the modal into addForm so re-renders don't lose user input
function snapshotFormFields(sheet) {
    const titleEl = sheet.querySelector("#atTitle");
    const descEl = sheet.querySelector("#atDesc");
    const deadlineEl = sheet.querySelector("#atDeadline");
    if (titleEl) addForm.title = titleEl.value;
    if (descEl) addForm.desc = descEl.value;
    if (deadlineEl && deadlineEl.value)
        addForm.deadline = new Date(deadlineEl.value).getTime();
    if (addForm.customTime) {
        const h = parseInt(sheet.querySelector("#atCustomHours")?.value) || 0;
        const m = parseInt(sheet.querySelector("#atCustomMins")?.value) || 0;
        const total = h * 60 + m;
        if (total > 0) addForm.timeMins = total;
    }
}

function renderAddModal() {
    const sheet = document.getElementById("modalSheet");
    if (addStep === 0) {
        const deadlineDate = new Date(addForm.deadline);
        // Format in local time for datetime-local input (avoid UTC shift)
        const pad = (n) => String(n).padStart(2, "0");
        const deadlineStr = `${deadlineDate.getFullYear()}-${pad(deadlineDate.getMonth() + 1)}-${pad(deadlineDate.getDate())}T${pad(deadlineDate.getHours())}:${pad(deadlineDate.getMinutes())}`;

        // Build group options for dropdown
        const groupCodes = state.myGroupCodes || [];
        let groupOptionsHtml = `<button class="chip${!addForm.assignedGroup ? " active" : ""}" data-grp="">🔒 Personal only</button>`;

        // We'll load group names async, but for now show codes
        // The names get filled in after render
        groupCodes.forEach((code) => {
            groupOptionsHtml += `<button class="chip${addForm.assignedGroup === code ? " active" : ""}" data-grp="${code}">👥 <span class="grp-name-${code}">${code}</span></button>`;
        });

        // Build time chips — include Custom option
        const timeChipsHtml =
            TIME_OPTIONS.map(
                (o) =>
                    `<button class="chip${o.v === 0 ? " chip-instant" : ""}${(o.v === 0 ? addForm.isInstant : !addForm.isInstant && !addForm.customTime && addForm.timeMins === o.v) ? " active" : ""}" data-time="${o.v}">${o.l}</button>`,
            ).join("") +
            `<button class="chip${addForm.customTime ? " active" : ""}" data-time="custom">Custom</button>`;

        sheet.innerHTML = `
      <div class="modal-header"><h2>New Task</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
      <div class="form-group"><label class="form-label">Title</label>
        <input class="input-field" id="atTitle" placeholder="e.g., Study for calculus final" value="${esc(addForm.title)}" maxlength="100"></div>
      <div class="form-group"><label class="form-label">Description</label>
        <textarea class="input-field" id="atDesc" placeholder="What does this involve?" rows="2">${esc(addForm.desc)}</textarea></div>
      <div class="form-group"><label class="form-label">Category</label>
        <div class="chip-row">${CATEGORIES.map((c) => `<button class="cat-chip${addForm.category === c.id ? " active" : ""}" data-cat="${c.id}"><span class="cat-icon">${c.icon}</span>${c.label}</button>`).join("")}</div></div>
      <div class="form-group"><label class="form-label">Start Date &amp; Time</label>
        <input type="datetime-local" class="input-field" id="atDeadline" value="${deadlineStr}"></div>
      <div class="form-group"><label class="form-label">Estimated Time</label>
        <div class="chip-row" id="timeChipRow">${timeChipsHtml}</div>
        <div id="customTimeRow" style="margin-top:8px;display:${addForm.customTime ? "flex" : "none"};gap:8px;align-items:center;">
            <input class="input-field" id="atCustomHours" type="number" min="0" max="99" placeholder="0" value="${addForm.customTime ? Math.floor(addForm.timeMins / 60) : ""}" style="width:70px;text-align:center;">
            <span style="font-size:13px;color:var(--text-dim);font-weight:600;">hrs</span>
            <input class="input-field" id="atCustomMins" type="number" min="0" max="59" step="5" placeholder="0" value="${addForm.customTime ? addForm.timeMins % 60 : ""}" style="width:70px;text-align:center;">
            <span style="font-size:13px;color:var(--text-dim);font-weight:600;">min</span>
        </div>
      </div>
      <div class="form-group" id="visibilitySection" style="display:${addForm.assignedGroup ? "none" : "block"}"><label class="form-label">Visibility</label>
        <div class="chip-row">${MODES.map((m) => `<button class="chip${addForm.mode === m.id ? " active" : ""}" data-mode="${m.id}">${m.icon} ${m.label}</button>`).join("")}</div></div>
      <div class="form-group" id="visibilityLocked" style="display:${addForm.assignedGroup ? "block" : "none"}"><label class="form-label">Visibility</label>
        <div style="display:flex;align-items:center;gap:10px;padding:10px 14px;background:var(--card);border-radius:10px;border:1px solid rgba(255,255,255,0.07);">
          <span style="font-size:18px;">👥</span>
          <div style="flex:1;">
            <div style="font-size:13px;font-weight:600;color:var(--text);">Visible to all group members</div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:2px;">Group tasks are always shared with the group</div>
          </div>
          <span style="font-size:16px;opacity:0.5;">🔒</span>
        </div>
      </div>
      ${
          groupCodes.length > 0
              ? `<div class="form-group"><label class="form-label">📌 Add to Group</label>
        <p style="font-size:12px;color:var(--text-muted);margin-bottom:8px;">Task will count toward the group's leaderboard & races</p>
        <div class="chip-row" id="groupChipRow">${groupOptionsHtml}</div>
      </div>`
              : ""
      }
      <button class="btn-primary" id="atNext">Rate Difficulty →</button>`;

        // Load group names from Firebase
        groupCodes.forEach(async (code) => {
            try {
                const snap = await db.ref(`groups/${code}/name`).once("value");
                const name = snap.val();
                if (name) {
                    const el = sheet.querySelector(`.grp-name-${code}`);
                    if (el) el.textContent = name;
                }
            } catch (e) {}
        });

        // Events — Category
        sheet.querySelectorAll(".cat-chip").forEach((b) =>
            b.addEventListener("click", () => {
                snapshotFormFields(sheet);
                addForm.category = b.dataset.cat;
                renderAddModal();
            }),
        );

        // Events — Time (with custom support)
        sheet.querySelectorAll("[data-time]").forEach((b) =>
            b.addEventListener("click", () => {
                snapshotFormFields(sheet);
                if (b.dataset.time === "custom") {
                    addForm.isInstant = false;
                    addForm.customTime = true;
                } else if (b.dataset.time === "0") {
                    addForm.isInstant = true;
                    addForm.customTime = false;
                    addForm.timeMins = 0;
                } else {
                    addForm.isInstant = false;
                    addForm.customTime = false;
                    addForm.timeMins = +b.dataset.time;
                }
                renderAddModal();
            }),
        );

        // Events — Mode
        sheet.querySelectorAll("[data-mode]").forEach((b) =>
            b.addEventListener("click", () => {
                snapshotFormFields(sheet);
                addForm.mode = b.dataset.mode;
                renderAddModal();
            }),
        );

        // Events — Group assignment
        sheet.querySelectorAll("[data-grp]").forEach((b) =>
            b.addEventListener("click", () => {
                addForm.assignedGroup = b.dataset.grp;
                sheet
                    .querySelectorAll("[data-grp]")
                    .forEach((x) => x.classList.remove("active"));
                b.classList.add("active");
                // Toggle visibility: group tasks are always visible to members
                const hasGroup = !!addForm.assignedGroup;
                const visSection = sheet.querySelector("#visibilitySection");
                const visLocked = sheet.querySelector("#visibilityLocked");
                if (visSection)
                    visSection.style.display = hasGroup ? "none" : "block";
                if (visLocked)
                    visLocked.style.display = hasGroup ? "block" : "none";
            }),
        );

        // Events — Next button
        sheet.querySelector("#atNext").addEventListener("click", async () => {
            addForm.title = sheet.querySelector("#atTitle").value.trim();
            addForm.desc = sheet.querySelector("#atDesc").value.trim();
            const dl = sheet.querySelector("#atDeadline").value;
            if (dl) addForm.deadline = new Date(dl).getTime();

            // Read custom time if active
            if (addForm.customTime) {
                const h =
                    parseInt(sheet.querySelector("#atCustomHours")?.value) || 0;
                const m =
                    parseInt(sheet.querySelector("#atCustomMins")?.value) || 0;
                addForm.timeMins = h * 60 + m;
                if (addForm.timeMins < 1) addForm.timeMins = 1;
            }

            if (!addForm.title) {
                sheet.querySelector("#atTitle").style.borderColor =
                    "var(--danger)";
                return;
            }
            addStep = 1;
            renderAddModal();
            // AI rate
            sheet.querySelector("#diffLoading").style.display = "flex";
            sheet.querySelector("#diffResult").style.display = "none";
            const result = await aiRateDifficulty(
                addForm.title,
                addForm.desc,
                addForm.timeMins,
                addForm.category,
            );
            addForm.difficulty = result.difficulty;
            addForm.reasoning = result.reasoning;
            addForm.tips = result.tips;
            renderDiffStep();
        });
    } else {
        // Show which group the task will go to
        let groupBadge = "";
        if (addForm.assignedGroup) {
            groupBadge = `<div style="text-align:center;margin-bottom:12px;"><span class="race-badge live" style="margin:0;">📌 Will be added to group <span class="grp-assign-name">${addForm.assignedGroup}</span></span></div>`;
        }

        sheet.innerHTML = `
      <div class="modal-header"><h2>Difficulty</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
      ${groupBadge}
      <div class="glow-card">
        <div class="loading-indicator" id="diffLoading"><div class="spinner"></div><span style="font-size:14px;color:var(--text-dim);">AI is analyzing…</span></div>
        <div id="diffResult" style="display:none;">
          <div class="diff-display">
            <div style="font-size:12px;font-weight:700;color:var(--text-dim);letter-spacing:2px;">DIFFICULTY</div>
            <div class="diff-number" id="diffNum">${addForm.difficulty}</div>
            <div class="diff-label" id="diffLbl">${diffLabel(addForm.difficulty)}</div>
          </div>
          <div class="diff-bar-track"><div class="diff-bar-fill" id="diffBar"></div></div>
          <div class="ai-reasoning" id="aiReasoning"></div>
          <div class="ai-tip" id="aiTip" style="display:none;"></div>
        </div>
      </div>
      <div class="manual-row" id="manualRow"></div>
      <div class="points-preview">
        <span style="font-size:15px;color:var(--text-dim);">Points for completion:</span>
        <span class="points-value" id="ptsPreview">+${calcPoints(addForm.difficulty, addForm.timeMins, addForm.deadline, Date.now())}</span>
      </div>
      <div class="modal-btns">
        <button class="btn-secondary" onclick="addStep=0;renderAddModal();">Back</button>
        <button class="btn-primary" id="atSave">Add Task</button>
      </div>`;

        // Load group name for the badge
        if (addForm.assignedGroup) {
            db.ref(`groups/${addForm.assignedGroup}/name`)
                .once("value")
                .then((snap) => {
                    const name = snap.val();
                    const el = sheet.querySelector(".grp-assign-name");
                    if (el && name) el.textContent = name;
                })
                .catch(() => {});
        }

        // Manual buttons
        const row = sheet.querySelector("#manualRow");
        for (let i = 1; i <= 10; i++) {
            const b = document.createElement("button");
            b.className =
                "manual-btn" + (i === addForm.difficulty ? " active" : "");
            if (i === addForm.difficulty) b.style.background = diffColor(i);
            b.textContent = i;
            b.addEventListener("click", () => {
                addForm.difficulty = i;
                renderDiffStep();
            });
            row.appendChild(b);
        }
        sheet.querySelector("#atSave").addEventListener("click", saveNewTask);
    }
}

function renderDiffStep() {
    const d = addForm.difficulty;
    const sheet = document.getElementById("modalSheet");
    sheet.querySelector("#diffLoading").style.display = "none";
    sheet.querySelector("#diffResult").style.display = "block";
    sheet.querySelector("#diffNum").textContent = d;
    sheet.querySelector("#diffNum").style.color = diffColor(d);
    sheet.querySelector("#diffLbl").textContent = diffLabel(d);
    sheet.querySelector("#diffLbl").style.color = diffColor(d);
    const bar = sheet.querySelector("#diffBar");
    bar.style.width = d * 10 + "%";
    bar.style.background = diffColor(d);
    sheet.querySelector("#aiReasoning").textContent = addForm.reasoning;
    if (addForm.tips) {
        const tip = sheet.querySelector("#aiTip");
        tip.style.display = "flex";
        tip.innerHTML = "💡 " + esc(addForm.tips);
    }
    // Update manual buttons
    sheet.querySelectorAll(".manual-btn").forEach((b, i) => {
        const lv = i + 1;
        b.classList.toggle("active", lv === d);
        b.style.background = lv === d ? diffColor(lv) : "";
    });
    sheet.querySelector("#ptsPreview").textContent =
        "+" + calcPoints(d, addForm.timeMins, addForm.deadline, Date.now());
}

function saveNewTask() {
    const now = Date.now();
    const t = {
        id: crypto.randomUUID?.() || Math.random().toString(36).substr(2, 9),
        title: addForm.title,
        description: addForm.desc,
        deadline: addForm.deadline,
        timeFrameMinutes: addForm.timeMins,
        difficulty: addForm.difficulty,
        points: calcPoints(
            addForm.difficulty,
            addForm.timeMins,
            addForm.deadline,
            now,
        ),
        completed: false,
        completedAt: 0,
        createdAt: now,
        isInstant: addForm.isInstant || false,
        startedAt: 0,
        category: addForm.category,
        competitionMode: addForm.assignedGroup ? "group" : addForm.mode,
        flagged: false,
        flagReason: "",
        assignedGroup: addForm.assignedGroup || "",
    };
    state.tasks.push(t);
    save();
    syncMyTasksToFirebase();

    // If assigned to a specific group, push this task directly to that group too
    if (t.assignedGroup) {
        const myId = getMyId();
        const taskData = {
            id: t.id,
            title: t.title,
            description: t.description,
            deadline: t.deadline,
            difficulty: t.difficulty,
            points: t.points,
            completed: t.completed,
            completedAt: t.completedAt,
            category: t.category,
            flagged: t.flagged,
            timeFrameMinutes: t.timeFrameMinutes,
        };
        // We already sync all tasks, but this ensures immediate visibility
        db.ref(`groups/${t.assignedGroup}/memberTasks/${myId}`)
            .once("value")
            .then((snap) => {
                const existing = snap.val();
                const arr = existing
                    ? Array.isArray(existing)
                        ? existing
                        : Object.values(existing)
                    : [];
                arr.push(taskData);
                db.ref(`groups/${t.assignedGroup}/memberTasks/${myId}`).set(
                    arr,
                );
            })
            .catch(() => {});
    }

    closeAddTask();
    switchTab("tasks");
}

// ============================================
// CALENDAR SCREEN
// ============================================
function renderCalendar() {
    const month = state.calMonth,
        year = state.calYear;
    const months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ];
    document.getElementById("calMonthYear").textContent =
        months[month] + " " + year;

    document.getElementById("calPrev").onclick = () => {
        state.calMonth--;
        if (state.calMonth < 0) {
            state.calMonth = 11;
            state.calYear--;
        }
        renderCalendar();
    };
    document.getElementById("calNext").onclick = () => {
        state.calMonth++;
        if (state.calMonth > 11) {
            state.calMonth = 0;
            state.calYear++;
        }
        renderCalendar();
    };

    const grid = document.getElementById("calGrid");
    const days = ["S", "M", "T", "W", "T", "F", "S"];
    let html = days
        .map((d) => `<div class="cal-day-header">${d}</div>`)
        .join("");

    const firstDay = new Date(year, month, 1).getDay();
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const today = new Date();
    const sel = state.calSelectedDate;

    for (let i = 0; i < firstDay; i++) html += '<div class="cal-day"></div>';

    for (let d = 1; d <= daysInMonth; d++) {
        const date = new Date(year, month, d);
        const ds = startOfDay(date);
        const de = ds + 86400000;
        const dayTasks = state.tasks.filter(
            (t) => t.deadline >= ds && t.deadline < de,
        );
        const isToday = isSameDay(date, today);
        const isSel = isSameDay(date, sel);
        const dots = dayTasks
            .slice(0, 3)
            .map(
                (t) =>
                    `<span class="cal-task-dot" style="background:${diffColor(t.difficulty)}"></span>`,
            )
            .join("");
        html += `<div class="cal-day${isToday ? " today" : ""}${isSel ? " selected" : ""}" data-date="${ds}" onclick="selectCalDay(${ds})">
      <span>${d}</span>${dots ? `<div class="cal-dots">${dots}</div>` : ""}
    </div>`;
    }
    grid.innerHTML = html;
    renderDayDetail();
}

function selectCalDay(ts) {
    state.calSelectedDate = new Date(ts);
    renderCalendar();
}

function renderDayDetail() {
    const sel = state.calSelectedDate;
    const ds = startOfDay(sel);
    const de = ds + 86400000;
    const dayTasks = state.tasks
        .filter((t) => t.deadline >= ds && t.deadline < de)
        .sort((a, b) => a.deadline - b.deadline);

    const detail = document.getElementById("dayDetail");
    let html = `<div class="day-detail-header"><h4>${fmtDate(sel)}</h4><span>${dayTasks.length} tasks</span></div>`;
    if (!dayTasks.length) {
        html +=
            '<div style="text-align:center;padding:24px 0;color:var(--text-dim);">📅 No tasks on this day</div>';
    } else {
        dayTasks.forEach((t) => {
            const cat =
                CATEGORIES.find((c) => c.id === t.category) || CATEGORIES[0];
            html += `<div class="day-task-row">
        <div class="day-task-time">${fmtTime(t.deadline)}</div>
        <div class="day-task-bar" style="background:${diffColor(t.difficulty)}"></div>
        <div class="day-task-info">
          <div class="day-task-title${t.completed ? " done" : ""}">${esc(t.title)}</div>
          <div class="day-task-meta">${cat.label} · +${t.points} pts</div>
        </div>
        ${t.completed ? '<span style="color:var(--success);font-size:16px;">✓</span>' : ""}
      </div>`;
        });
    }
    detail.innerHTML = html;
}

// ============================================
// COMPETE SCREEN
// ============================================
function renderCompete() {
    const tabs = document.getElementById("competeTabs");
    tabs.innerHTML = ["leaderboard", "friends", "groups", "challenges"]
        .map(
            (s) =>
                `<button class="compete-tab${state.competeSection === s ? " active" : ""}" data-sec="${s}">${s.charAt(0).toUpperCase() + s.slice(1)}</button>`,
        )
        .join("");
    tabs.querySelectorAll(".compete-tab").forEach((b) =>
        b.addEventListener("click", () => {
            state.competeSection = b.dataset.sec;
            renderCompete();
        }),
    );

    const content = document.getElementById("competeContent");
    if (state.competeSection === "leaderboard") renderLeaderboard(content);
    else if (state.competeSection === "friends") renderFriends(content);
    else if (state.competeSection === "groups") renderGroups(content);
    else renderChallenges(content);
}

// Leaderboard period toggle state
let lbPeriod = "weekly"; // "weekly" | "alltime"

async function renderLeaderboard(el) {
    el.innerHTML = `
        <div style="display:flex;gap:8px;margin-bottom:16px;">
            <button class="chip${lbPeriod === "weekly" ? " active" : ""}" id="lbWeekly">This Week</button>
            <button class="chip${lbPeriod === "alltime" ? " active" : ""}" id="lbAllTime">All Time</button>
        </div>
        <div id="lbBody"><div style="text-align:center;padding:30px 0;"><div class="spinner"></div><div style="margin-top:8px;font-size:13px;color:var(--text-dim);">Loading leaderboard...</div></div></div>`;

    el.querySelector("#lbWeekly").addEventListener("click", () => {
        lbPeriod = "weekly";
        renderLeaderboard(el);
    });
    el.querySelector("#lbAllTime").addEventListener("click", () => {
        lbPeriod = "alltime";
        renderLeaderboard(el);
    });

    try {
        const snap = await db.ref("leaderboard").once("value");
        const raw = snap.val() || {};
        const myId = getMyId();

        // Ensure our own entry is always included
        const weekAgo = Date.now() - 604800000;
        const myWeekly = state.tasks
            .filter((t) => t.completed && !t.flagged && t.completedAt > weekAgo)
            .reduce((s, t) => s + t.points, 0);
        raw[myId] = {
            id: myId,
            name: state.profile.name,
            emoji: state.profile.emoji,
            weeklyPts: myWeekly,
            allTimePts: state.profile.totalPoints || 0,
            updatedAt: Date.now(),
        };

        const ptsKey = lbPeriod === "weekly" ? "weeklyPts" : "allTimePts";
        const entries = Object.values(raw)
            .sort((a, b) => (b[ptsKey] || 0) - (a[ptsKey] || 0))
            .map((e, i) => ({ ...e, rank: i + 1, me: e.id === myId }));

        const top3 = entries.slice(0, 3);
        const rest = entries.slice(3);
        const medals = ["🥇", "🥈", "🥉"];
        const heights = ["podium-2", "podium-1", "podium-3"];

        let html = `<div class="podium">
        ${[1, 0, 2]
            .map((i) => {
                const e = top3[i];
                if (!e) return "";
                return `<div class="podium-card ${heights[i]}${e.me ? " me" : ""}">
                <div class="podium-medal">${medals[i]}</div>
                <div class="podium-emoji">${e.emoji}</div>
                <div class="podium-name${e.me ? " me-name" : ""}">${esc(e.name)}</div>
                <div class="podium-pts">${e[ptsKey] || 0}</div>
            </div>`;
            })
            .join("")}</div>`;

        rest.forEach((e) => {
            html += `<div class="lb-row${e.me ? " me" : ""}">
                <span class="lb-rank">#${e.rank}</span>
                <span class="lb-emoji">${e.emoji}</span>
                <span class="lb-name${e.me ? " me-name" : ""}">${esc(e.name)}${e.me ? " (you)" : ""}</span>
                <span class="lb-pts">${e[ptsKey] || 0} pts</span>
            </div>`;
        });

        if (!entries.length)
            html = `<div class="empty-state" style="padding:30px 0;"><div class="emoji">🏆</div><h3>No scores yet</h3><p>Complete tasks to appear here</p></div>`;

        el.querySelector("#lbBody").innerHTML = html;
    } catch (err) {
        el.querySelector("#lbBody").innerHTML =
            `<div style="text-align:center;color:var(--danger);padding:20px;">Failed to load leaderboard</div>`;
    }
}

// ============================================
// FIREBASE GROUP SYSTEM
// ============================================
const db = firebase.database();

function genGroupCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let code = "";
    for (let i = 0; i < 6; i++)
        code += chars[Math.floor(Math.random() * chars.length)];
    return code;
}

function getMyId() {
    if (!state.profile.id) {
        state.profile.id =
            crypto.randomUUID?.() || Math.random().toString(36).substr(2, 12);
        save();
    }
    return state.profile.id;
}

// Push my tasks to every Firebase group I'm in
function syncMyTasksToFirebase() {
    const myId = getMyId();
    const myTasks = state.tasks.map((t) => ({
        id: t.id,
        title: t.title,
        description: t.description || "",
        deadline: t.deadline,
        difficulty: t.difficulty,
        points: t.points,
        completed: t.completed,
        completedAt: t.completedAt || 0,
        category: t.category,
        flagged: t.flagged || false,
        timeFrameMinutes: t.timeFrameMinutes,
    }));
    const myInfo = {
        id: myId,
        name: state.profile.name,
        emoji: state.profile.emoji,
    };

    // Update every group I belong to
    (state.myGroupCodes || []).forEach((code) => {
        db.ref(`groups/${code}/members/${myId}`).set(myInfo);
        db.ref(`groups/${code}/memberTasks/${myId}`).set(myTasks);
    });

    // Sync to global leaderboard
    syncLeaderboard();
}

function syncLeaderboard() {
    const myId = getMyId();
    const weekAgo = Date.now() - 604800000;
    const weeklyPts = state.tasks
        .filter((t) => t.completed && !t.flagged && t.completedAt > weekAgo)
        .reduce((s, t) => s + t.points, 0);
    const allTimePts = state.profile.totalPoints || 0;
    db.ref(`leaderboard/${myId}`).set({
        id: myId,
        name: state.profile.name,
        emoji: state.profile.emoji,
        weeklyPts,
        allTimePts,
        updatedAt: Date.now(),
    });
}

function getMemberPoints(memberTasks) {
    if (!memberTasks || !Array.isArray(memberTasks)) return 0;
    return memberTasks
        .filter((t) => t.completed && !t.flagged)
        .reduce((s, t) => s + (t.points || 0), 0);
}

// Active Firebase listeners (so we can detach)
let groupListeners = {};

function listenToGroup(code) {
    if (groupListeners[code]) return; // already listening
    groupListeners[code] = db.ref(`groups/${code}`);
    groupListeners[code].on("value", () => {
        // Re-render if we're on the compete tab
        if (
            state.currentTab === "compete" &&
            state.competeSection === "groups"
        ) {
            renderCompete();
        }
    });
}

function stopListeningToGroup(code) {
    if (groupListeners[code]) {
        groupListeners[code].off();
        delete groupListeners[code];
    }
}

// ============================================
// FRIENDS SYSTEM
// ============================================
async function renderFriends(el) {
    const myId = getMyId();
    el.innerHTML = `<div style="text-align:center;padding:30px 0;"><div class="spinner"></div></div>`;

    try {
        // Load incoming requests, outgoing requests, and friends list
        const [friendsSnap, inSnap, outSnap] = await Promise.all([
            db.ref(`friends/${myId}/list`).once("value"),
            db.ref(`friends/${myId}/incoming`).once("value"),
            db.ref(`friends/${myId}/outgoing`).once("value"),
        ]);

        const friendsList = friendsSnap.val() || {};
        const incoming = inSnap.val() || {};
        const outgoing = outSnap.val() || {};

        let html = "";

        // My friend code / add friend section
        html += `<div class="friend-code-card">
            <div style="font-size:12px;color:var(--text-muted);font-weight:700;letter-spacing:1px;margin-bottom:6px;">YOUR FRIEND CODE</div>
            <div class="friend-code-display" onclick="navigator.clipboard.writeText('${myId}');this.textContent='Copied!';setTimeout(()=>this.textContent='${myId.slice(0, 8)}...',1200);">${myId.slice(0, 8)}...</div>
            <div style="font-size:11px;color:var(--text-muted);margin-top:4px;">Tap to copy full code</div>
        </div>
        <button class="btn-primary" style="margin-bottom:16px;" onclick="openAddFriendModal()">+ Add Friend</button>`;

        // Incoming requests
        const inArr = Object.values(incoming);
        if (inArr.length) {
            html += `<div class="friends-section-label">📬 Friend Requests (${inArr.length})</div>`;
            inArr.forEach((req) => {
                html += `<div class="friend-request-row">
                    <span style="font-size:22px;">${req.emoji || "⚡"}</span>
                    <div style="flex:1;">
                        <div style="font-size:14px;font-weight:700;">${esc(req.name)}</div>
                        <div style="font-size:11px;color:var(--text-muted);">wants to be your friend</div>
                    </div>
                    <button class="btn-accept" onclick="acceptFriend('${req.id}','${esc(req.name)}','${req.emoji || "⚡"}')">✓</button>
                    <button class="btn-decline" onclick="declineFriend('${req.id}')">✗</button>
                </div>`;
            });
        }

        // Outgoing requests
        const outArr = Object.values(outgoing);
        if (outArr.length) {
            html += `<div class="friends-section-label">⏳ Pending</div>`;
            outArr.forEach((req) => {
                html += `<div class="friend-request-row">
                    <span style="font-size:22px;">${req.emoji || "⚡"}</span>
                    <div style="flex:1;">
                        <div style="font-size:14px;font-weight:700;">${esc(req.name)}</div>
                        <div style="font-size:11px;color:var(--text-muted);">Request sent</div>
                    </div>
                    <button class="btn-decline" onclick="cancelFriendRequest('${req.id}')">Cancel</button>
                </div>`;
            });
        }

        // Friends list
        const friendsArr = Object.values(friendsList);
        if (friendsArr.length) {
            html += `<div class="friends-section-label">👥 Friends (${friendsArr.length})</div>`;
            // Fetch their leaderboard stats
            for (const f of friendsArr) {
                let fPts = { weeklyPts: "—", allTimePts: "—" };
                try {
                    const fSnap = await db
                        .ref(`leaderboard/${f.id}`)
                        .once("value");
                    if (fSnap.val()) fPts = fSnap.val();
                } catch (e) {}
                html += `<div class="friend-row">
                    <span style="font-size:26px;">${f.emoji || "⚡"}</span>
                    <div style="flex:1;">
                        <div style="font-size:14px;font-weight:700;">${esc(f.name)}</div>
                        <div style="font-size:11px;color:var(--text-dim);">Week: <span style="color:var(--neon);font-family:var(--mono);">${fPts.weeklyPts}</span> pts &nbsp;·&nbsp; Total: <span style="color:var(--accent-light);font-family:var(--mono);">${fPts.allTimePts}</span> pts</div>
                    </div>
                    <button class="btn-remove-friend" onclick="removeFriend('${f.id}')">✗</button>
                </div>`;
            }
        } else if (!inArr.length) {
            html += `<div class="empty-state" style="padding:24px 0;">
                <div class="emoji">🤝</div>
                <h3>No friends yet</h3>
                <p>Share your code or add someone else's</p>
            </div>`;
        }

        el.innerHTML = html;
    } catch (err) {
        el.innerHTML = `<div style="color:var(--danger);text-align:center;padding:20px;">Failed to load friends</div>`;
    }
}

function openAddFriendModal() {
    const modal = document.getElementById("addTaskModal");
    const sheet = document.getElementById("modalSheet");
    sheet.innerHTML = `
        <div class="modal-header"><h2>Add Friend</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
        <div class="form-group">
            <label class="form-label">Enter their Friend Code</label>
            <input class="input-field" id="afCode" placeholder="Paste their full code" style="font-family:var(--mono);font-size:12px;" autocomplete="off">
        </div>
        <div id="afError" style="color:var(--danger);font-size:13px;text-align:center;display:none;margin-bottom:12px;"></div>
        <div id="afPreview" style="display:none;margin-bottom:16px;"></div>
        <button class="btn-primary" id="afSubmit">Send Request</button>`;

    const input = sheet.querySelector("#afCode");
    const errorEl = sheet.querySelector("#afError");
    const previewEl = sheet.querySelector("#afPreview");
    let foundUser = null;

    input.addEventListener("input", async () => {
        const code = input.value.trim();
        errorEl.style.display = "none";
        previewEl.style.display = "none";
        foundUser = null;
        if (code.length < 10) return;

        const myId = getMyId();
        if (code === myId) {
            errorEl.textContent = "That's your own code!";
            errorEl.style.display = "block";
            return;
        }
        try {
            const snap = await db.ref(`leaderboard/${code}`).once("value");
            const user = snap.val();
            if (!user) {
                errorEl.textContent = "No user found with this code";
                errorEl.style.display = "block";
                return;
            }
            foundUser = user;
            previewEl.style.display = "block";
            previewEl.innerHTML = `<div class="glow-card" style="text-align:center;">
                <div style="font-size:32px;">${user.emoji || "⚡"}</div>
                <div style="font-size:16px;font-weight:800;margin-top:4px;">${esc(user.name)}</div>
                <div style="font-size:12px;color:var(--text-dim);margin-top:2px;">${user.weeklyPts || 0} pts this week</div>
            </div>`;
        } catch (e) {
            errorEl.textContent = "Error looking up user";
            errorEl.style.display = "block";
        }
    });

    sheet.querySelector("#afSubmit").addEventListener("click", async () => {
        if (!foundUser) {
            errorEl.textContent = "Enter a valid friend code first";
            errorEl.style.display = "block";
            return;
        }
        const myId = getMyId();
        try {
            // Send request to their incoming, log in our outgoing
            await db.ref(`friends/${foundUser.id}/incoming/${myId}`).set({
                id: myId,
                name: state.profile.name,
                emoji: state.profile.emoji,
                sentAt: Date.now(),
            });
            await db.ref(`friends/${myId}/outgoing/${foundUser.id}`).set({
                id: foundUser.id,
                name: foundUser.name,
                emoji: foundUser.emoji || "⚡",
                sentAt: Date.now(),
            });
            closeAddTask();
            renderCompete();
        } catch (err) {
            errorEl.textContent = "Failed to send request: " + err.message;
            errorEl.style.display = "block";
        }
    });

    modal.classList.add("open");
}

async function acceptFriend(theirId, theirName, theirEmoji) {
    const myId = getMyId();
    try {
        // Add to both friend lists
        await db
            .ref(`friends/${myId}/list/${theirId}`)
            .set({ id: theirId, name: theirName, emoji: theirEmoji });
        await db.ref(`friends/${theirId}/list/${myId}`).set({
            id: myId,
            name: state.profile.name,
            emoji: state.profile.emoji,
        });
        // Clean up request nodes
        await db.ref(`friends/${myId}/incoming/${theirId}`).remove();
        await db.ref(`friends/${theirId}/outgoing/${myId}`).remove();
        renderCompete();
    } catch (err) {
        alert("Failed to accept: " + err.message);
    }
}

async function declineFriend(theirId) {
    const myId = getMyId();
    try {
        await db.ref(`friends/${myId}/incoming/${theirId}`).remove();
        await db.ref(`friends/${theirId}/outgoing/${myId}`).remove();
        renderCompete();
    } catch (err) {
        alert("Failed to decline: " + err.message);
    }
}

async function cancelFriendRequest(theirId) {
    const myId = getMyId();
    try {
        await db.ref(`friends/${myId}/outgoing/${theirId}`).remove();
        await db.ref(`friends/${theirId}/incoming/${myId}`).remove();
        renderCompete();
    } catch (err) {
        alert("Failed to cancel: " + err.message);
    }
}

async function removeFriend(theirId) {
    if (!confirm("Remove this friend?")) return;
    const myId = getMyId();
    try {
        await db.ref(`friends/${myId}/list/${theirId}`).remove();
        await db.ref(`friends/${theirId}/list/${myId}`).remove();
        renderCompete();
    } catch (err) {
        alert("Failed to remove: " + err.message);
    }
}

// ============================================
// RENDER GROUPS — reads from Firebase
// ============================================
async function renderGroups(el) {
    const myId = getMyId();
    const codes = state.myGroupCodes || [];

    if (!codes.length) {
        el.innerHTML = `<div class="empty-state" style="padding:40px 0;">
            <div class="emoji">👥</div><h3>No groups yet</h3>
            <p>Create or join a group to compete with friends</p>
        </div>
        <div class="group-actions">
            <button class="btn-primary" onclick="openCreateGroupModal()">+ Create Group</button>
            <button class="btn-secondary" style="flex:1;text-align:center;" onclick="openJoinGroupModal()">🔗 Join Group</button>
        </div>`;
        return;
    }

    el.innerHTML = `<div style="text-align:center;padding:30px 0;"><div class="spinner"></div><div style="margin-top:8px;font-size:13px;color:var(--text-dim);">Loading groups...</div></div>`;

    let html = "";

    for (let ci = 0; ci < codes.length; ci++) {
        const code = codes[ci];
        try {
            const snap = await db.ref(`groups/${code}`).once("value");
            const g = snap.val();
            if (!g) {
                // Group was deleted from Firebase
                state.myGroupCodes = state.myGroupCodes.filter(
                    (c) => c !== code,
                );
                save();
                stopListeningToGroup(code);
                continue;
            }

            listenToGroup(code);

            const members = g.members ? Object.values(g.members) : [];
            const isCreator = g.creatorId === myId;

            // Build ranked members
            const ranked = members
                .map((m) => {
                    const tasks = g.memberTasks?.[m.id];
                    const taskArr = tasks
                        ? Array.isArray(tasks)
                            ? tasks
                            : Object.values(tasks)
                        : [];
                    return { ...m, pts: getMemberPoints(taskArr) };
                })
                .sort((a, b) => b.pts - a.pts);

            // Check race winner
            let raceHtml = "";
            if (g.race && g.race.targetPoints) {
                let winner = g.race.winnerId ? g.race : null;
                if (!winner) {
                    for (const m of ranked) {
                        if (m.pts >= g.race.targetPoints) {
                            // Write winner to Firebase
                            db.ref(`groups/${code}/race`).update({
                                winnerId: m.id,
                                winnerName: m.name,
                                wonAt: Date.now(),
                            });
                            winner = { winnerId: m.id, winnerName: m.name };
                            break;
                        }
                    }
                }
                if (winner && winner.winnerId) {
                    raceHtml = `<div class="race-badge won">🏁 ${esc(winner.winnerName)} won! Reached ${g.race.targetPoints} pts</div>`;
                } else {
                    raceHtml = `<div class="race-badge live">🏁 Race to ${g.race.targetPoints} pts — in progress</div>`;
                }
            }

            let timeLimitHtml = "";
            if (g.timeLimitDays > 0 && g.createdAt) {
                const elapsed = Math.floor(
                    (Date.now() - g.createdAt) / 86400000,
                );
                const remaining = Math.max(0, g.timeLimitDays - elapsed);
                timeLimitHtml = `<div class="group-time">⏱ ${remaining}d remaining of ${g.timeLimitDays}d competition</div>`;
            }

            html += `<div class="group-card">
                <div class="group-header">
                    <div>
                        <div class="group-name">${esc(g.name)}</div>
                        <div class="group-members">${members.length} member${members.length !== 1 ? "s" : ""}</div>
                    </div>
                    <div style="text-align:right;">
                        <div class="group-code-label">CODE</div>
                        <div class="group-code" style="cursor:pointer;" onclick="event.stopPropagation();navigator.clipboard.writeText('${code}');this.textContent='Copied!';setTimeout(()=>this.textContent='${code}',1200);">${code}</div>
                    </div>
                </div>
                ${raceHtml}${timeLimitHtml}
                <div class="group-lb">`;

            ranked.forEach((m, ri) => {
                const isMe = m.id === myId;
                const medals = ["🥇", "🥈", "🥉"];
                const medal = ri < 3 ? medals[ri] : `#${ri + 1}`;
                html += `<div class="group-lb-row${isMe ? " me" : ""}" onclick="event.stopPropagation();openGroupDetail('${code}')">
                    <span class="group-lb-rank">${medal}</span>
                    <span class="group-lb-emoji">${m.emoji}</span>
                    <span class="group-lb-name${isMe ? " me-name" : ""}">${esc(m.name)}${isMe ? " (you)" : ""}</span>
                    <span class="group-lb-pts">${m.pts} pts</span>
                </div>`;
            });

            html += `</div><div class="group-card-actions">
                <button class="btn-secondary" onclick="event.stopPropagation();openGroupDetail('${code}')" style="flex:1;text-align:center;">View Tasks</button>`;
            if (isCreator) {
                html += `<button class="btn-delete" onclick="event.stopPropagation();deleteGroup('${code}')">🗑</button>`;
            } else {
                html += `<button class="btn-delete" onclick="event.stopPropagation();leaveGroup('${code}')" style="font-size:12px;">Leave</button>`;
            }
            html += `</div></div>`;
        } catch (err) {
            console.error("Error loading group", code, err);
            html += `<div class="card" style="margin-bottom:12px;color:var(--text-dim);font-size:13px;">Failed to load group ${code}</div>`;
        }
    }

    html += `<div class="group-actions">
        <button class="btn-primary" onclick="openCreateGroupModal()">+ Create Group</button>
        <button class="btn-secondary" style="flex:1;text-align:center;" onclick="openJoinGroupModal()">🔗 Join Group</button>
    </div>`;

    el.innerHTML = html;
}

// ============================================
// CREATE GROUP
// ============================================
function openCreateGroupModal() {
    const modal = document.getElementById("addTaskModal");
    const sheet = document.getElementById("modalSheet");
    sheet.innerHTML = `
        <div class="modal-header"><h2>Create Group</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
        <div class="form-group">
            <label class="form-label">Group Name</label>
            <input class="input-field" id="cgName" placeholder="e.g., Study Squad" maxlength="30">
        </div>
        <div class="form-group">
            <label class="form-label">Time Limit (optional)</label>
            <div class="chip-row">
                <button class="chip active" data-days="0">No limit</button>
                <button class="chip" data-days="7">7 days</button>
                <button class="chip" data-days="14">14 days</button>
                <button class="chip" data-days="30">30 days</button>
            </div>
        </div>
        <div class="form-group">
            <label class="form-label">🏁 Race Game (optional)</label>
            <p style="font-size:12px;color:var(--text-dim);margin-bottom:8px;">First person to reach the target points wins!</p>
            <div class="chip-row" id="cgRaceChips">
                <button class="chip active" data-race="0">No race</button>
                <button class="chip" data-race="500">500 pts</button>
                <button class="chip" data-race="1000">1000 pts</button>
                <button class="chip" data-race="2000">2000 pts</button>
                <button class="chip" data-race="custom">Custom</button>
            </div>
            <div id="cgCustomRaceRow" style="margin-top:8px;display:none;">
                <input class="input-field" id="cgCustomRace" type="number" placeholder="Custom point target" min="100" step="50">
            </div>
        </div>
        <button class="btn-primary" id="cgSubmit">Create Group</button>`;

    let selectedDays = 0,
        selectedRace = 0,
        customRace = false;

    sheet.querySelectorAll("[data-days]").forEach((b) =>
        b.addEventListener("click", () => {
            selectedDays = +b.dataset.days;
            sheet
                .querySelectorAll("[data-days]")
                .forEach((x) => x.classList.remove("active"));
            b.classList.add("active");
        }),
    );

    sheet.querySelectorAll("[data-race]").forEach((b) =>
        b.addEventListener("click", () => {
            if (b.dataset.race === "custom") {
                customRace = true;
                document.getElementById("cgCustomRaceRow").style.display =
                    "block";
            } else {
                customRace = false;
                selectedRace = +b.dataset.race;
                document.getElementById("cgCustomRaceRow").style.display =
                    "none";
            }
            sheet
                .querySelectorAll("[data-race]")
                .forEach((x) => x.classList.remove("active"));
            b.classList.add("active");
        }),
    );

    sheet.querySelector("#cgSubmit").addEventListener("click", async () => {
        const name = sheet.querySelector("#cgName").value.trim();
        if (!name) {
            sheet.querySelector("#cgName").style.borderColor = "var(--danger)";
            return;
        }

        let raceTarget = selectedRace;
        if (customRace) {
            raceTarget =
                parseInt(document.getElementById("cgCustomRace").value) || 0;
            if (raceTarget < 100) {
                document.getElementById("cgCustomRace").style.borderColor =
                    "var(--danger)";
                return;
            }
        }

        const myId = getMyId();
        const code = genGroupCode();
        const groupData = {
            name,
            code,
            creatorId: myId,
            createdAt: Date.now(),
            timeLimitDays: selectedDays > 0 ? selectedDays : -1,
            race:
                raceTarget > 0
                    ? {
                          targetPoints: raceTarget,
                          winnerId: null,
                          winnerName: null,
                          wonAt: null,
                      }
                    : null,
            members: {
                [myId]: {
                    id: myId,
                    name: state.profile.name,
                    emoji: state.profile.emoji,
                },
            },
            memberTasks: {
                [myId]: state.tasks.map((t) => ({
                    id: t.id,
                    title: t.title,
                    description: t.description || "",
                    deadline: t.deadline,
                    difficulty: t.difficulty,
                    points: t.points,
                    completed: t.completed,
                    completedAt: t.completedAt || 0,
                    category: t.category,
                    flagged: t.flagged || false,
                    timeFrameMinutes: t.timeFrameMinutes,
                })),
            },
        };

        try {
            await db.ref(`groups/${code}`).set(groupData);
            if (!state.myGroupCodes) state.myGroupCodes = [];
            state.myGroupCodes.push(code);
            save();
            closeAddTask();
            renderCompete();
        } catch (err) {
            alert("Failed to create group: " + err.message);
        }
    });

    modal.classList.add("open");
}

// ============================================
// JOIN GROUP
// ============================================
function openJoinGroupModal() {
    const modal = document.getElementById("addTaskModal");
    const sheet = document.getElementById("modalSheet");
    sheet.innerHTML = `
        <div class="modal-header"><h2>Join Group</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
        <div class="form-group">
            <label class="form-label">Enter Group Code</label>
            <input class="input-field" id="jgCode" placeholder="e.g., AB3X7K" maxlength="6" style="font-family:var(--mono);font-size:20px;text-align:center;letter-spacing:4px;text-transform:uppercase;">
        </div>
        <div id="jgError" style="color:var(--danger);font-size:13px;text-align:center;display:none;margin-bottom:12px;"></div>
        <div id="jgPreview" style="display:none;margin-bottom:16px;"></div>
        <button class="btn-primary" id="jgSubmit">Join Group</button>`;

    const codeInput = sheet.querySelector("#jgCode");
    const errorEl = sheet.querySelector("#jgError");
    const previewEl = sheet.querySelector("#jgPreview");
    let foundGroup = null;

    codeInput.addEventListener("input", async () => {
        const code = codeInput.value.trim().toUpperCase();
        errorEl.style.display = "none";
        previewEl.style.display = "none";
        foundGroup = null;

        if (code.length === 6) {
            try {
                const snap = await db.ref(`groups/${code}`).once("value");
                const g = snap.val();
                if (!g) {
                    errorEl.textContent = "No group found with this code";
                    errorEl.style.display = "block";
                    return;
                }
                const myId = getMyId();
                const members = g.members ? Object.values(g.members) : [];
                if (members.some((m) => m.id === myId)) {
                    errorEl.textContent = "You're already in this group!";
                    errorEl.style.display = "block";
                    return;
                }
                foundGroup = { code, data: g };
                previewEl.style.display = "block";
                previewEl.innerHTML = `
                    <div class="glow-card" style="text-align:center;">
                        <div style="font-size:15px;font-weight:800;margin-bottom:4px;">${esc(g.name)}</div>
                        <div style="font-size:13px;color:var(--text-dim);">${members.length} member${members.length !== 1 ? "s" : ""}</div>
                        <div style="display:flex;justify-content:center;gap:4px;margin-top:8px;">
                            ${members.map((m) => `<span style="font-size:20px;">${m.emoji}</span>`).join("")}
                        </div>
                        ${g.race && g.race.targetPoints ? `<div class="race-badge live" style="margin-top:8px;">🏁 Race to ${g.race.targetPoints} pts</div>` : ""}
                    </div>`;
            } catch (err) {
                errorEl.textContent = "Error looking up group";
                errorEl.style.display = "block";
            }
        }
    });

    sheet.querySelector("#jgSubmit").addEventListener("click", async () => {
        if (!foundGroup) {
            errorEl.textContent = "Enter a valid 6-character code";
            errorEl.style.display = "block";
            return;
        }
        const myId = getMyId();
        const code = foundGroup.code;
        try {
            await db.ref(`groups/${code}/members/${myId}`).set({
                id: myId,
                name: state.profile.name,
                emoji: state.profile.emoji,
            });
            await db.ref(`groups/${code}/memberTasks/${myId}`).set(
                state.tasks.map((t) => ({
                    id: t.id,
                    title: t.title,
                    description: t.description || "",
                    deadline: t.deadline,
                    difficulty: t.difficulty,
                    points: t.points,
                    completed: t.completed,
                    completedAt: t.completedAt || 0,
                    category: t.category,
                    flagged: t.flagged || false,
                    timeFrameMinutes: t.timeFrameMinutes,
                })),
            );
            if (!state.myGroupCodes) state.myGroupCodes = [];
            if (!state.myGroupCodes.includes(code))
                state.myGroupCodes.push(code);
            save();
            closeAddTask();
            renderCompete();
        } catch (err) {
            alert("Failed to join group: " + err.message);
        }
    });

    modal.classList.add("open");
}

// ============================================
// GROUP DETAIL VIEW
// ============================================
async function openGroupDetail(code) {
    const modal = document.getElementById("addTaskModal");
    const sheet = document.getElementById("modalSheet");
    sheet.innerHTML = `<div style="text-align:center;padding:40px 0;"><div class="spinner"></div></div>`;
    modal.classList.add("open");

    try {
        const snap = await db.ref(`groups/${code}`).once("value");
        const g = snap.val();
        if (!g) {
            sheet.innerHTML = `<div class="modal-header"><h2>Group not found</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>`;
            return;
        }

        const myId = getMyId();
        const members = g.members ? Object.values(g.members) : [];
        const ranked = members
            .map((m) => {
                const tasks = g.memberTasks?.[m.id];
                const taskArr = tasks
                    ? Array.isArray(tasks)
                        ? tasks
                        : Object.values(tasks)
                    : [];
                return { ...m, pts: getMemberPoints(taskArr), tasks: taskArr };
            })
            .sort((a, b) => b.pts - a.pts);

        let html = `<div class="modal-header"><h2>${esc(g.name)}</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>`;

        // Race progress
        if (g.race && g.race.targetPoints) {
            const target = g.race.targetPoints;
            const hasWinner = g.race.winnerId;
            html += `<div class="glow-card" style="margin-bottom:16px;">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                    <span style="font-size:14px;font-weight:700;">🏁 Race to ${target} pts</span>
                    ${hasWinner ? `<span class="race-badge won" style="margin:0;">🏆 ${esc(g.race.winnerName)} won!</span>` : '<span class="race-badge live" style="margin:0;">Live</span>'}
                </div>`;
            ranked.forEach((m) => {
                const progress = Math.min(100, (m.pts / target) * 100);
                const isWinner = g.race.winnerId === m.id;
                html += `<div style="margin-bottom:8px;">
                    <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:3px;">
                        <span>${m.emoji} ${esc(m.name)}${m.id === myId ? " (you)" : ""}${isWinner ? " 🏆" : ""}</span>
                        <span style="font-family:var(--mono);color:var(--neon);">${m.pts}/${target}</span>
                    </div>
                    <div class="challenge-bar-track" style="margin:0;"><div class="challenge-bar-fill" style="width:${progress}%;${isWinner ? "background:var(--neon);" : ""}"></div></div>
                </div>`;
            });
            html += `</div>`;
        }

        // Info cards
        html += `<div style="display:flex;gap:8px;margin-bottom:16px;">
            <div class="card" style="flex:1;text-align:center;">
                <div style="font-size:11px;color:var(--text-muted);font-weight:700;letter-spacing:1px;">INVITE CODE</div>
                <div style="font-family:var(--mono);font-size:18px;font-weight:700;color:var(--accent);margin-top:4px;cursor:pointer;" onclick="navigator.clipboard.writeText('${code}');this.textContent='Copied!';setTimeout(()=>this.textContent='${code}',1200);">${code}</div>
            </div>
            <div class="card" style="flex:1;text-align:center;">
                <div style="font-size:11px;color:var(--text-muted);font-weight:700;letter-spacing:1px;">MEMBERS</div>
                <div style="font-size:18px;font-weight:700;margin-top:4px;">${members.length}</div>
            </div>
        </div>`;

        // Member task sections
        ranked.forEach((m) => {
            const isMe = m.id === myId;
            const tasks = m.tasks.sort((a, b) => a.deadline - b.deadline);
            const activeTasks = tasks.filter((t) => !t.completed);
            const doneTasks = tasks.filter((t) => t.completed && !t.flagged);

            html += `<div class="group-member-section">
                <div class="group-member-header" onclick="this.parentElement.classList.toggle('collapsed')">
                    <div style="display:flex;align-items:center;gap:8px;">
                        <span style="font-size:22px;">${m.emoji}</span>
                        <div>
                            <div style="font-size:14px;font-weight:700;">${esc(m.name)}${isMe ? " (you)" : ""}</div>
                            <div style="font-size:12px;color:var(--text-dim);">${m.pts} pts · ${doneTasks.length} done · ${activeTasks.length} active</div>
                        </div>
                    </div>
                    <span class="group-member-chevron">›</span>
                </div>
                <div class="group-member-tasks">`;

            if (!tasks.length) {
                html += `<div style="padding:12px 0;text-align:center;font-size:13px;color:var(--text-muted);">No tasks yet</div>`;
            } else {
                tasks.forEach((t) => {
                    const cat =
                        CATEGORIES.find((c) => c.id === t.category) ||
                        CATEGORIES[0];
                    const existingDispute = g.disputes?.[m.id]?.[t.id];
                    const myVote = existingDispute?.votes?.[myId];
                    const votes = existingDispute?.votes
                        ? Object.values(existingDispute.votes)
                        : [];
                    const upVotes = votes.filter((v) => v === "up").length;
                    const downVotes = votes.filter((v) => v === "down").length;
                    const hardVotes = votes.filter((v) => v === "hard").length;
                    const canContest = !isMe && !t.completed;
                    const isContested = !!existingDispute;

                    html += `<div class="group-task-row">
                        <div class="task-diff-bar" style="background:${diffColor(t.difficulty)};width:4px;height:32px;border-radius:2px;flex-shrink:0;"></div>
                        <div style="flex:1;min-width:0;">
                            <div style="font-size:13px;font-weight:600;${t.completed ? "color:var(--text-muted);text-decoration:line-through;" : ""}">${esc(t.title)}</div>
                            <div style="font-size:11px;color:var(--text-dim);">${cat.icon} ${cat.label} · ${diffLabel(t.difficulty)} · ${timeUntil(t.deadline)}</div>
                            ${isContested ? `<div class="dispute-pill">⚖️ Contested · ${upVotes}↑easy ${hardVotes}↑hard ${downVotes}↓fair${myVote ? ` · you: ${myVote === "up" ? "too easy" : myVote === "hard" ? "too hard" : "fair"}` : ""}</div>` : ""}
                        </div>
                        <div style="text-align:right;flex-shrink:0;display:flex;flex-direction:column;align-items:flex-end;gap:4px;">
                            ${t.completed ? '<span style="color:var(--success);">✓</span>' : `<span style="font-family:var(--mono);font-size:12px;color:var(--neon);">+${t.points}</span>`}
                            ${canContest && !myVote ? `<button class="btn-contest" onclick="event.stopPropagation();openDisputeModal('${code}','${m.id}','${t.id}',${t.difficulty},${t.points},'${esc(t.title).replace(/'/g, "\\'")}')">⚖️</button>` : ""}
                            ${canContest && myVote ? `<span style="font-size:10px;color:var(--text-muted);">voted</span>` : ""}
                        </div>
                    </div>`;
                });
            }
            html += `</div></div>`;
        });

        sheet.innerHTML = html;
    } catch (err) {
        sheet.innerHTML = `<div class="modal-header"><h2>Error</h2><button class="modal-close" onclick="closeAddTask()">×</button></div><p style="color:var(--danger);">${err.message}</p>`;
    }
}

// ============================================
// DIFFICULTY DISPUTES
// ============================================
async function openDisputeModal(
    groupCode,
    ownerId,
    taskId,
    currentDiff,
    currentPts,
    taskTitle,
) {
    const modal = document.getElementById("addTaskModal");
    const sheet = document.getElementById("modalSheet");
    const myId = getMyId();

    let existingDispute = null;
    try {
        const snap = await db
            .ref(`groups/${groupCode}/disputes/${ownerId}/${taskId}`)
            .once("value");
        existingDispute = snap.val();
    } catch (e) {}

    const myVote = existingDispute?.votes?.[myId];
    const votes = existingDispute?.votes
        ? Object.values(existingDispute.votes)
        : [];
    const upVotes = votes.filter((v) => v === "up").length;
    const downVotes = votes.filter((v) => v === "down").length;
    const hardVotes = votes.filter((v) => v === "hard").length;

    const voteLabel = (v) =>
        v === "up" ? "Too Easy" : v === "hard" ? "Too Hard" : "Fair";

    sheet.innerHTML = `
        <div class="modal-header"><h2>⚖️ Dispute Difficulty</h2><button class="modal-close" onclick="closeAddTask()">×</button></div>
        <div class="dispute-task-preview">
            <div style="font-size:12px;color:var(--text-muted);margin-bottom:4px;">TASK IN QUESTION</div>
            <div style="font-size:15px;font-weight:700;">${taskTitle}</div>
            <div style="display:flex;align-items:center;gap:10px;margin-top:10px;">
                <div style="font-size:32px;font-weight:900;color:${diffColor(currentDiff)};">${currentDiff}</div>
                <div>
                    <div style="font-size:14px;font-weight:700;color:${diffColor(currentDiff)};">${diffLabel(currentDiff)}</div>
                    <div style="font-size:11px;color:var(--text-muted);">AI-rated difficulty · +${currentPts} pts</div>
                </div>
            </div>
        </div>

        ${
            existingDispute
                ? `
        <div class="dispute-votes-card">
            <div style="font-size:11px;font-weight:700;color:var(--text-muted);letter-spacing:1px;margin-bottom:10px;">CURRENT VOTES</div>
            <div style="display:flex;gap:8px;">
                <div class="dispute-vote-count easy">
                    <div style="font-size:20px;font-weight:900;">${upVotes}</div>
                    <div style="font-size:10px;">Too Easy</div>
                </div>
                <div class="dispute-vote-count fair">
                    <div style="font-size:20px;font-weight:900;">${downVotes}</div>
                    <div style="font-size:10px;">Fair</div>
                </div>
                <div class="dispute-vote-count hard">
                    <div style="font-size:20px;font-weight:900;">${hardVotes}</div>
                    <div style="font-size:10px;">Too Hard</div>
                </div>
            </div>
            ${existingDispute.resolved ? `<div style="margin-top:10px;font-size:13px;color:var(--neon);font-weight:700;">✓ Resolved — difficulty ${existingDispute.resolvedDiff !== currentDiff ? `changed to ${existingDispute.resolvedDiff}` : "kept as " + currentDiff}</div>` : ""}
        </div>`
                : ""
        }

        ${
            myVote
                ? `
        <div style="text-align:center;padding:16px;color:var(--text-muted);font-size:13px;">
            You already voted: <strong style="color:var(--text);">${voteLabel(myVote)}</strong>
        </div>`
                : `
        <div style="font-size:13px;color:var(--text-dim);margin-bottom:14px;line-height:1.5;">
            Vote on whether this difficulty is accurate. The majority wins — <strong>Too Easy</strong> raises it by 2, <strong>Too Hard</strong> lowers it by 2.
        </div>
        <div style="display:flex;gap:8px;">
            <button class="btn-dispute-vote easy" onclick="castDisputeVote('${groupCode}','${ownerId}','${taskId}',${currentDiff},${currentPts},'up')">
                <div style="font-size:18px;">📈</div>
                <div style="font-size:12px;font-weight:700;">Too Easy</div>
                <div style="font-size:10px;opacity:0.7;">Raise +2</div>
            </button>
            <button class="btn-dispute-vote fair" onclick="castDisputeVote('${groupCode}','${ownerId}','${taskId}',${currentDiff},${currentPts},'down')">
                <div style="font-size:18px;">✅</div>
                <div style="font-size:12px;font-weight:700;">Fair</div>
                <div style="font-size:10px;opacity:0.7;">Keep as-is</div>
            </button>
            <button class="btn-dispute-vote hard" onclick="castDisputeVote('${groupCode}','${ownerId}','${taskId}',${currentDiff},${currentPts},'hard')">
                <div style="font-size:18px;">📉</div>
                <div style="font-size:12px;font-weight:700;">Too Hard</div>
                <div style="font-size:10px;opacity:0.7;">Lower −2</div>
            </button>
        </div>`
        }`;

    modal.classList.add("open");
}

async function castDisputeVote(
    groupCode,
    ownerId,
    taskId,
    currentDiff,
    currentPts,
    vote,
) {
    const myId = getMyId();
    const disputePath = `groups/${groupCode}/disputes/${ownerId}/${taskId}`;

    try {
        await db.ref(`${disputePath}/votes/${myId}`).set(vote);
        await db.ref(`${disputePath}/taskId`).set(taskId);
        await db.ref(`${disputePath}/ownerId`).set(ownerId);
        await db.ref(`${disputePath}/originalDiff`).set(currentDiff);
        await db.ref(`${disputePath}/createdAt`).set(Date.now());

        const snap = await db.ref(disputePath).once("value");
        const dispute = snap.val();
        const votes = Object.values(dispute.votes || {});
        const upVotes = votes.filter((v) => v === "up").length;
        const downVotes = votes.filter((v) => v === "down").length;
        const hardVotes = votes.filter((v) => v === "hard").length;
        const total = votes.length;

        // Get member count for quorum
        const membersSnap = await db
            .ref(`groups/${groupCode}/members`)
            .once("value");
        const memberCount = membersSnap.val()
            ? Object.keys(membersSnap.val()).length
            : 1;
        const otherCount = Math.max(1, memberCount - 1);

        const allVoted = total >= otherCount;
        const clearMajority =
            total >= 2 && Math.max(upVotes, downVotes, hardVotes) / total > 0.6;

        if (allVoted || clearMajority) {
            // Determine winner — most votes wins; ties keep as-is
            let newDiff = currentDiff;
            let outcome = "kept";
            if (upVotes > downVotes && upVotes > hardVotes) {
                newDiff = Math.min(10, currentDiff + 2);
                outcome = "raised";
            } else if (hardVotes > downVotes && hardVotes > upVotes) {
                newDiff = Math.max(1, currentDiff - 2);
                outcome = "lowered";
            }

            const newPts =
                newDiff !== currentDiff
                    ? calcPoints(newDiff, 60, Date.now() + 86400000, Date.now())
                    : currentPts;

            await db.ref(`${disputePath}/resolved`).set(true);
            await db.ref(`${disputePath}/resolvedDiff`).set(newDiff);
            await db.ref(`${disputePath}/resolvedAt`).set(Date.now());

            if (newDiff !== currentDiff) {
                const tasksSnap = await db
                    .ref(`groups/${groupCode}/memberTasks/${ownerId}`)
                    .once("value");
                const tasksRaw = tasksSnap.val();
                const tasksArr = tasksRaw
                    ? Array.isArray(tasksRaw)
                        ? tasksRaw
                        : Object.values(tasksRaw)
                    : [];
                const updated = tasksArr.map((t) =>
                    t.id === taskId
                        ? { ...t, difficulty: newDiff, points: newPts }
                        : t,
                );
                await db
                    .ref(`groups/${groupCode}/memberTasks/${ownerId}`)
                    .set(updated);
            }

            closeAddTask();
            const msg =
                outcome === "raised"
                    ? `⚖️ Resolved! Difficulty raised ${currentDiff} → ${newDiff} (+2)`
                    : outcome === "lowered"
                      ? `⚖️ Resolved! Difficulty lowered ${currentDiff} → ${newDiff} (−2)`
                      : `⚖️ Resolved! Rating kept at ${currentDiff} — majority said it's fair`;
            alert(msg);
        } else {
            closeAddTask();
        }
    } catch (err) {
        alert("Failed to cast vote: " + err.message);
    }
}

// ============================================
// DELETE / LEAVE GROUP
// ============================================
async function deleteGroup(code) {
    if (!confirm("Delete this group? All members will lose access.")) return;
    try {
        await db.ref(`groups/${code}`).remove();
        state.myGroupCodes = (state.myGroupCodes || []).filter(
            (c) => c !== code,
        );
        stopListeningToGroup(code);
        save();
        renderCompete();
    } catch (err) {
        alert("Failed to delete: " + err.message);
    }
}

async function leaveGroup(code) {
    if (!confirm("Leave this group?")) return;
    const myId = getMyId();
    try {
        await db.ref(`groups/${code}/members/${myId}`).remove();
        await db.ref(`groups/${code}/memberTasks/${myId}`).remove();
        state.myGroupCodes = (state.myGroupCodes || []).filter(
            (c) => c !== code,
        );
        stopListeningToGroup(code);
        save();
        renderCompete();
    } catch (err) {
        alert("Failed to leave: " + err.message);
    }
}

function renderChallenges(el) {
    if (!state.completedChallenges) state.completedChallenges = {};
    const now = Date.now();

    // Group challenges: daily, weekly, milestones
    const groups = [
        {
            label: "⚡ Daily",
            ids: CHALLENGES.filter((c) => c.windowDays === 1).map((c) => c.id),
        },
        {
            label: "📅 Weekly",
            ids: CHALLENGES.filter((c) => c.windowDays === 7).map((c) => c.id),
        },
        {
            label: "🏆 Milestones",
            ids: CHALLENGES.filter((c) => c.windowDays === 0).map((c) => c.id),
        },
    ];

    let html = "";
    groups.forEach(({ label, ids }) => {
        const group = CHALLENGES.filter((c) => ids.includes(c.id));
        if (!group.length) return;
        html += `<div class="challenge-group-label">${label}</div>`;
        group.forEach((ch) => {
            const done = state.completedChallenges[ch.id];
            const { value, max } = getChallengeProgress(ch);
            const pct = Math.min(100, Math.round((value / max) * 100));
            const isComplete = done || value >= max;

            let timeLabel = "";
            if (ch.windowDays > 0 && !done) {
                const msLeft =
                    ch.windowDays * 86400000 -
                    (now % (ch.windowDays * 86400000));
                const hLeft = Math.floor(msLeft / 3600000);
                timeLabel =
                    hLeft < 24 ? `${hLeft}h left` : `${ch.windowDays}d window`;
            } else if (done) {
                timeLabel = "Completed ✓";
            } else {
                timeLabel = "All time";
            }

            html += `<div class="challenge-card${isComplete ? " challenge-done" : ""}">
                <div class="challenge-header">
                    <div style="display:flex;align-items:center;gap:10px;">
                        <span style="font-size:24px;">${ch.icon}</span>
                        <div>
                            <div class="challenge-title">${ch.title}</div>
                            <div class="challenge-desc">${ch.desc}</div>
                        </div>
                    </div>
                    <div style="text-align:right;flex-shrink:0;">
                        <div class="challenge-bonus${isComplete ? " earned" : ""}">+${ch.bonus}</div>
                        <div class="challenge-deadline">${timeLabel}</div>
                    </div>
                </div>
                <div class="challenge-bar-track">
                    <div class="challenge-bar-fill${isComplete ? " complete" : ""}" style="width:${pct}%"></div>
                </div>
                <div class="challenge-progress">
                    ${
                        isComplete
                            ? `<span style="color:var(--success);font-weight:700;">✓ Bonus awarded: +${ch.bonus} pts</span>`
                            : `${value} / ${max} · ${pct}%`
                    }
                </div>
            </div>`;
        });
    });

    el.innerHTML =
        html ||
        `<div class="empty-state"><div class="emoji">🎯</div><h3>No challenges</h3></div>`;
}

// ============================================
// PROFILE SCREEN
// ============================================
function renderProfile() {
    const p = state.profile;
    const prog = levelProgress(p.totalPoints);
    const ptsToNext = Math.round(p.level * 150 * (1 - prog));

    // Activity — last 7 days
    const dayLabels = ["S", "M", "T", "W", "T", "F", "S"];
    let activityHtml = "";
    for (let i = 6; i >= 0; i--) {
        const d = new Date();
        d.setDate(d.getDate() - i);
        const ds = startOfDay(d),
            de = ds + 86400000;
        const count = state.tasks.filter(
            (t) => t.completed && t.completedAt >= ds && t.completedAt < de,
        ).length;
        const intensity = Math.min(1, count / 4);
        const bg =
            intensity > 0
                ? `rgba(0,245,212,${0.15 + intensity * 0.85})`
                : "var(--bg)";
        activityHtml += `<div class="activity-day"><div class="activity-block" style="background:${bg}"></div><div class="activity-label">${dayLabels[d.getDay()]}</div></div>`;
    }

    document.getElementById("profileContent").innerHTML = `
    <div class="profile-card">
      <div class="profile-emoji">${p.emoji}</div>
      <div>
        <div class="profile-name">${esc(p.name)}</div>
        <div><span class="profile-level">Lv. ${p.level}</span><span class="profile-title">${levelTitle(p.level)}</span></div>
      </div>
    </div>
    <div class="level-card">
      <div class="level-header"><span>Level ${p.level}</span><span class="next">Level ${p.level + 1}</span></div>
      <div class="level-bar-track"><div class="level-bar-fill" style="width:${prog * 100}%"></div></div>
      <div class="level-remaining">${ptsToNext} pts to next level</div>
    </div>
    <div class="stats-grid">
      <div class="stat-card"><div class="stat-icon">⭐</div><div class="stat-value">${p.totalPoints}</div><div class="stat-label">Total Points</div></div>
      <div class="stat-card"><div class="stat-icon">✅</div><div class="stat-value">${p.tasksCompleted}</div><div class="stat-label">Tasks Done</div></div>
      <div class="stat-card"><div class="stat-icon">🔥</div><div class="stat-value">${p.streak}</div><div class="stat-label">Current Streak</div></div>
      <div class="stat-card"><div class="stat-icon">🏆</div><div class="stat-value">${p.bestStreak}</div><div class="stat-label">Best Streak</div></div>
    </div>
    <div class="activity-card"><h4>This Week</h4><div class="activity-row">${activityHtml}</div></div>
    <button class="reset-btn" onclick="resetAll()">Reset All Data</button>`;
}

function resetAll() {
    if (
        !confirm(
            "Delete all tasks, points, and progress? This cannot be undone.",
        )
    )
        return;
    localStorage.removeItem("clutch_state");
    location.reload();
}

// ============================================
// INIT
// ============================================
document.addEventListener("DOMContentLoaded", () => {
    load();
    document.querySelector(".tab-bar").style.display = state.onboarded
        ? "flex"
        : "none";
    initOnboarding();
    initNav();
    // Close modal on overlay click
    document.getElementById("addTaskModal").addEventListener("click", (e) => {
        if (e.target === document.getElementById("addTaskModal"))
            closeAddTask();
    });
});