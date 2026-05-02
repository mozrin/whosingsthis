# WhoSingsThis 🎵

**WhoSingsThis** is a premium, multi-platform music recognition application built with Flutter and Dart. It delivers a "Shazam-style" experience with a stunning glassmorphic UI, high-performance audio fingerprinting, and seamless Spotify integration.

---

## 📍 Project Structure

This is a monorepo containing the full stack infrastructure:

*   **[`/client`](./client)**: The core Flutter application. Supports **Linux**, **Android**, **iOS**, and **Web**.
*   **[`/server`](./server)**: High-performance Dart backend for handling user data and Spotify synchronization.
*   **[`/infrastructure`](./infrastructure)**: Dockerized PostgreSQL database and environment configurations.
*   **[`/WhoSingsThis.sh`](./WhoSingsThis.sh)**: Intelligent launcher script for Linux that verifies system dependencies before startup.

---

## 🗺️ The Roadmap

### Phase 1: Recognition Engine (Current) ✅
- [x] Microphone capture via PulseAudio/PipeWire.
- [x] Audio fingerprinting using Chromaprint (`fpcalc`).
- [x] Metadata retrieval via the AcoustID API.
- [x] Hardened error handling for missing system binaries.

### Phase 2: Premium UI/UX ✅
- [x] Glassmorphic mobile-first design.
- [x] Animated waveforms and ambient background glows.
- [x] Multi-platform responsive layout (9:16 aspect ratio enforcement on Desktop).

### Phase 3: Identity & Ecosystem (Upcoming) 🚀
- [ ] **Spotify OAuth2**: Direct integration to allow "Add to Playlist" functionality.
- [ ] **User Accounts**: Sync recognition history across Mobile and Desktop.
- [ ] **Native Fingerprinting**: Bundle `libchromaprint` as a Flutter FFI plugin to remove dependency on external `fpcalc` binaries for mobile builds.

---

## 🛠️ Setup & Installation

### Linux Dependencies
To use the recognition features on Linux, you must have audio utilities installed:
```bash
sudo apt-get update
sudo apt-get install pulseaudio-utils libchromaprint-tools
```

### Quick Launch
1.  Hit `Ctrl+Shift+B` in VS Code to see the **Developer Menu**.
2.  Run `./WhoSingsThis.sh` for a dependency-checked launch.

---

> [!NOTE]
> This project is designed for a high-end mobile experience. While it runs beautifully on Linux, the UI is optimized for a 9:16 portrait display to match the target mobile hardware.
