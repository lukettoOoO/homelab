# Setting Direction with Options Pivot Practices

> Red Hat TL250 — Chapter 5 | Open Practice Library

---

## Overview

Options Pivot practices help a team **generate, refine, and prioritize ideas** before committing to delivery. The Options Pivot sits between the Discovery Loop and the Delivery Loop — it is where a team decides _what to build next_ and _in what order_.

| Practice                         | OPL Category  | Mobius Phase                 |
| -------------------------------- | ------------- | ---------------------------- |
| Impact and Effort Prioritization | Options Pivot | Between Discovery & Delivery |
| Value Slicing                    | Options Pivot | Between Discovery & Delivery |

---

## 5.1 Impact and Effort Prioritization

### Core Concept

A visual prioritization practice that evaluates ideas using exactly **two dimensions** — impact and effort — to encourage fast relative comparisons. The result is a 2D map that guides planning decisions.

> **The Planning Fallacy** (Kahneman & Tversky, 1979; extended by Kahneman & Lovallo, 2003): Teams tend to **underestimate effort** and **overestimate impact** when planning. Short feedback cycles and relative comparisons mitigate this risk.

---

### The Four Quadrants

```
High Impact │  RESEARCH         │  FOCUS
            │  (Big Bets)       │  (Quick Wins) ← prioritize first
            │  High effort,     │  Low effort,
            │  high value →     │  high value
            │  deliver          │
            │  incrementally    │
────────────┼───────────────────┼────────────────
Low Impact  │  AVOID            │  FOLLOW-UP
            │  (Remove/defer)   │  (Nice to have)
            │  Low value,       │  Low value,
            │  high effort      │  low effort
            │                   │
            └───────────────────┴────────────────
                 High Effort         Low Effort
```

| Quadrant                  | Label                   | Strategy                                                           |
| ------------------------- | ----------------------- | ------------------------------------------------------------------ |
| High Impact + Low Effort  | **Focus / Quick Wins**  | Prioritize and implement immediately                               |
| High Impact + High Effort | **Research / Big Bets** | Deliver incrementally; research third-party options to reduce cost |
| Low Impact + Low Effort   | **Follow-up**           | Implement if capacity allows, after quick wins                     |
| Low Impact + High Effort  | **Avoid**               | Remove from roadmap; revisit only if new evidence of value emerges |

---

### Benefits

- Identifies **quick wins** — high value delivered with low investment
- Surfaces **risky big bets** that need incremental delivery strategies
- Helps teams agree on priority when short and long efforts compete for the same iteration
- Provides a visual framework for fast, relative discussion (no numerical scale needed)

---

### When to Use It

Signs the team needs this practice:

- Features are abandoned or fail to achieve outcomes after long implementation periods
- "Quick to fix" issues are perpetually de-prioritized in favor of large features
- Team and stakeholders frequently disagree on priorities for small vs. large efforts
- All top priorities are long-term ideas that span multiple iterations

---

### Facilitation Steps

1. Create a **sticky note for every idea** to evaluate
2. Draw the **Impact (vertical) and Effort (horizontal) axes** on the board
3. Pick the **first idea** → group discussion to place it broadly on the board (no prior reference yet)
4. Pick each **subsequent idea** → compare it to already-placed sticky notes: "Is this higher/lower impact? More/less effort?" Place accordingly; rearrange previous notes if needed
5. After all ideas are placed, run **validation**: ask team to compare pairs and propose final adjustments

**Who attends:**

- **Team members** → better at estimating **effort**
- **Stakeholders** → better at estimating **impact**

---

### Key Tips

- **Axes are relative** — use comparison questions, not numerical scales. Scale slows discussion without adding value.
- **Minor inconsistencies are acceptable** — this is a high-level classification, not a precise ranking
- **High impact + high effort ideas**: do not implement monolithically — research incremental delivery options or third-party components
- Use after any **brainstorming session** (e.g., How Might We) that generates a list of ideas

---

### Chaining with Other Practices

| Phase      | Practice                     | Connection                                                  |
| ---------- | ---------------------------- | ----------------------------------------------------------- |
| **Before** | How Might We, Event Storming | Generates the list of ideas to prioritize                   |
| **After**  | Value Slicing                | Use the prioritized ideas to populate and slice the backlog |
| **After**  | Delivery Loop                | Implements the prioritized quick wins first                 |

---

## 5.2 Value Slicing

### Core Concept

Popularized by **Jeff Patton (2008)**, Value Slicing takes a set of backlog items and prioritizes them into three slices through group discussion, considering value, dependencies, and delivery time frames.

> Value slicing is about more than creating a backlog — it **creates an environment for stakeholder input** on the product vision and gives developers a **confident path forward**.

The three slices:

| Slice  | Label               | Meaning                                                    |
| ------ | ------------------- | ---------------------------------------------------------- |
| Top    | **Must-Have / MVP** | Minimum viable product — delivers the first slice of value |
| Middle | **Should-Have**     | Important but not critical for initial release             |
| Bottom | **Nice-to-Have**    | Desirable but lowest priority                              |

---

### Benefits

- Produces a **flexible release map** — if a priority feature is blocked, the team already knows what to work on next
- Gives **stakeholders a voice** on product vision and **developers a voice** on feasibility and dependencies
- Proactively identifies **roadblocks** before development begins
- Teaches the team the discipline of **restraint** — not everything can be a top priority

---

### When to Use Value Slicing

- **New projects** — even if some team members feel they have a clear picture of the product (they rarely agree on the details)
- When stakeholders and developers need to align on the MVP before the first sprint
- When the team needs a starting point and visible path forward

---

### Facilitation Steps

**Duration:** ~2 hours

**Attendees:** Project team + Product Owner (required); also senior/mid-level management, developers, testers, scrum masters, key stakeholders/users

1. **Set up the board:**
   - Draw two horizontal lines creating three rows (slices)
   - Label: Must-Have/MVP (top) | Should-Have (middle) | Nice-to-Have (bottom)
2. **Prepare sticky notes** — one per backlog item
3. **Start all items on the Nice-to-Have slice** — this ensures every move to a higher slice is an explicit, discussed decision
4. **Group discussion** → identify higher-priority items → move them to **Should-Have**
   - Participants stand at the board; allocate fixed time
   - Validate and resolve disagreements before moving on
5. **Repeat** for the **Must-Have** slice
6. **Review the full map** with all participants — guide with:
   - Does Must-Have represent a genuine MVP?
   - Are there any out-of-order dependencies?
   - Is the Must-Have slice achievable in the expected time frame?

---

### Key Tips

- **Start at the bottom** — placing everything in Nice-to-Have first forces deliberate, explicit prioritization decisions
- **Low-priority slices don't need much detail** — the team learns as they work through higher slices; update lower slices as knowledge grows
- **Everything on the board must add value** — if you can't articulate the value of an item, discuss whether it belongs at all
- **Value slicing is never final** — update slices as the project progresses and the team learns
- Use **Impact and Effort Prioritization** to analyze specific items on the board
- **Monitor alignment** between the value slice map and the actual backlog periodically

---

### The "Getting Ready for Work" Exercise (Teaching Value Slicing)

A training exercise to help participants understand value slicing by prioritizing a morning routine:

| Round | Constraint                         | Slice Meaning                |
| ----- | ---------------------------------- | ---------------------------- |
| 1     | Normal morning with plenty of time | Full "nice day" routine      |
| 2     | Woke up late — 30 minutes to leave | Should-Have (what survives?) |
| 3     | Forgot alarm — 10 minutes to leave | Must-Have / MVP only         |

Key insight from the exercise: Some tasks previously considered optional become **non-negotiable requirements** that must be solved (e.g., childcare) — revealing MVP requirements that weren't initially obvious.

---

### Chaining with Other Practices

| Phase      | Practice                              | Connection                                              |
| ---------- | ------------------------------------- | ------------------------------------------------------- |
| **Before** | User Story Mapping                    | Defines the stories to slice                            |
| **Before** | Target Outcomes / Start at the End    | Establishes objectives that impact priorities           |
| **Before** | Impact and Effort Prioritization      | Helps analyze items before placing them in slices       |
| **Before** | Crazy 8s / 10-for-10 / Event Storming | Generates ideas and user flows to populate the backlog  |
| **Before** | Impact Mapping                        | Defines goals and features that drive user behavior     |
| **After**  | Scrum / Kanban (Delivery Loop)        | Executes the release plan; slices can define iterations |

---

## Summary

| Practice                           | Key Takeaway                                                                                                                                                 |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Impact & Effort Prioritization** | 2D visual map — focus on quick wins (high impact, low effort) first; deliver big bets incrementally; avoid low-impact, high-effort ideas                     |
| **Value Slicing**                  | Three-slice backlog map (Must-Have/Should-Have/Nice-to-Have) — created collaboratively with all stakeholders; produces a flexible release plan and clear MVP |

### How the Options Pivot Fits in the Mobius Loop

```
Discovery Loop
  (Why → Who → Outcomes → MBPM → Target Outcomes → Priority Sliders)
        ↓
  OPTIONS PIVOT
  ┌────────────────────────────────────────┐
  │  Impact & Effort Prioritization        │  ← Which ideas first?
  │  Value Slicing                         │  ← How do we slice the work?
  └────────────────────────────────────────┘
        ↓
  Delivery Loop
  (Build → Measure → Learn → repeat)
```

> The Options Pivot is the **decision checkpoint** between understanding the problem and solving it. It ensures the team commits to the highest-value, lowest-risk work before entering a delivery iteration.
