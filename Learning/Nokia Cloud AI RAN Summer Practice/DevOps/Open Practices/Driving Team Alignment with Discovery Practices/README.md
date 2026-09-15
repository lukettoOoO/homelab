# Driving Team Alignment with Discovery Practices

> Red Hat TL250 — Chapter 4 | Open Practice Library

---

## Overview

Discovery practices help teams find **shared purpose and alignment** on project outcomes. All three practices covered are **Discovery Loop** practices in the Mobius Loop, focused on the **Why → Who → Outcomes** elements.

| Practice                             | OPL Category | Mobius Element       |
| ------------------------------------ | ------------ | -------------------- |
| Metrics-based Process Mapping (MBPM) | Discovery    | Why / Who / Outcomes |
| Target Outcomes                      | Discovery    | Outcomes             |
| Priority Sliders                     | Discovery    | Outcomes             |

---

## 4.1 Metrics-based Process Mapping (MBPM)

### Core Concept

A **lean process improvement technique** that creates a detailed map of a process delivering a good or service to a customer. The map displays process steps, responsible actors, lead time metrics, and quality metrics — enabling teams to **identify bottlenecks and constraints**.

> MBPM differs from Value Stream Mapping (VSM): VSM shows **macro-level** value delivery streams across a company; MBPM shows **detailed process implementation steps** for a specific value stream.

---

### The Three Key Metrics (per Process Step)

| Metric                          | Symbol | Definition                                                                                                                             |
| ------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Process Time**                | PT     | Time the team/actor actively **executes** the step                                                                                     |
| **Lead Time**                   | LT     | Time elapsed from when work is **available** at a step to when it is **delivered** to the next step                                    |
| **Percent Complete & Accurate** | %C&A   | Percentage of step outputs that are complete and accurate — requiring **no corrections or clarifications** for downstream work centers |

> Each step also has a **verb-noun activity description** (e.g., "test code", "approve change", "deploy to production").

---

### How to Read a Process Map Table

Each row = one **time slice** (a vertical column of simultaneous steps).

| Field          | How to Calculate                                                    |
| -------------- | ------------------------------------------------------------------- |
| End-to-end PT  | Sum of all PT values                                                |
| End-to-end LT  | Sum of the **largest** PT value per time slice                      |
| PT/LT ratio    | PT ÷ LT (low ratio = bottleneck — work waits idle most of the time) |
| End-to-end PCA | **Multiply** all %C&A values together                               |

#### Example Summary Table

| Time Slice  | Step                  | PT (days) | LT (days) | PT/LT    | %C&A    |
| ----------- | --------------------- | --------- | --------- | -------- | ------- |
| 1           | Gather Requirements   | 4         | 5         | 80%      | 60%     |
| 2           | Implement Code        | 8         | 10        | 80%      | 70%     |
| 2           | Create Test Cases     | 5         | 6         | 83%      | 65%     |
| 3           | Update Deployment Doc | 0.5       | 0.5       | 100%     | 85%     |
| 4           | Deploy to QA          | 0.5       | 3         | 17%      | 50%     |
| 5           | Test New Code         | 3         | 4         | 75%      | 80%     |
| 6           | Create Change Request | 0.25      | 1         | 25%      | 95%     |
| **7**       | **Approve Change**    | **0.03**  | **5**     | **0.6%** | **40%** |
| 8           | Deploy to Production  | 1         | 2         | 50%      | 50%     |
| **Summary** | **End-to-End**        | **17.3**  | **30.5**  | **57%**  | **2%**  |

**Reading the results:**

- Only **2%** of deliverables emerge complete and accurate — 98% require fixes or rework
- **"Approve Change"** is the critical bottleneck: 5-day LT with only 0.03 days of actual work (0.6% PT/LT ratio)
- Improving this step delivers the maximum improvement to overall process lead time

---

### Benefits of MBPM

- Visualizes the **end-to-end process** and associated time/quality metrics
- Enables estimation of **ROI** for process improvements
- Builds **empathy** between teams — each team sees their work in the context of the larger process
- Helps teams understand what they unknowingly deliver as **faulty outputs** to downstream steps

---

### When to Use MBPM

Signs the process needs mapping:

- The process is large and complex — teams don't understand the full picture
- Components have different batch sizes (upstream won't pass until a batch is large enough)
- End-to-end lead time is measured in **weeks or months**
- Frequent low-quality deliverables or high change failure rate
- Deployment frequency measured in months or quarters
- Mean time to restore service (MTTR) is too high

---

### Facilitation Steps

1. Identify the process to map and all teams/actors involved
2. Gather representatives from **each team** in the process
3. At the session start: define **process start and end points** (add trigger on left, end marker on right)
4. Create a **row per actor/work center** on the left side
5. Lead a group discussion to identify steps between start and end; map interactions; parallel steps go in the same vertical time slice
6. After the session: participants agree on the flow, then **estimate PT, LT, and %C&A** for each step
7. Transfer to a table; calculate end-to-end totals

**Materials (in-person):** Drawing paper roll (canvas), A6 colored sticky notes, markers, charcoal pencil for connecting lines

---

### The Theory of Constraints (Goldratt, 1984)

> A small number of constraints limit a system's ability to produce more output. Every system has at least one constraint.

**Five Focusing Steps:**

| Step | Action                                                         |
| ---- | -------------------------------------------------------------- |
| 1    | **Identify** the system constraint (MBPM helps here)           |
| 2    | **Exploit** the constraint — get the most out of it            |
| 3    | **Subordinate** everything else to steps 1 & 2                 |
| 4    | **Alleviate** the constraint                                   |
| 5    | **Repeat** — improving a constraint causes a new one to emerge |

After implementing a solution, update the process map with **observed** metrics to verify improvement and detect new constraints.

---

### Chaining with Other Practices

| Phase      | Practice                       | Connection                                                 |
| ---------- | ------------------------------ | ---------------------------------------------------------- |
| **Before** | Value Stream Mapping (VSM)     | Identifies which process to map in detail with MBPM        |
| **After**  | CI/CD                          | MBPM often reveals opportunities to add/improve automation |
| **After**  | Impact & Effort Prioritization | Evaluate identified improvements by impact vs. cost        |

---

## 4.2 Target Outcomes

### Core Concept

A practice that helps the team **discover, write, and share their desired outcomes** — creating a canvas of measurable outcomes that serves as an information radiator throughout the project.

> Outcome = a **change in human behavior** that drives changes impacting long-term business results.
> Output = the scoped work a team completes (e.g., implementing a feature).

**Key distinction:** Not all outputs translate into value. A feature nobody uses is output without outcome.

---

### Benefits

- Creates **shared alignment and purpose** with team, stakeholders, and customers
- Constantly displayed outcomes remind the team of success criteria in daily activities
- Guides **prioritization of work items** and discussions in other Mobius Loop practices
- Helps the team **iterate** to find the right features that deliver value (outcomes over outputs)

---

### When to Use Target Outcomes

Signs the team needs this practice:

- A product was delivered on time/budget, but customers don't use it — and the team couldn't adapt quickly because the project was considered "finished"
- Daily work focuses on completing **features** instead of achieving **desired results**
- The team celebrates delivery **before** customers interact with the product
- Final product fails in the marketplace despite agile methods being followed
- Unexpected scope changes occur frequently

---

### Facilitation Steps

1. Identify and present the **project context** to the team
   - If context is unclear, use Start at the End, News Headlines, or Start with Why first
2. Use **Silent Collaboration** (or other brainstorming) to generate potential outcomes
3. Use **Affinity Mapping** to group similar outcomes; use **Dot Voting** to reach consensus on a small set
4. Review and structure outcomes to ensure they are **measurable**; identify how to quantify and measure each
5. Review and discuss with **all stakeholders** — ensure outcomes are not too narrow; obtain consent

---

### The Six Attributes of a Valid Outcome

| Attribute    | Description                                                              |
| ------------ | ------------------------------------------------------------------------ |
| **Name**     | Simple, action-based description                                         |
| **Scale**    | A measurable metric (binary "Yes/No" → likely an output, not an outcome) |
| **How**      | Defines how and when measurement is taken                                |
| **Baseline** | An existing measure to compare against                                   |
| **Target**   | The desired value of the metric                                          |
| **Value**    | The outcome achieves value when met                                      |

> These can be visualized as an **arrow diagram**: Baseline → (measurement method) → Target → Value

**Alternative framework:** SMART criteria — Specific, Measurable, Assignable, Realistic, Time-bound.

---

### Target Outcomes Must Have a Time Frame

- Measure each outcome **regularly** during the project and at the end of the time period
- When the time period ends, evaluate and decide whether to add new outcomes with new time periods
- New customer information may require **new target outcomes** → use "Stop the World" event to communicate the change

---

### Example: Issue Resolution Time

Team analyzes customer feedback → finds long resolution times hurt retention → uses MBPM to identify bottlenecks → creates target outcomes:

1. **Reduce average customer issue resolution time by ≥10 days**
2. **Do not increase operations team workload**
3. **Increase average customer satisfaction score by ≥0.3**

If only some outcomes are achieved → use Options practices to decide: pivot discovery activities, or pursue a different solution.

---

### Chaining with Other Practices

| Phase      | Practice                                          | Connection                                               |
| ---------- | ------------------------------------------------- | -------------------------------------------------------- |
| **Before** | MBPM                                              | Provides context for which outcomes to set               |
| **Before** | Impact Mapping                                    | Identifies personas, behaviors, and desired impacts      |
| **After**  | Priority Sliders                                  | Uses target outcomes as a basis for priority discussions |
| **After**  | How Might We / Lightning Decision Jam             | Designs outputs that drive the identified outcomes       |
| **After**  | Cohort Analysis / Split Testing / Feature Toggles | Measures impact of deliverables on target outcomes       |

---

## 4.3 Priority Sliders

### Core Concept

A practice that helps teams achieve **consensus on the relative priority of project characteristics** (often non-functional requirements like performance, security, and reusability). Produces a visual ranking that serves as an information radiator for autonomous decision-making.

> Priority Sliders produce a **relative ordering** — not an absolute list of tasks. The team can still make exceptions for high-impact issues in low-priority areas.

---

### Benefits

- Provides **clarification of motivations and desires** across stakeholder groups
- Increases **team autonomy** — teams can make trade-off decisions confidently without needing stakeholder approval each time
- New team members and stakeholders can quickly understand **why certain priorities are set**
- Reduces repetitive discussions about scope characteristics

---

### When to Use Priority Sliders

Signs the team needs this practice:

- Stakeholders ask prioritization questions the team cannot answer during demos
- Team lacks direct, consistent stakeholder access
- Team receives **conflicting signals** from leadership about scope characteristics
- Frequent repetitive conversations about scope trade-offs
- Scope priorities are constantly changing ("must be more performant", "must be security compliant", etc.)

---

### Common Characteristics to Prioritize (Starting List)

- Functional Completeness
- Performance
- Reliability / Stability
- Scalability
- Maintenance
- Market Viability / Product-Market Fit
- User Experience
- Reusability
- Security

> Best with **≤ 8 items** for manageable discussion.

---

### Facilitation Steps

1. Determine the list of characteristics relevant to the project (≤8 items)
2. List items in a column; **explain each item** so all participants share the same understanding
3. Draw a **horizontal scale** to the right of each item (divisions = number of items)
   - Left = lowest priority, Right = highest priority
4. Use **Silent Collaboration**: each participant privately writes their priority ranking (1 = lowest, N = highest)
5. Participants place stickers on the scale for each item
6. **Group discussion**: use clustering of stickers to identify relative priorities
   - Spread-out stickers = lack of shared understanding → facilitate discussion
   - Outlier sticker → ask that participant to explain their reasoning
7. Place a final sticky note on each item noting the **agreed priority**

---

### Facilitation Tips

- **Do NOT use numerical averaging** (adding up scores) to determine priorities — shared understanding requires discussion
- Ensure **dominant voices don't suppress** quieter participants
- If a cluster is very spread out, facilitate a definition discussion for that item
- Acknowledge that the list is **not final in all situations** — this helps teams reach consensus
- Priorities are **relative order of importance**, not a task sequence

---

### Example: Reading Priority Sliders Results

If the team sets: **Product/Market Fit > Functional Completeness > UX > ... > Security**

Then the team can autonomously decide to:

- **Prioritize a new feature over stability fixes** (Functional Completeness > Stability)
- **Use an unaudited third-party auth component** (Product fit > Security)
- **Spend more time on user research before adding features** (Product fit > Functional Completeness)

---

### Chaining with Other Practices

| Phase      | Practice                          | Connection                                                                                       |
| ---------- | --------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Before** | Target Outcomes                   | Sets the "what we're trying to achieve" before discussing "how we'll prioritize characteristics" |
| **Before** | Start at the End / News Headlines | Identifies concerns to prioritize to achieve success                                             |
| **After**  | Definition of Done                | Priority sliders inform quality criteria in the DoD                                              |
| **After**  | Backlog Refinement                | Guides scope priority discussions during story clarification                                     |
| **After**  | Increment Planning                | Ensures iteration goals align with stakeholder priorities                                        |

---

## Summary

| Practice             | Key Takeaway                                                                                                                                |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **MBPM**             | Map process steps with PT, LT, and %C&A metrics → identify the bottleneck → use Theory of Constraints to improve system throughput          |
| **Target Outcomes**  | Define measurable, time-bound outcomes (not outputs) → keep them publicly displayed → use them to guide all Mobius Loop decisions           |
| **Priority Sliders** | Reach consensus on relative priority of project characteristics → publicly display → use to make autonomous trade-off decisions confidently |

### How These Practices Connect

```
MBPM
  ↓ (reveals bottlenecks and process context)
Target Outcomes
  ↓ (defines what success looks like in measurable terms)
Priority Sliders
  ↓ (establishes HOW to make trade-off decisions autonomously)
Options Pivot & Delivery Loop
```

> **Discovery practices are not a one-time activity.** Revisit them as new information emerges, outcomes are achieved, or the team pivots direction.
