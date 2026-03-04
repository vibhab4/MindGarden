# 🌿 MindGarden

MindGarden is a privacy-first, fully offline mental wellness app built in SwiftUI.  
It helps users reset, regulate, and take small positive actions using guided grounding techniques and gentle interaction design.

Built for the Swift Student Challenge 2026.

---

## ✨ Features

### 🫧 Grounding (5-4-3-2-1 Reset)
- Guided sensory reset flow
- Two modes:
  - Gentle Reset – classic grounding prompts
  - Explore Your Senses – playful prompt variations
- Step-based interaction (no overwhelming journaling)
- Fully offline

### 🌱 Growth System
- Completing sessions grows your digital plant
- Progress tracked locally using lightweight persistence
- Encourages consistency without pressure

### 🐥 Animated Guide Character
- Custom vector duck built entirely with SwiftUI Shape
- Spring-based animations (no external libraries)
- Provides supportive prompts throughout the experience

### 🎉 Completion Feedback
- Confetti animation on action completion
- Haptic feedback for reinforcement
- Subtle motion design for delight

---

## 🧠 Design Philosophy

MindGarden was designed around three principles:

1. Offline by Default  
   No accounts, no network dependency, no external APIs.

2. Low Cognitive Load  
   Minimal typing. Tap-based interactions. Clear progression.

3. Gentle Encouragement  
   Supportive tone. No scoring pressure. Growth through small steps.

---

## 🛠 Tech Stack

- Swift  
- SwiftUI  
- Swift Package Manager (.swiftpm)  
- @State & @AppStorage for state and local persistence  
- JSON encoding/decoding for lightweight storage  
- Custom SwiftUI Shape implementations  
- Spring and implicit animations  
- SF Symbols  

No external libraries were used.

---

## 🏗 Architecture Overview

- Modular SwiftUI view composition  
- State-driven navigation  
- Grounding flow implemented as a step-based state machine  
- Deterministic prompt randomization for Explore mode  
- Lightweight local persistence without databases  
- Strict package structure to meet 25MB submission constraints  

---

## 🔒 Privacy

All user data is stored locally on device.  
No analytics, no tracking, no network calls.

---

## 🚀 Running the Project

1. Open MindGarden.swiftpm in Swift Playgrounds (Mac).
2. Run the app.
3. Experience the full flow in under three minutes.

---

## 🌟 Future Improvements

- Expanded cognitive reframe module  
- Insight analytics dashboard  
- Additional guided reset modes  
- Adaptive progress system  

---

## 📬 Author

Vibha Bhavikatti  
Swift Student Challenge 2026

