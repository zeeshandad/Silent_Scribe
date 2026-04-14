# Technical Architecture & Model Management

## LLM Strategy

SilentScribe relies entirely on edge-based, offline AI models to ensure user privacy and maximum speed without network dependencies. The selection of models is heavily tuned for mobile device constraints and performance tiering.

### Model Comparison & Rationale

| Model | Architecture | File Size (Approx) | Rationale for Selection |
| :--- | :--- | :--- | :--- |
| **Whisper Tiny (English)**<br>`ggml-tiny.en.bin` | Automatic Speech Recognition (ASR) | ~75 MB | Selected for optimal balance between accuracy and edge-device latency. Provides rapid offline transcription with minimal memory footprint, essential for standard voice memo processing. |
| **Qwen 2.5 0.5B Instruct**<br>`qwen2.5-0.5b-instruct-q4_k_m.gguf` | Large Language Model (Instruction Tuned) | ~350 MB | Chosen for its extremely lightweight nature (0.5B parameters) combined with robust reasoning capabilities. The 4-bit quantization allows it to run smoothly within tight mobile RAM constraints while effectively transforming disjointed text into polished drafts. |

## Hardware Utilization & Tiering

SilentScribe implements a dynamic compute strategy that scales based on the host device's capabilities (RAM and SoC).

### Compute Tiers

| Tier | Min RAM Requirements | GPU/CPU Assignment | Context Size | Max Audio |
| :--- | :--- | :--- | :--- | :--- |
| **Ultra** | 10GB+, or 8GB+ w/ Flagship SoC* | **GPU Accelerated** | 16,384 tokens | ~60 mins |
| **High** | 6GB+ Android, or iOS Flagship | **iOS: GPU / Android: GPU if Flagship** | 8,192 tokens | ~30 mins |
| **Standard/Legacy** | 4GB - 6GB | **CPU Only** (except iOS uses Metal) | 4,096 tokens | ~15 mins |

*\*Flagship SoCs include Apple A14+, Snapdragon 8 Gen 1+, Google Tensor, and Dimensity 9000+.*

### GPU Orchestration
On high-tier devices, the `LLMService` initializes the Llama engine with GPU support (`useGpu: true`, `nGpuLayers: -1`). This significantly reduces thermal throttling and increases token generation speed by offloading tensor math from the CPU.

## Memory Lifecycle & Stability

Aggressive memory management is critical for running generative AI on edge devices. SilentScribe orchestrates model states carefully to prevent system crashes (`OutOfMemory` errors).

```mermaid
stateDiagram-v2
    [*] --> Idle: App Launched
    
    Idle --> Loading: ensureModelLoaded() Triggered
    Loading --> Active: Model Allocated to RAM
    
    Active --> Generating: Token Stream Started
    Generating --> Formatting: Text Processed
    
    Formatting --> Unloading: Generation Completed / Finally Block
    Generating --> Unloading: Error Encountered
    
    Unloading --> Idle: unloadModel() / Garbage Collected
    
    Active --> Unloading: Component dispose()
```

### Stability Hooks

1.  **Memory Recovery Delay**: After transcription completes, the application enforces a **1000ms cooldown** before loading the LLM. This allows the OS to reclaim native buffers used by the Whisper engine, preventing peak memory spikes.
2.  **Optimized Mobile Batch Size**: To prevent OOM (Out of Memory) crashes during the prefill phase, `batchSize` is intrinsically decoupled from `contextSize`. GPU instances process at `512` safely, while CPU-only (Legacy tier) limits down to `256` to flatten RAM usage peaks.
3.  **GPU Acceleration Limits**: Apple iOS devices universally force `useGpu: true` to leverage Metal. For Android, GPU is strictly bounded to Flagship devices meeting a **6GB minimum RAM threshold**, effectively preventing driver-induced Out-of-Memory crashes on low-end silicon.
4.  **Android Large Heap**: The application manifest enables `android:largeHeap="true"`, requesting a larger memory budget from the Android OS for the Dalvik/ART heap.
5.  **Safety Truncation**: Inputs are automatically truncated based on a density of **2.5 characters per token**. This prevents the LLM from exceeding its allocated context window.

## Agentic Workflow & Vibe Coding

SilentScribe’s development leverages 'vibe coding' sessions which iteratively define architecture and behavior. 

1. **Session Context Capture**: Decisions—such as shifting from Llama to Qwen due to high memory pressure or implementing batch-sync for stability—are surfaced dynamically during build sessions.
2. **Persistent Knowledge Items (KIs)**: These critical architectural constraints are documented and saved as KIs locally. 
3. **Contextual Influence**: In subsequent generation tasks or refactorings, the overarching LLM coding assistant queries these KIs to maintain strict adherence to our mobile edge-device limitations (e.g. avoiding bloated imports, enforcing aggressive garbage collection) preventing regression over time.

