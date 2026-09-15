# Delivering Value with Agile Methodologies

> Red Hat TL250 — Chapter 6 | Open Practice Library

---

## Overview

Delivery practices implement the solution identified during the Options Pivot. Teams organize delivery around **time-boxed iterations**, delivering an **increment of value** by the end of each one.

| Practice           | OPL Category | Mobius Phase                  |
| ------------------ | ------------ | ----------------------------- |
| Increment Planning | Delivery     | Delivery Loop                 |
| Daily Standup      | Foundation   | Foundation                    |
| Backlog Refinement | Options      | Options Pivot                 |
| Showcase           | Delivery     | Delivery Loop                 |
| Retrospectives     | Foundation   | Foundation (covered in Ch. 2) |
| Kanban             | Delivery     | Delivery Loop                 |

> Agile ceremonies and Kanban are **complementary, not mutually exclusive**. Many teams use Kanban alongside some agile ceremonies.

---

## 6.1 The Five Agile Ceremonies

### Overview and Purpose

| Ceremony               | Purpose                                                  | When                                        |
| ---------------------- | -------------------------------------------------------- | ------------------------------------------- |
| **Increment Planning** | Commit to work and set the increment goal                | Start of increment                          |
| **Daily Standup**      | Synchronize efforts; surface impediments                 | Every day (fixed time)                      |
| **Backlog Refinement** | Clarify work items and acceptance criteria               | During increment (not same day as planning) |
| **Showcase**           | Demonstrate completed work; collect stakeholder feedback | Last day of increment                       |
| **Retrospectives**     | Reflect, inspect, and adapt ways of working              | After Showcase, before next planning        |

> Ceremonies work together to create **short feedback loops** and increase adaptability to changing requirements and business goals.

---

### Increment Planning

Teams commit to a **set of defined work** and establish an **increment goal** for the upcoming time-boxed cycle.

**Benefits:**

- Helps the team accommodate and accept changes during delivery
- Through incremental deliveries, teams use feedback to adjust software design or accept new requirements
- As forecasting improves, the team can communicate better delivery estimates and risks

**Facilitation Steps:**

1. Identify attendees and schedule the meeting (plan for logistics/video conferencing)
2. Verify the product backlog was updated after last refinement — top items should be well-understood
3. Verify the sprint board is ready
4. **Propose an increment goal**
5. Review action items from the last retrospective and any lingering issues
6. Review work items with the team; determine what to complete to meet the goal; clarify acceptance criteria and Definition of Done; agree on capacity
7. Team agrees on the increment backlog — if no unified agreement, revisit earlier steps
8. Start the increment

---

### Daily Standup

A **short, fixed-length, fixed-time** daily meeting to synchronize efforts and surface impediments early.

**Three Questions (round-robin):**

1. What did you do **yesterday**?
2. What will you do **today**?
3. Do you have any **blockers or impediments**?

> Follow-up questions and blockers are captured in the **Parking Lot** for deeper discussion after the standup — not resolved during it.

**Benefits:**

- Increases team involvement and collaboration
- Team members help each other when problems arise
- Impediments are identified and shared **early**
- Every team member has a daily voice in project success

---

### Backlog Refinement

A **time-boxed** activity where team and product owner review and clarify backlog items to ensure they are well-understood before the next increment.

**What gets discussed:**

- Team questions about current or future work items
- New work items
- New details added to existing future items

**Benefits:**

- Creates alignment between development team, product owner, and stakeholders
- Provides consistent time to understand product vision and direction
- Enables quicker increment planning — items already clarified before sprint starts
- Product owner/stakeholders get action items; immediate answers not required

**Scheduling tip:** Schedule on a different day than increment planning to avoid meeting overload. For increments longer than 1 week, schedule **multiple refinement sessions** per increment.

---

### Showcase

A **demonstration of completed increment work** to stakeholders and interested parties, collecting feedback.

> Show **what was done**, not what is coming. Demonstrate from the perspective of a **product user**.

**Benefits:**

- Creates periodic feedback points throughout the project
- Allows the team to adjust and deliver a better product over iterations
- Stakeholders see the product being built (not just status reports on % complete)
- Provides an opportunity to celebrate the work done and validate next steps

**Facilitation Steps:**

1. Identify attendees and schedule (plan logistics)
2. Determine agenda and presenters — focus on completed work
3. Perform a **dry run** with the working software
4. Perform the showcase
5. **Explicitly ask for feedback** and validate direction/next steps with stakeholders

> **Interactive showcases** generate more valid and candid feedback than passive presentations.

---

### Retrospectives

Covered in detail in [Chapter 2](../Getting%20Started%20with%20DevOps%20Culture%20and%20Practices%20%26%20Fostering%20Culture%20and%20Collaboration/README.md#24-retrospectives). Key scheduling note here:

- Scheduled **after Showcase**, **before the next Increment Planning**
- Always provide a **break between Showcase and Retrospective** — lets the team absorb feedback
- Use to evaluate the ceremonies themselves — if a ceremony isn't working, the retrospective is where to fix it

---

### Two-Week Increment Cadence (Example Sequence)

```
Day 1:     Increment Planning
Days 2-9:  Development
Day 3/4:   Backlog Refinement #1
Day 7/8:   Backlog Refinement #2 (for >1 week increments)
Every day: Daily Standup
Day 10:    Showcase → [break] → Retrospective
           ↓
Day 11:    Increment Planning (next cycle)
```

---

### Optimizing Agile Ceremonies

| Practice            | How It Helps Ceremonies                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Retrospectives**  | Evaluate and improve ceremonies themselves; track action plans                                                               |
| **Social Contract** | Guides team behavior that affects ceremony effectiveness (e.g., "assume positive intent", "every idea deserves to be heard") |
| **Parking Lot**     | Keeps ceremony discussions on topic; captures off-topic items for later                                                      |

> **Key principle:** Don't abandon a ceremony if it's not working — use feedback to adapt it. Try each activity more than once before concluding it provides no value.

---

### Metrics Collected During Ceremonies

**At the Showcase:**

- How well the team achieved the increment goal
- Whether the team delivered the expected amount of planned work
- DevOps metrics: deployment frequency, time to fix broken builds, lead time for change, change failure rate
- Test code coverage

**At the Retrospective:**

- Team interaction quality
- Collaboration patterns with other teams
- Action plan experiments for the next increment

---

### When to Use Agile Ceremonies

Signs the team would benefit from agile ceremonies:

- Misalignment between developers, ops, security, and testers
- Misalignment between stakeholder vision and team understanding
- Team doesn't know why a design decision was made
- Disengagement from the delivery team
- "Scope creep" feeling from stakeholders
- Constantly changing priorities
- "Analysis paralysis" before starting work
- Management pressure emphasizing time/budget at the expense of quality

> ⚠️ Some scenarios are not solved by ceremonies alone — **team culture** also matters significantly.

---

## 6.2 Kanban

### Core Concept

A delivery practice originating from **Toyota's pull production system** (on-demand manufacturing). Adapted for software delivery: a **Kanban board** visualizes work items as cards in columns representing process stages.

**Core activities (Essential Kanban Condensed):**

1. **Visualize** — make work and the process visible
2. **Limit Work in Progress (WIP)** — prevent bottleneck accumulation
3. **Manage flow** — optimize the movement of tasks through stages
4. **Make policies explicit** — write rules on the board itself
5. **Implement feedback loops** — observe and respond to flow data
6. **Improve collaboratively, evolve experimentally**

---

### Board Mechanics

| Element                | Represents                                                                              |
| ---------------------- | --------------------------------------------------------------------------------------- |
| **Column**             | A stage in the delivery process                                                         |
| **Card / Sticky note** | A task or work item                                                                     |
| **WIP Limit**          | Maximum number of tasks allowed in a column simultaneously                              |
| **Swim Lane**          | A separate section of the board for tasks from different teams, processes, or customers |

**Basic pull flow:**

- Team member **pulls** a card from a previous column into an in-progress column when they start work
- Team member **pushes** the card to the "done" column when the stage is complete
- When a column hits its WIP limit → **stop pulling new work; help complete in-progress items first**

---

### The Eight Types of Lean Waste (Toyota)

Kanban was designed to eliminate these:

| Waste Type                | Description                                   |
| ------------------------- | --------------------------------------------- |
| **Overproduction**        | Building more than needed                     |
| **Waiting**               | Idle time between process steps               |
| **Transportation**        | Unnecessary movement of materials/information |
| **Processing**            | Steps that add no value                       |
| **Inventory**             | Excess work items piling up                   |
| **Movement**              | Unnecessary movement of people                |
| **Defects**               | Errors requiring rework                       |
| **Underutilized workers** | Skills not being used                         |

---

### Kanban vs. Scrum

| Aspect      | Kanban                                 | Scrum                                       |
| ----------- | -------------------------------------- | ------------------------------------------- |
| Iterations  | No fixed iterations — continuous flow  | Fixed-length sprints                        |
| Roles       | No prescribed roles                    | Scrum Master, Product Owner, Dev Team       |
| Ceremonies  | No prescribed ceremonies               | Planning, Standup, Review, Retrospective    |
| WIP limits  | Core principle                         | Not explicitly required                     |
| Flexibility | More flexible and adaptable            | More prescriptive and structured            |
| Best for    | Continuous delivery, support/ops teams | Feature development with predictable cycles |

> Teams without extensive agile experience may benefit from Scrum's more prescriptive structure. Kanban principles are **universally applicable** regardless of methodology.

---

### Setting Up a Kanban Board

**Minimal board (starting point):**

```
┌─────────────┬──────────────────┬─────────────┐
│   To Do     │   In Progress    │    Done     │
│             │  (WIP limit: 5)  │             │
│ • Task A    │ • Task C         │ • Task F   │
│ • Task B    │ • Task D         │             │
│ • Task E    │                  │             │
└─────────────┴──────────────────┴─────────────┘
```

**More detailed board (when distinct phases exist):**

```
To Do → Dev In Progress → Dev Done → Review In Progress → Done
```

Each hand-off to a different person/team is a good candidate for a new column.

**WIP limit guidance:** A good starting limit = number of team members who can perform work in that stage.

---

### Observations You Can Make from a Kanban Board

| Observation                               | Indicates                                                             |
| ----------------------------------------- | --------------------------------------------------------------------- |
| Cards accumulating in one column          | **Bottleneck** at that stage                                          |
| Many cards in progress simultaneously     | **Excessive parallelization** / context switching                     |
| Cards frequently moving backward          | Presence of **defects**                                               |
| Long lead time from one stage to the next | **Improvement opportunity** at that specific stage                    |
| Long total lead time                      | Evaluate **overall process** effectiveness                            |
| Cards piling up waiting to be pulled      | **Imbalance** — upstream producing faster than downstream can consume |

---

### Example: Kanban in Practice (Security-Focused Team)

A team with strict security and quality requirements builds this board:

```
Backlog → Dev In Progress → Dev Done → Code Review In Progress →
Code Review Done → Security Audit In Progress → Done
```

**Iterative improvements:**

1. Team observes many cards stuck in "Dev Done" → impose WIP limit of 3
   - Lead time: 20 days → **15 days** ✓
2. Team measures per-column lead time → "Security Audit" takes 10 days
3. Security team identifies recurring issues → implements:
   - **Automated security tests** in CI (catching common issues earlier)
   - **Documented checklist** with remediation steps
4. Final lead time: 20 days → **8 days** (60% reduction) ✓

> This mirrors the **Theory of Constraints** (from Ch. 4 MBPM): identify the constraint, exploit it, alleviate it, repeat.

---

### Flow Manager Role

Consider assigning a team member to **proactively manage flow**:

- Names: "Flow Manager", "Service Delivery Manager", "Delivery Manager", "Flow Master"
- Monitors the board, identifies accumulations, proposes WIP limit adjustments
- All team members should observe and contribute to flow improvement

---

### Chaining with Other Practices

| Practice               | Connection                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| **Backlog Refinement** | Defines the Definition of Ready for cards entering the board                                      |
| **Definition of Done** | Defines policies for cards moving to "Done"                                                       |
| **Daily Standup**      | Used alongside Kanban when spontaneous communication isn't enough                                 |
| **Retrospectives**     | Review flow metrics and adapt the board design                                                    |
| **MBPM**               | Complementary — both identify process bottlenecks, but MBPM goes deeper into time/quality metrics |

---

## Summary

| Practice               | Key Takeaway                                                                                           |
| ---------------------- | ------------------------------------------------------------------------------------------------------ |
| **Increment Planning** | Time-boxed commitment to a goal + delivery plan; enables adaptability through iterations               |
| **Daily Standup**      | 3 questions, round-robin, parking lot for blockers — keeps the team synchronized daily                 |
| **Backlog Refinement** | Clarifies work before the sprint — quicker planning, better alignment                                  |
| **Showcase**           | Interactive demo to stakeholders → real feedback, not status reports                                   |
| **Kanban**             | Pull-based, WIP-limited board — visualizes flow, surfaces bottlenecks, continuously improves lead time |

### The Delivery Loop in Practice

```
OPTIONS PIVOT (Value Slicing, Impact & Effort)
       ↓
DELIVERY LOOP:
  ┌── Increment Planning ──────────────────────────┐
  │  Daily Standup (every day)                      │
  │  Backlog Refinement (mid-increment)             │
  │  [Build → Measure → Learn]                      │
  │  Showcase → Retrospective                       │
  └────────────────────────────────────────────────┘
       ↓
  (Back to Options Pivot OR Discovery Loop based on learnings)
```

> **Deliver → Measure → Learn → Adapt.** Every increment is an opportunity to either validate that you're on the right path or to discover you need to pivot.
