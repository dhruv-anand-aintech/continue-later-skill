# create-continuation-skill

Generate comprehensive **continuation.md** handoff documentation for fresh development sessions. Perfect for handing off projects to new team members, resuming long-running tasks, or documenting your work before context gets lost.

## The Problem

Long projects, multi-week tasks, or team handoffs require detailed context that's easy to lose:
- **What was just implemented?** (Exact changes, not vague summaries)
- **What's currently broken?** (Root causes matter)
- **What's the next step?** (In priority order)
- **What trapped us?** (Gotchas save hours)
- **How do we build & deploy?** (Exact commands, nothing assumed)

A simple `continuation.md` file solves this—and this tool generates it automatically.

## Installation

```bash
npm install -g create-continuation-skill
```

Or use it locally in a project:

```bash
npm install --save-dev create-continuation-skill
```

## Quick Start

### 1. Create a configuration file (`continuation-config.yaml`)

```yaml
projectName: MyAwesomeApp
workingDirectory: /Users/you/Code/my-awesome-app
projectDescription: |
  A cross-platform mobile app for tracking water usage.
  Built with React Native, PostgreSQL backend, and real-time analytics.

techStack:
  - React Native (iOS/Android)
  - PostgreSQL with TimescaleDB
  - Node.js / Express
  - Redux for state management
  - Jest + Detox for testing

currentState:
  working:
    - Login / authentication (OAuth2 flow)
    - Water usage dashboard
    - Daily email alerts
  broken:
    - Chart rendering on Android API 28 (due to WebView version)
    - Real-time sync drops after 10 minutes (likely socket timeout)
  inProgress:
    - Offline mode with sync queue
    - Dark mode UI refactor

recentChanges: |
  ### Fixed Android Chart Issue
  The chart library (react-native-svg) was breaking on API 28 because
  the WebView didn't support SVG transforms. Switched to a canvas-based
  library (react-native-canvas). All existing chart tests pass.

  ### Migrated to TimescaleDB
  Replaced vanilla PostgreSQL with TimescaleDB for time-series queries.
  Water usage queries are now 100x faster (3s → 30ms).
  Migration script created and tested on staging.

pendingTasks:
  - Test offline sync queue with poor network conditions (using Clumsy)
  - Add dark mode toggle to settings screen
  - Implement push notifications for alert escalation
  - Security audit (focus on OAuth2 token refresh logic)
  - Performance profiling on low-end Android devices

keyDecisions:
  - Used canvas-based charting instead of SVG to support older Android APIs
  - TimescaleDB over Postgres for time-series optimization (agreed with team on perf vs complexity tradeoff)
  - Real-time sync uses websockets with auto-reconnect + exponential backoff instead of long-polling

gotchas:
  - title: React Native WebView SVG Support
    description: SVG transforms aren't supported in WebView on Android API < 29
    solution: Switch to canvas-based charting library
    lesson: Test on min supported API level early; don't assume WebView features

  - title: Socket Timeout After 10 Minutes
    description: Real-time connection drops exactly every 10 minutes (suspiciously round number)
    solution: Added keepalive pings every 5 minutes; appears to be NAT/firewall timeout
    lesson: Use monitored health checks; timeouts are often environmental, not code bugs

  - title: TimescaleDB Binary Compatibility
    description: Docker image of TimescaleDB 2.8 doesn't work on M1 Macs (arm64v8 tag missing)
    solution: Build local image from source or use Postgres in dev, TimescaleDB only in prod
    lesson: Always test database version/architecture match; Docker's default tags can be misleading

buildInstructions: |
  ### Prerequisites
  ```bash
  # Install dependencies
  npm install
  gem install bundler  # for iOS pods
  
  # Set up environment
  cp .env.example .env
  # Edit .env with your API keys (get from 1password)
  ```

  ### Development Build
  ```bash
  # iOS
  npm run build:ios
  # Opens simulator automatically
  open ios/MyAwesomeApp.xcworkspace
  
  # Android
  npm run build:android
  adb install build/app.apk
  ```

  ### Run Tests
  ```bash
  npm test                    # Unit + integration tests
  detox build-framework-cache && detox test --configuration ios.sim.debug  # E2E
  ```

deployInstructions: |
  ### Deploy to Staging
  ```bash
  # Build APK + IPA
  npm run build:staging
  
  # Deploy to Firebase App Distribution
  npm run deploy:staging
  
  # Notify team
  npx changelog-release staging
  ```

  ### Deploy to Production
  ```bash
  # Requires approval from 2 reviewers
  npm run build:release
  
  # Apple TestFlight
  npm run deploy:testflight
  
  # Google Play Console (manual final approval required)
  npm run deploy:playstore
  ```
