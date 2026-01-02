![BRACU Voting Machine Banner](./voting_machine.png)

# 🗳️ BRACU Voting Machine

[![Assembly](https://img.shields.io/badge/Language-Assembly%208086-blue.svg)](https://en.wikipedia.org/wiki/Assembly_language)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Target](https://img.shields.io/badge/Target-EMU8086%20%2F%20DOSBox-orange.svg)](#)

A robust and secure **8086 Assembly-based Voting System** designed for BRAC University. This project implements a full-featured digital ballot box with multi-level authentication, candidate management, and real-time result processing.

---

## ✨ Key Features

### 🛡️ Secure Authentication
- **Admin Login**: Restricted access to system management with a secure password and failed attempt locking.
- **Voter Login**: Unique Voter IDs and passwords for all registered voters ensure one-person-one-vote integrity.
- **System Lock**: Automatically locks after too many failed login attempts to prevent brute-force attacks.

### 📋 Candidate Management (Admin)
- **Add Candidate**: Dynamically add candidates to the election (max 3).
- **Edit/Remove**: Full CRUD operations to manage the ballot list.
- **Search**: Quick search functionality to find specific candidates.

### 🗳️ Voting Logic
- **Prevention of Double Voting**: Once a voter casts their ballot, their ID is flagged, and they cannot vote again.
- **Immediate Win Condition**: Built-in logic to end the election instantly if a candidate reaches a majority threshold (3 votes).
- **Tie Detection**: Intelligent tie detection that prompts admin intervention if results are inconclusive.

---

## 🚀 Getting Started

### Prerequisites
To run this project, you need an 8086 emulator. We recommend:
- **EMU8086** (Windows)
- **DOSBox** (Cross-platform)

### Installation & Execution
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/bracu-voting-machine.git
   ```
2. Open `10_08_22201027_22299402_23301702.asm` in **EMU8086**.
3. Click **Emulate** and then **Run**.

---

## 🛠️ Internal Mechanics

The system utilizes low-level interrupt handling and memory management:
- **INT 10h**: Used for screen clearing and cursor positioning to provide a clean UI.
- **INT 21h**: Extensively used for string input/output and keyboard events.
- **Direct Memory Addressing**: Candidate and voter data are stored in structured buffers within the `.DATA` segment for efficient retrieval.

---

## 👥 Meet the Team

| Name | Role |
| :--- | :--- |
| **Ahsan Habib** | Developer |
| **Imran Ali** | Developer |
| **Nusaiba Sawda** | Developer |

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
<p align="center">
  Developed with ❤️ for CSE341 - Microprocessors at BRAC University
</p>

