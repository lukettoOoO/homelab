# Getting Started with DevOps Culture and Practices & Fostering Culture and Collaboration

> Red Hat TL250 — Chapters 1 & 2 | Open Practice Library

---

## Chapter 1 — Getting Started with DevOps Culture and Practices

### 1.1 The Open Practice Library (OPL)

A **community-driven collection of activities** for making incremental progress throughout the product delivery cycle. Activities are called **practices** because teams must routinely execute them to increase proficiency and develop new work habits.

#### What Makes a Practice

| Criterion  | Description                                             |
| ---------- | ------------------------------------------------------- |
| Empowering | Enables teams to work more effectively                  |
| Simple     | Prescribed behaviors are concise and actionable         |
| Generic    | Not specific to any particular scenario                 |
| Proven     | Tested and demonstrated value across a variety of teams |

> A practice is **not** a theoretical principle — it is a set of prescribed actions or behaviors.

---

### 1.2 The Mobius Loop

An **iterative process model** that organizes a continuous flow of activities to help teams define and achieve targeted outcomes.

Red Hat modified the upstream Mobius Loop by adding a **Foundation** layer — reflecting the open organization philosophy that open technology and open culture are complementary and inseparable.

```
         ┌─────────────┐
         │  Discovery  │ ◄──────────────────────────┐
         │    Loop     │                            │
         └──────┬──────┘                            │
                │                                   │
         ┌──────▼──────┐                            │
         │   Options   │                            │
         │    Pivot    │                            │
         └──────┬──────┘                            │
                │                                   │
         ┌──────▼──────┐                            │
         │  Delivery   │ ───────────────────────────┘
         │    Loop     │
         └─────────────┘
              ▲▲▲
     ══════ Foundation ══════
       (Culture + Technology)
```

#### Mobius Loop Components

| Component          | Side   | Focus                                     |
| ------------------ | ------ | ----------------------------------------- |
| **Discovery Loop** | Left   | Why → Who → Outcomes                      |
| **Options Pivot**  | Center | Generate & refine ideas; decide next step |
| **Delivery Loop**  | Right  | Deliver → Measure → Learn                 |
| **Foundation**     | Base   | Culture & Technology practices            |

---

### 1.3 Outcomes vs. Outputs

| Term        | Definition                                                             |
| ----------- | ---------------------------------------------------------------------- |
| **Output**  | The scoped work a team completes to drive an outcome (e.g., a feature) |
| **Outcome** | A change in human/team behavior that drives an impact                  |
| **Impact**  | A change to long-term business results                                 |

> The Mobius Loop emphasizes **outcomes over outputs**. Each output has a hypothesis predicting a measurable effect on a target outcome. If the outcome is not achieved, the team generates a new hypothesis.

---

### 1.4 Foundation Practices

Support all other practices in the library. Split into two elements:

- **Culture** — Creating, building, and nurturing effective team culture
  - _Example:_ **Network Mapping** — visual map of commonalities between team members to build trust
- **Technology** — Techniques to deliver quality products faster
  - _Example:_ **Pair Programming** — two members share one workstation to promote knowledge sharing

---

### 1.5 Discovery Loop Practices

Focus on three elements: **Why** (shared purpose) → **Who** (end user) → **Outcomes** (success criteria)

Teams use discovery practices to:

- Identify team/project purpose
- Clarify assumptions
- Conduct customer needs analysis
- Define measurable target outcomes

**Example Practices:**

- **Six Dimensions of Discovery** — explore and prioritize challenges across six dimensions
- **Empathy Mapping** — illustrate user attitudes and behaviors
- **Start at the End** — imagine project failure to enumerate key questions upfront

---

### 1.6 Options Pivot Practices

Help teams generate and refine ideas, and decide which to pursue first. For each option pursued, a **hypothesis** is developed predicting measurable changes to identified outcomes.

**Example Practices:**

- **Design of Experiments** — turn ideas into well-defined experiments for the Delivery Loop
- **How, Now, Wow Prioritization** — plot ideas on a 2D graph (difficulty vs. novelty); prioritize easy + novel ideas

---

### 1.7 Delivery Loop Practices

Focus on three elements: **Deliver** → **Measure** → **Learn**

**Example Practices:**

- **Story Kick-offs** — developers meet with product owner before starting a story
- **Split Testing** — compare versions of a product; one acts as null hypothesis baseline

---

### 1.8 Visualization of Work

A **cultural foundation practice** — radiating and visually representing all aspects of the team's activity to facilitate a transparent and open way of working.

#### Information Radiator

A physical or digital artifact that provides information at a glance. Displayed to tell the story of the team's progress and decision-making.

#### When to Use It

- Team lacks shared understanding of key decisions
- Onboarding/stakeholder updates are difficult and time-consuming
- Documentation exists but is not used effectively

#### Tips

- Use **line of sight** to position radiators effectively
- Use **color coding** across radiators for consistency
- Keep radiators **constantly visible** so they can be updated and spark conversations
- **Walk the Walls** technique: stakeholders inspect artifacts and start conversations with the team
- Store all digital radiators on a **single board** for combined analysis

#### OPL Practices That Produce Information Radiators

| Practice        | Loop Section  | Artifact                    |
| --------------- | ------------- | --------------------------- |
| Social Contract | Foundation    | Agreed team behaviors       |
| The Big Picture | Foundation    | Software delivery pipeline  |
| Target Outcomes | Discovery     | List of shared outcomes     |
| Value Slicing   | Options Pivot | Flexible release map        |
| Kanban          | Delivery      | Board visualizing work flow |

---

### 1.9 Facilitation Techniques

#### Three Facilitation Styles

| Style            | Description                               | When to Use                   |
| ---------------- | ----------------------------------------- | ----------------------------- |
| **Hierarchical** | Facilitator actively directs interactions | First time using a practice   |
| **Cooperative**  | Equal engagement, open problem-solving    | Red Hat's preferred style     |
| **Autonomous**   | Team operates without a facilitator       | Proficient, experienced teams |

> Red Hat promotes **cooperative facilitation** — teams that experience it develop cooperative behaviors and retain them even when autonomous.

#### Attributes of Cooperative Facilitation

1. **Maintaining psychological safety** — invite everyone to speak; respond equitably; apply the **"Yes, and…" rule** (accept ideas and build on them, never dismiss)
2. **Guiding toward the goal** — observe, create a mental model, use targeted question types
3. **Modeling continuous learning** — embrace "I don't know"; start with the desired outcome; close with a review of goals and takeaways

#### Facilitation Question Types

| Type            | Purpose                                                  | Example                                                     |
| --------------- | -------------------------------------------------------- | ----------------------------------------------------------- |
| **Challenging** | Explore alternatives while affirming the original idea   | "Is it possible an alternative works better for some? How?" |
| **Clarifying**  | Ensure a concept is clearly understood                   | "What did you mean when you said…?"                         |
| **Gauging**     | Elicit strong opinions to inform subsequent interactions | "How do you define DevOps?"                                 |
| **Leading**     | Guide participants to discover an answer                 | "How might your idea support the main idea?"                |
| **Probing**     | Focus on a specific aspect of a response                 | "Can you tell me why that idea is important?"               |
| **Reflective**  | Ask participants to reflect from their own perspective   | "Have you ever experienced something like that?"            |

#### Signs of Ineffective Group Dynamics

- Increased restlessness, boredom, fidgeting
- Lots of side conversations
- Unproductive arguments

**Response:** Refocus on objectives → identify the behavior with the group → consider a break → pivot or postpone if interest is lost.

---

### 1.10 Cooperative Facilitation Techniques

A typical sequence:

```
Parking Lot → Silent Collaboration → Affinity Mapping → Dot Voting → Confidence Voting
```

Each technique can also be used in isolation.

#### Parking Lot

Captures off-topic but valuable discussion items for later. Prevents scope creep while ensuring no idea is dismissed.

- Agree on a visible location (wall / shared doc)
- Any participant can flag an off-topic item
- Allocate time at the end to address items
- **Anti-pattern:** Not addressing items → contributors feel ignored

#### Silent Collaboration

Everyone silently writes one idea per sticky note. Prevents groupthink and ensures diverse ideas from all members.

- One idea per sticky note
- Anonymous sticky notes (evaluate content, not author)
- Time-boxed: 5–10 minutes
- All use the same color sticky notes for anonymity

#### Affinity Mapping

Sort, organize, and group numerous ideas to find patterns and similarities.

1. Gather participants around a large wall canvas
2. Each participant writes observations/ideas on sticky notes
3. Post notes; participants cluster similar ones together
4. Refine clusters collaboratively
5. Name each cluster with a category label

- Redundant sticky notes are valuable — they signal shared concerns
- Use Parking Lot for sticky notes that don't fit any cluster

#### Dot Voting

Reach consensus on the most important items from a list.

- Each participant receives a fixed number of dot stickers (e.g., 3)
- Place dots on preferred themes/groups (can concentrate all on one)
- Sort groups by total votes descending
- Team discusses which to act on based on votes + capacity

#### Confidence Voting

Understand a team's agreement or disagreement with a specific decision.

1. State the decision clearly
2. Count to three → all raise hand with fingers indicating confidence:
   - **0 (fist)** = no confidence
   - **1–4 fingers** = low to high confidence continuum
   - **5 fingers** = full confidence
3. If votes include 0–2 fingers, initiate discussion; ask low-confidence members what would change their vote

---

## Chapter 2 — Fostering Culture and Collaboration

### 2.1 Team Forming and Ice Breakers

**Team culture** is the product of behaviors and interactions from all team members — it must be created **intentionally and continuously**.

#### Themes That Support Team Forming

| Theme                          | Description                                                                    |
| ------------------------------ | ------------------------------------------------------------------------------ |
| **Psychological Safety**       | Team members feel safe to provide honest feedback and propose ideas            |
| **Celebrating Success**        | Incremental delivery → recognize small wins → boosts confidence and motivation |
| **Team Identity & Uniqueness** | Names, slogans, logos, theme songs help individuals identify with the team     |

> Experiments that don't achieve the intended outcome are **necessary and acceptable**. Focus on causes and effects, not personal responsibility.

#### Steps to Form a Team

1. Identify skills needed for the planned work (add members if new skills are required)
2. Create a unique team identity
3. Identify individual expertise, roles, and responsibilities — collaboratively
4. Create intentional bonding experiences
5. Establish a shared way of working (social contract, Scrum, Kanban, etc.)
6. Revisit and refine continuously using feedback; reform if team dynamics change significantly

#### Tuckman's Five Stages of Team Development

A model that helps identify team needs at every point in the project. Teams may not progress linearly — constant attention is needed to avoid regression or stagnation.

---

### 2.2 Team Forming Practices

#### Network Mapping

Identifies commonalities between team members to build bonds and safe collaboration spaces.

**Steps:**

1. Each participant places a sticky note with their name and personal details on a large surface
2. Participants pair up, converse to find a commonality, then join their sticky notes with a line describing it
3. Perform multiple rounds within the allocated time
4. Facilitate pairing using smaller groups if needed

- Not every pair needs to find a commonality

#### Team Sentiment

An ongoing information radiator tracking the mood of the team. Helps surface and address problems early.

- Choose a mechanism (e.g., mood containers with marbles)
- Team members update their mood at any time
- Radiator is visible to all
- If sentiment trends negative → start a team conversation

#### Start with Why

Each team member expresses their personal motivations. Used to find team purpose and link outcomes to individual motivations — increasing team buy-in.

#### Team Name and Logo

Builds collective identity and a sense of ownership.

- Each member writes name suggestions
- Use Silent Collaboration + Dot Voting to select
- Team finds or creates a logo together
- Output used for external communication and team rallying

---

### 2.3 Social Contract

A **simple yet highly effective** foundation practice that enables team autonomy and self-accountability. Created **by and for the team** — it codifies expected behaviors and provides a mechanism for radiating team norms to stakeholders.

#### Benefits

- Promotes **self-governing teams** and autonomy
- Develops **empathy** between team members during creation
- Provides a **reference artifact** for periodic reminders and accountability discussions

#### Signs a Social Contract Is Needed

- Team members have different expectations about acceptable behavior
- Too many 1:1 corrections — repetitive and inconsistent
- Decisions affecting the team are not shared openly (Information Refrigeration)
- Domination of conversations by a few; others not participating

#### Facilitation Steps

1. Provide open space to visualize the activity
2. Set context — explain what a social contract is and does
3. Use silent brainstorming to generate ideas
4. Consolidate similar ideas (use affinity mapping)
5. Gain consensus on behaviors to keep
6. **Commit** — everyone signs the contract

#### Optimization Tips

- Display the social contract **publicly**
- Reinforce that **no one is above the contract**
- Team members hold **each other** accountable
- **Revisit often** and update as needed
- Reference the contract, not the person, when addressing behavior

#### Practices Before a Social Contract

- **Icebreakers** — build initial comfort
- **Network Mapping** — build relationships and trust

#### Practices After a Social Contract

- **Target Outcomes** — define what the team strives to deliver
- **Start at the End** — identify assumptions to test early
- **Retrospectives** — reflect and potentially update the contract

---

### 2.4 Retrospectives

A retrospective provides the team the opportunity to **reflect, inspect, and adapt** their ways of working. Involves the **entire team** (stakeholders typically do not attend).

> A foundation practice — used throughout the Mobius Loop, not just at the end of an iteration.

#### Purpose & Benefits

- Drives **continuous improvement**
- Empowers the team to **adapt to change**
- Gives all team members an opportunity to speak
- Reduces gaps between deliverables and customer expectations

#### Common Retrospective Outcomes

- List of action items → treated as backlog items with capacity allocated
- Changes to the social contract, Definition of Ready, or Definition of Done
- Changes to automated testing or review processes
- Team bonding activities

#### When to Facilitate a Retrospective

- Team is not meeting deadlines
- Team member conflicts
- Difficulty communicating with the product owner
- Low-quality deliverables / too many bugs
- Unexpected scope changes

#### Facilitation Steps

1. Select a retrospective format and set up workspace
2. Allocate time for team input
3. Use affinity mapping to group similar inputs
4. Discuss results and collect action items

#### The Prime Directive

> _"Regardless of what we discover, we understand and truly believe that everyone did the best job he or she could, given what was known at the time, his or her skills and abilities, the resources available and the situation at hand."_
> — Norm Kerth

#### Common Retrospective Formats

| Format                               | Areas Covered                                                                   |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| **Plus / Minus / Interesting (PMI)** | Positive, negative, interesting activities                                      |
| **Quad**                             | What worked well / questions & uncertainties / what needs to change / new ideas |
| **Starfish**                         | Keep Doing / Less Of / More Of / Stop Doing / Start Doing                       |

#### Anti-Patterns

- Canceling the retrospective ("nothing to improve")
- Failing to identify actions and owners
- Turning it into a blame session
- Reusing the same format every time
- Not tracking improvement actions from previous retrospectives

#### Facilitation Tips

- Rotate retrospective formats to collect different feedback dimensions
- Add a social element (game, food) to celebrate team effort
- Consider changing the location (café, park) for a fresh perspective
- For remote: use a virtual whiteboard, cameras on, everyone can edit

#### Practices to Chain With Retrospectives

- **Before:** Showcase (demos output) → Parking Lot (collect concerns during iteration)
- **After:** Sprint Planning → Story Repointing → Social Contract update → Lightning Decision Jam (turn ideas into action items)

---

## Summary

| Concept                      | Key Takeaway                                                                      |
| ---------------------------- | --------------------------------------------------------------------------------- |
| **OPL**                      | Community-driven practices to drive incremental progress and transformation       |
| **Mobius Loop**              | Iterative model: Discovery → Options → Delivery, supported by Foundation          |
| **Outcomes > Outputs**       | Focus on behavioral changes that drive business results, not just deliverables    |
| **Visualization of Work**    | Information radiators drive transparency, conversations, and shared understanding |
| **Cooperative Facilitation** | All members contribute; "Yes, and…" rule; guide with questions, not answers       |
| **Team Forming**             | Intentional, continuous — psychological safety, celebration, identity             |
| **Social Contract**          | Team-created self-governance document; publicly displayed; revisited regularly    |
| **Retrospectives**           | Continuous improvement ritual; reflect → inspect → adapt; entire team involved    |
