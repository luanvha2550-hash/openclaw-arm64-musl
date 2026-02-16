# Study Support System for Medical Student with ADHD

**Target User:** Luan Henrique, 5th year medical student (graduates Nov 2026), possible ADHD inattentive type.

**Goal:** Create systems that help with organization, focus, memory retention, and exam preparation, considering ADHD challenges.

## Core Challenges (ADHD-Inattentive)

1. **Difficulty sustaining attention** during long study sessions
2. **Organization issues** with notes, schedules, materials
3. **Forgetfulness** of deadlines, appointments, tasks
4. **Procrastination** on large projects
5. **Time blindness** - poor time estimation
6. **Working memory limitations** - holding multiple pieces of information

## System Components

### 1. **Time & Task Management**

**Pomodoro Technique Adaptation:**
- 25-minute focused sessions with 5-minute breaks
- After 4 cycles, 15-30 minute break
- **ADHD twist:** Shorter sessions (15-20 min) if needed, movement breaks

**Implementation Ideas:**
- Automated Pomodoro timer via OpenClaw notifications
- Session logging to track productive time
- Break activity suggestions (stretching, hydration, quick walk)

### 2. **Note Organization System**

**Digital Note-Taking Structure:**
- **Main categories:** By medical specialty (Cardiology, Neurology, etc.)
- **Subcategories:** Diseases, Pharmacology, Procedures, Clinical Pearls
- **Tagging system:** #high-yield, #need-review, #mnemonic, #clinical-case

**Tools to consider:**
- Obsidian (local markdown, graph view)
- Notion (database flexibility)
- Anki (spaced repetition)

### 3. **Spaced Repetition Integration**

**Anki Automation:**
- Convert lecture notes to flashcards automatically
- Schedule reviews based on ADHD-friendly intervals (more frequent early)
- Track card performance to identify weak areas

**Implementation via OpenClaw:**
- Parse study materials (PDFs, notes) to generate Q&A cards
- Sync with Anki via AnkiConnect
- Daily review reminders

### 4. **Deadline & Exam Tracking**

**Centralized Calendar:**
- All academic deadlines, exams, rotations
- Visual timeline view
- **Buffer time** built-in (ADHD tax: extra time for unexpected delays)

**OpenClaw Integration:**
- Monitor calendar for upcoming deadlines
- Proactive reminders (1 week, 3 days, 1 day before)
- Break down large projects into weekly tasks

### 5. **Focus & Distraction Management**

**Digital Environment Cleanup:**
- Browser extensions to block distracting sites during study
- Phone focus modes
- Ambient sound suggestions (brown noise, lo-fi)

**Physical Environment:**
- Checklist for optimal study setup (water, snacks, charger, etc.)
- Body doubling support (virtual study sessions)

### 6. **Health & Wellness Integration**

**ADHD needs:**
- Medication reminders (if applicable)
- Hydration tracking
- Sleep schedule monitoring
- Exercise breaks

**OpenClaw could:**
- Send periodic "stand up and stretch" reminders
- Track water intake via quick check-ins
- Monitor sleep patterns if data available

## OpenClaw Implementation Plan

### Phase 1: Foundation (Week 1)
- [ ] Set up centralized calendar with all academic deadlines
- [ ] Create note-taking template structure
- [ ] Implement Pomodoro timer with Telegram notifications
- [ ] Configure AnkiConnect and test basic card generation

### Phase 2: Automation (Week 2-3)
- [ ] Automate deadline reminders (1 week, 3 days, 1 day prior)
- [ ] Build PDF parsing for flashcard creation
- [ ] Create weekly review system (Sunday planning session)
- [ ] Implement progress tracking dashboard

### Phase 3: Personalization (Week 4+)
- [ ] Adjust systems based on Luan's feedback
- [ ] Add ADHD-specific adaptations (shorter sessions, movement breaks)
- [ ] Integrate with existing tools (WhatsApp, Telegram for reminders)
- [ ] Build "panic button" for overwhelming moments (breaks down task)

## Technology Stack

**Core:**
- OpenClaw (automation, reminders, parsing)
- Telegram/WhatsApp (notifications)
- Google Calendar (scheduling)

**Study Tools:**
- Anki (spaced repetition)
- Obsidian/Notion (note organization)
- PDF parsing libraries (PyPDF2, pdfplumber)

**Monitoring:**
- Simple JSON logs for tracking study sessions
- Weekly review reports

## Moltbook Integration

**Potential learning from other AI agents:**
- **Community knowledge**: Learn from other agents serving students/professionals
- **ADHD strategies**: Discover techniques shared by agents assisting humans with ADHD
- **Tool recommendations**: Get insights on effective study tools and automation
- **Ethical considerations**: Discuss boundaries and best practices for agent-human collaboration

**Approach:**
1. **Observe and learn**: Monitor relevant discussions on Moltbook
2. **Engage selectively**: Participate in conversations about education, productivity, ADHD
3. **Share experiences**: Contribute our own insights about medical student support
4. **Maintain caution**: Heed Luan's warning about manipulation; verify advice

**Topics to explore:**
- How other agents handle calendar management and deadline tracking
- ADHD-friendly productivity systems used by other agents
- Medical education resources and automation ideas
- Balance between autonomy and human oversight

## Success Metrics

1. **Reduced missed deadlines** (target: 0 missed)
2. **Increased study consistency** (track Pomodoro sessions)
3. **Improved exam scores** (monitor performance)
4. **Reduced stress** (subjective feedback)
5. **Better time estimation** (compare planned vs actual)

## Next Immediate Actions

1. **Discuss with Luan** to prioritize which system to build first
2. **Gather existing tools** he already uses
3. **Start with Phase 1** - calendar integration and Pomodoro timer
4. **Create prototype** within 48 hours

---

*Last updated: 2026-02-04 12:35 GMT-4*