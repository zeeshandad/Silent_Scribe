# SilentScribe 🎙️✨

SilentScribe is a high-performance, **entirely offline** voice memo assistant. It leverages state-of-the-art edge AI models to transcribe and format your speech into polished writing, meeting minutes, or executive summaries directly on your device.

## Key Features

- **Privacy First**: All processing occurs locally. Your voice and text never leave your hardware.
- **Hardware Optimized**: Dynamic compute tiering that scales from legacy hardware to flagship SoCs with GPU acceleration.
- **Agentic Workflow**: Intelligent formatting using Qwen 2.5 (0.5B Instruct) calibrated for mobile memory constraints.
- **Stability Engineered**: Implements aggressive memory recovery, batch synchronization, and safety truncation to ensure 99.9% uptime on limited RAM devices.

## Documentation

For deep dives into our technical decisions and optimization strategies, see:
- [**Technical Architecture & Model Management**](docs/Architecture.md)

## Development

This project is built with Flutter and utilizes native C++ bindings for high-performance AI inference via `whisper_ggml` and `flutter_llama`.

### Getting Started

1.  **Environment**: Ensure you have Flutter 3.x installed and a physical Android or iOS device (emulators are not supported due to high RAM/Compute requirements).
2.  **Models**: On first launch, the app will download required models (~400MB total).
3.  **Permissions**: Microphone access is required for operation.

---
Built with intensity for the age of Edge AI.

