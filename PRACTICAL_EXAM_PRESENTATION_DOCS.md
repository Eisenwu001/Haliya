# Practical Exam Presentation Guide
## Project: *Haliya: Mask of Sorrows*
**Target Presentation Duration:** 10 Minutes (Exact)  
**Game Engine:** Godot Engine 4.7 (Forward+ Renderer)  
**Platform:** PC (Keyboard & Mouse)  
**Internal Canvas:** 640 × 360 (Pixel-snapped integer scaling)

---

## 1. Presentation Time Management Matrix

| Time Window | Duration | Category / Section | Primary Focus | On-Screen Asset |
| :---: | :---: | :--- | :--- | :--- |
| **0:00 – 0:45** | 45 sec | **Opening & Overview** | Team greeting, title hook, agenda | Main Menu (idle night sky) |
| **0:45 – 2:00** | 1m 15s | **Category 2: Scope for This Showing** | Working features, partial items, skipped items, constraints | Scope Slide / Main Menu |
| **2:00 – 3:00** | 1m 00s | **Category 3: System Architecture** | 4 core modules, Godot Signal bus flow | Architecture Diagram Slide |
| **3:00 – 5:30** | 2m 30s | **Category 4: Implemented Features** | Continuous live gameplay demo (Menu $\rightarrow$ Combat $\rightarrow$ Pots $\rightarrow$ Boss) | Live Game Window |
| **5:30 – 6:45** | 1m 15s | **Category 5: In Progress** | Tutorial, Rice Fields life, Cavern boss arena, Weapon moves | In-Progress Slide / Game Paused |
| **6:45 – 7:45** | 1m 00s | **Category 6: Engineering Evidence** | Animation test cases, 24-step Level 3-1 QA checklist (TL reviewed) | QA Test Matrix Slide |
| **7:45 – 9:00** | 1m 15s | **Category 7: Challenges & Decisions** | Attack snapping, stamina balance, procedural audio, screen scaling | Technical Challenges Slide |
| **9:00 – 10:00** | 1m 00s | **Category 8: Limitations & Conclusion** | Save system, keyboard focus, shared animations, Q&A open | Summary Slide / Title Screen |

---

## 2. Team Role Distribution

* **Speaker (Presenter):** Holds the microphone, speaks at a calm, conversational pace (~125 words per minute), and keeps track of the stopwatch.
* **Driver (Player):** Operates the keyboard and mouse, executes moves cleanly, lets animations breathe, and follows the speaker's vocal cues.

---

## 3. Complete Category-by-Category Presentation Script

---

### [0:00 – 0:45] Opening & Introduction
* **Allocated Time:** 45 Seconds
* **Driver Cue:** Keep game open on the Main Menu. The title screen, crescent moon, and twilight forest parallax should drift in the background.

#### Speaker Script:
> "Good day, teachers, panel members, and classmates.
> 
> Today, we are proud to present our practical exam for our game: **Haliya: Mask of Sorrows**.
> 
> It is a 2D action-adventure platformer developed in Godot Engine, inspired by Philippine folklore and mythology.
> 
> For our 10-minute presentation today, we will walk you through Categories 2 to 8:
> * We will begin with our Project Scope and Architecture.
> * Then, we will take you through a continuous, live gameplay demonstration.
> * Finally, we will present our QA engineering evidence, technical challenges, and honest limitations.
> 
> To begin, let us examine **Category 2: The Scope for This Showing**."

---

### [0:45 – 2:00] Category 2: Scope for This Showing
* **Allocated Time:** 1 Minute 15 Seconds
* **Driver Cue:** Switch to Slide 1 (Scope Summary) or leave game on the Main Menu.

#### Speaker Script:
> "In Category 2, we define the exact boundaries of what is included in today's build.
> 
> **1. What is fully built and working right now:**  
> We have completed our core player movement, magnetic attack snapping, heavy hit-pause feedback, timed block and parry defense, our dynamic health and stamina HUD, breakable earthenware pots, and working boss encounters.
> 
> **2. What is partially built:**  
> Our tutorial house runs, but still needs guide prompts. Our Rice Fields stage is traversable, but needs more background life. And our underground cave boss arena is currently a simple room layout.
> 
> **3. What was deliberately not attempted yet, and why:**  
> * We skipped a complex RPG inventory menu because we prioritized responsive action-combat feel first.
> * We deliberately skipped online multiplayer. High-precision blocking and parrying require zero input lag, so we focused entirely on a solid single-player experience running at 60 frames per second.
> 
> **4. Our Project Constraints:**  
> * We locked our internal canvas to **640 by 360 pixels** using integer scaling so our pixel art remains razor-sharp on modern monitors.
> * We cleanly separated our 2D collision layers so weapons never glitch through terrain.
> * And we placed a strict cap of 100 stamina to prevent non-stop button mashing."

---

### [2:00 – 3:00] Category 3: System Architecture
* **Allocated Time:** 1 Minute 00 Seconds
* **Driver Cue:** Switch to Slide 2 (Architecture Diagram).

#### Speaker Script:
> "Now, looking under the hood, here is **Category 3: System Architecture**.
> 
> To keep our codebase clean and modular, our game is divided into four primary components:
> 
> 1. **The Game Manager (`main.gd`):** Acts as the central brain. It coordinates level transitions, camera tracking, and HUD state.
> 2. **The Player System (`player.gd`):** Manages user inputs, character physics, attack states, and stamina consumption.
> 3. **The Enemy and Boss System (`skeleton.gd`, `aswang.gd`, bosses):** Drives enemy AI, patrol states, detection, and combat patterns.
> 4. **World and Interactive Props (`level_builder.gd`, `palayok_pot.gd`):** Generates terrain platforms, hazards, and breakable pots that drop loot.
> 
> **How do these systems communicate?**  
> We use Godot's **Signal architecture**. Instead of scripts tightly depending on each other, they broadcast events.  
> For example: When the player takes damage, `player.gd` emits a signal. `main.gd` receives that signal and animates the health bar down. When an enemy is hit, it signals `procedural_audio.gd` to play a clash sound.  
> This separation prevents bugs and ensures one system can be edited without breaking another."

---

### [3:00 – 5:30] Category 4: Implemented Features (The Live Gameplay Demo)
* **Allocated Time:** 2 Minutes 30 Seconds Total
* **Format:** One continuous live playthrough on screen.

#### Part 4A: Main Menu & Controls Guide (30s)
* **Driver Cue:** Click 'CONTROLS' on the Main Menu, show the popup, close it, click 'STAGE SELECT', and launch Level 1-1.
> *"To see this architecture running in real-time, here is **Category 4: Our Live Gameplay Demonstration**.*  
> *We begin at our **Main Menu**. Clicking the 'Controls' button opens our guide window, clearly showing the key bindings: A and D to move, Space to jump, J to attack, K to block, and Escape to pause.*  
> *We also built an interactive **Stage Select** screen so our testing team and panel can load directly into any chapter. Let us enter Chapter 1: The Whispering Forest."*

#### Part 4B: Movement & Attack Snap (45s)
* **Driver Cue:** Inside the level, run right, jump onto a platform, crouch, then walk toward a skeleton. Swing attack from slightly away so the character steps into range.
> *"Inside the level, here is our **Movement and Combat Feel**.*  
> *Our character runs, jumps across platforms, and crouches under obstacles with responsive physics.*  
> *When we engage an enemy, notice our **Attack Snap** feature: even if we swing slightly out of distance, the character glides forward into range so the strike connects.*  
> *Furthermore, on every successful hit, there is a brief micro-pause. This hit-stop delivers a solid, crunchy physical feel to our combat."*

#### Part 4C: Timed Block & Health HUD (45s)
* **Driver Cue:** Wait for the skeleton to swing. Tap BLOCK right before the strike connects to parry (dizzy stars appear). Counter-attack. Then take one hit on purpose.
> *"Next is our **Defense and HUD System**.*  
> *Holding block defends against incoming strikes. If we time our block right before an attack hits, we execute a **Timed Parry**—deflecting the blow, stunning the enemy with yellow dizzy stars, and opening them up for a heavy counter-attack.*  
> *Now, look at our **Dynamic HUD** at the top: When we take damage, notice the trailing yellow ghost bar. It lingers for a moment so the player registers exactly how much health was lost.*  
> *Both attacking and blocking consume stamina from our green bar, forcing deliberate, calculated decisions."*

#### Part 4D: Breakable Pots & Boss Encounter (30s)
* **Driver Cue:** Walk to a clay pot. Hit it once (it cracks), hit it again (it breaks and drops a dumpling). Pick up the dumpling. Then walk into the boss area and block a boss attack.
> *"Throughout the stages, we have **Breakable Earthenware Pots**.*  
> *On hit one, the pot cracks and wobbles. On hit two, it shatters into clay chips, shakes the screen, and drops healing dumplings.*  
> *Finally, entering a boss area triggers an intense combat encounter. Bosses have distinct attack patterns like ground slams and shield blocks. The player must study their rhythm, block heavy strikes, and exploit their recovery openings."*

---

### [5:30 – 6:45] Category 5: In Progress
* **Allocated Time:** 1 Minute 15 Seconds
* **Driver Cue:** Pause the game or switch to Slide 3 (In-Progress Roadmap).

#### Speaker Script:
> "While our core gameplay loop is completely playable, here is **Category 5: What is Currently In Progress**:
> 
> 1. **The Tutorial House (Bahay Kubo):** We are assembling authentic bamboo and thatch artwork, along with on-screen button prompts to guide new players safely before they face lethal monsters.
> 2. **Stage 2 (Rice Fields):** We are adding wind shaders to make rice crops sway, adding wetland wildlife sounds like frogs and cicadas, and adding mud puddles that slow movement.
> 3. **Cavern Biomes and Boss Arenas:** We are upgrading the final underground lair from a flat room into an ancient sanctuary with glowing lapis crystals and dynamic elevation.
> 4. **Boss Fairness Tuning:** For our dragon boss, Bakunawa, we are adding falling ceiling dust warnings so players have time to react before rocks drop during earthquake attacks.
> 5. **Starter Weapon Differentiation:** We are creating distinct weapon animations—giving the Spear longer reach to poke safely, and the Dagger faster attack speed."

---

### [6:45 – 7:45] Category 6: Engineering Evidence & QA Test Cases
* **Allocated Time:** 1 Minute 00 Seconds
* **Driver Cue:** Switch to Slide 4 (QA Test Case Matrix).

#### Speaker Script:
> "Next is **Category 6: Engineering Evidence and QA Test Cases**.
> 
> To prove our game is technically sound, our team relies on two formal test case documents:
> 
> * **Test Document 1: Character and Weapon Visuals:**  
> We rigorously tested Haliya's idle animations with and without her mask across all three weapon variations—Fists, Kris, and Kampilan—to ensure no sprites flicker or glitch.
> 
> * **Test Document 2: Stage 3 Gameplay Verification (24 Steps):**  
> This is a comprehensive 24-step checklist testing our updated Rainy Forest build. It systematically verifies HUD health tracking, collision safety, enemy combat behaviors, rain particles, and audio triggers.
> 
> **Review Status:**  
> This test case underwent formal review and approval under our Team Lead, **Sir Ariel Aviles**, for Version 2.0. We are currently drafting Version 3.0 for our next feature release."

---

### [7:45 – 9:00] Category 7: Challenges & Engineering Decisions
* **Allocated Time:** 1 Minute 15 Seconds
* **Driver Cue:** Switch to Slide 5 (Technical Challenges & Decisions).

#### Speaker Script:
> "Moving to **Category 7: Challenges and Engineering Decisions**.
> 
> Building this project brought four significant technical hurdles, and here is how we engineered solutions for them:
> 
> 1. **The Challenge of Pixel-Level Whiffing:**  
> Attacks would miss by one or two pixels.  
> * **Our Decision:** We engineered magnetic attack snapping, gliding the player slightly forward into contact range.
> 
> 2. **The Challenge of Defense Balancing:**  
> Infinite blocking made combat boring, while overly strict timing made it frustrating.  
> * **Our Decision:** We tied blocking to a stamina cost and introduced a fair 0.20-second timed parry window that rewards precision with stun and counter-damage.
> 
> 3. **The Challenge of Audio Overhead:**  
> Storing large sound files bloated project size and slowed loading.  
> * **Our Decision:** We wrote a procedural synthesizer script in Godot that generates all sword whooshes, metal parry clanks, and thunder in RAM at runtime with zero external audio files.
> 
> 4. **The Challenge of Pixel Distortion:**  
> Different monitor resolutions caused blurry pixel art.  
> * **Our Decision:** We locked the canvas to 640 by 360 using nearest-neighbor integer scaling to ensure pixel-perfect clarity on any monitor."

---

### [9:00 – 10:00] Category 8: Honest Limitations & Final Conclusion
* **Allocated Time:** 1 Minute 00 Seconds
* **Driver Cue:** Switch to Slide 6 (Honest Limitations & Project Summary).

#### Speaker Script:
> "Finally, let us address **Category 8: Honest Limitations**.
> 
> To be completely transparent about our current build:
> 
> 1. **3-Slot Save System & Meta-Progression:** Run progress (stage, HP, armor, roguelite blessings, and play time) is automatically saved across 3 Chronicle Slots (`user://haliya_save_slot_1..3.json`), alongside persistent Moon Pearl currency and Ancestral Altar unlocks (`user://haliya_meta.cfg`). Stage Select is also available for instant testing.
> 2. **Keyboard-Focused Input:** Controls are currently tuned for keyboard and mouse. Full gamepad auto-mapping and vibration are scheduled for the next milestone.
> 3. **Shared Weapon Swings:** Different weapons currently share the same sword swing frames while unique animations are being drawn.
> 4. **Hardware Requirements:** Because of our Forward+ lighting, rain particles, and shaders, the game requires hardware supporting modern graphics.
> 
> ---
> 
> ### **Final Conclusion:**
> 
> In summary, our team has delivered a fully playable, responsive 2D action platformer with tight combat mechanics, strategic blocking, intelligent enemies, and verified QA test evidence.
> 
> We have a clear roadmap for our final release, and we are proud of what we have achieved so far.
> 
> Thank you very much, teachers and panel members. We are now open for your questions and suggestions!"

---

## 4. Q&A Defense Strategy for Practical Exam

| Possible Panel Question | Recommended Calm Answer |
| :--- | :--- |
| **"Why is the game only single-player?"** | *"High-precision combat with 0.20-second parries and hit-stop requires zero latency. Online netcode would compromise that responsiveness."* |
| **"Why doesn't the game save progress yet?"** | *"We focused our current sprint on gameplay physics and enemy AI. For testing purposes, our Stage Select allows direct jumping into any level."* |
| **"What engine and language did you use?"** | *"Godot Engine 4.7 using GDScript, taking advantage of Forward+ rendering and Jolt Physics."* |
| **"If an unexpected bug happens during demo:"** | *"That edge-case behavior is documented in our test logs and is slated for resolution in our upcoming Version 3.0 patch."* |
