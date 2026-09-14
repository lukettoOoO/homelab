# Running AI Models Locally with Podman AI Lab

## 1. Choosing the AI Model

### Model Selection Criteria
Selecting an AI model for an application involves evaluating:
* **Use Case**: Specifies the targeted task (e.g., text generation via LLMs vs. object recognition via CNNs).
* **Licensing & Provenance**: Adherence to model and dataset licensing terms (open weights vs. proprietary restrictions).
* **Fine-Tuning Requirements**: Adapting base models to domain-specific data requires significant GPU hardware and time.
* **Inference Costs**: Running local inference consumes fewer compute resources than full model training.

### Use Case Categories
* **Natural Language Processing (NLP)**: Text generation (chatbots, assistance), text classification (sentiment/spam), Named Entity Recognition (NER), translation.
* **Computer Vision**: Image classification, object detection, image segmentation.
* **Audio Processing**: Speech-to-text (e.g., Whisper), text-to-speech, audio classification.
* **Multimodal**: Processes combined inputs (e.g., text + images or time-series data).

### Large Language Model (LLM) Types
* **Base LLMs**: Pretrained on vast corpora; understand text generation but require fine-tuning for specific tasks.
* **Instruct LLMs**: Fine-tuned to follow specific instructions or task prompts (e.g., code generation).
* **Chat LLMs**: Fine-tuned for multi-turn conversational context and dialogue flow.
* **Mixture of Experts (MoE)**: Architecture combining specialized sub-models routed dynamically by an internal router.

### Model Size & Quantization
* **Parameter Count & Precision**: Model size depends on parameter count (e.g., 7B = 7 billion parameters) and floating-point precision (FP32 or FP16).
* **Quantization**: Compresses models by reducing weight/activation precision to lower bit-width data types (e.g., 4-bit `Q4_K_M`).
  * *Benefits*: Dramatically reduces RAM/disk footprint (e.g., 7B model reduced from ~30 GB to ~4.1 GB) and improves inference speed on consumer hardware with minimal accuracy loss.
  * *Methods*: Post-Training Quantization (PTQ -> GGUF format) and Quantization-Aware Training (QAT -> QLoRA).

---

## 2. Running AI Models Locally via Podman AI Lab

### Architecture & Runtime Components
* **Podman AI Lab**: Extension for Podman Desktop that enables building, running, and testing containerized AI models locally on non-accelerated developer workstations.
* **`llama.cpp` Backend**: Optimized C/C++ inference runtime for executing GGUF-quantized models across CPUs and GPUs.
* **GGUF Format**: Encapsulates model weights and metadata into a single file.
  * *File Naming Pattern*: `BaseName-Size-FineTune-Version-Encoding-Type.gguf`  
    *Example*: `granite-7b-lab-Q4_K_M.gguf` (Granite base, 7B parameters, LAB fine-tuned, 4-bit `Q4_K_M` encoding).

### Core Components in Podman AI Lab
* **Catalog**: Curated library of open-source models downloadable directly from Hugging Face.
* **Model Services**: Containers (`ghcr.io/containers/llamacpp_python`) running an inference server mounting the local GGUF file and exposing an **OpenAI-compatible HTTP API** (e.g., `/v1/chat/completions`).
* **Playgrounds**: Integrated chat UI inside Podman Desktop to test models, system prompts, and hyperparameters.

### Resource Usage Characteristics
* **Idle State**: Minimal CPU usage; model stays loaded in RAM (~1.2 GB RAM for a 4-bit 7B GGUF model).
* **Active Inference**: Multi-core CPU utilization spikes during text generation while RAM footprint remains stable.

---

## 3. Consuming Local AI Models from Client Applications

### Prompt Engineering Techniques
Prompt engineering adapts an LLM's output behavior through structured text instructions:
* **System Prompt / Message**: Global instructions configured at the start of a session establishing rules, context, and output format.
* **Persona Pattern**: Assigns a specific role to the model (e.g., *"You are a database assistant that generates SQL select statements exclusively"*).
* **Zero-Shot vs. Few-Shot**: Providing zero vs. one or more explicit input-output examples in the prompt to guide complex formatting (e.g., JSON structure).
* **Chain of Thought (CoT)**: Instructs the model to output explicit step-by-step reasoning before delivering the final answer.

### Inference Hyperparameters
* **Temperature**: Controls output randomness/creativity (`0.0` = deterministic & focused; `1.0` = creative & diverse).
* **Top-p (Nucleus Sampling)**: Restricts token selection to the top cumulative probability threshold (e.g., `0.1` = top 10% candidate tokens).
* **Max Tokens**: Restricts the maximum number of tokens generated in the response.

### LangChain Integration Architecture
LangChain is an open-source framework for building LLM-driven applications:
* **Messages**: Encapsulates dialogue turns (`SystemMessage`, `HumanMessage`, `AIMessage` or tuples `("system", "...")`).
* **Prompt Templates**: `ChatPromptTemplate` defines reusable prompts with dynamic template variables (e.g., `{language}`, `{user_input}`).
* **Model Abstraction (`ChatOpenAI`)**: Consumes Podman AI Lab inference endpoints using standard OpenAI API wrappers:
  ```python
  from langchain_openai import ChatOpenAI

  llm = ChatOpenAI(
      base_url="http://localhost:PORT/v1",
      api_key="not-needed",
      temperature=0.1
  )
  ```
* **Output Parsers**: Transforms raw model text responses into structured formats (`JsonOutputParser`, custom string parsers).
* **LangChain Expression Language (LCEL)**: Chains components sequentially using pipe operators (`|`):
  ```python
  chain = prompt_template | llm | output_parser
  response = chain.invoke({"variable": "value"})
  ```

---

## 4. Podman AI Lab Recipes with Podman Desktop

### AI Application Complexity & Architecture
* **Traditional ML Libraries vs. Service-Based AI**: Classic machine learning models (e.g., Scikit-learn) import directly into application code. Complex models (LLMs, audio/vision models) run as standalone containerized microservices to allow independent resource allocation and scaling over HTTP/REST APIs.

### Core Concepts: Recipes vs. AI Apps
* **Recipe**: A declarative manifest/template that specifies how to build and execute all multi-container components of an AI application on a local workstation. Serves as an application blueprint.
* **AI App**: A running instance of an application generated from a recipe. A single recipe can instantiate multiple independent AI App instances.

### Running Components of an AI App
When a recipe starts, Podman AI Lab deploys three types of containerized components:
1. **Model Service Container**: Dedicated container running the inference engine (e.g., `ghcr.io/containers/llamacpp_python` for GGUF LLMs) exposing an OpenAI-compatible API. To optimize system resources, model service containers run standalone outside the application pod and can be reused across multiple AI Apps.
2. **AI Application Containers**: Containers hosting application business logic, APIs, and web interfaces (e.g., Streamlit, Node.js, Python backends).
3. **Supporting Containers**: Infrastructure containers required by specific patterns, such as vector databases (e.g., Pgvector, Chroma) for Retrieval-Augmented Generation (RAG).

### Pod Architecture & Podman Pause
* Application containers and supporting containers are grouped together inside a local **Podman Pod**.
* The pod includes a standard `podman-pause` infrastructure container used by Podman to manage networking and shared namespaces across containers in the pod.

### Lifecycle Management of AI Apps
* **Starting**: Select recipe from AI Lab Catalog -> select recommended model -> click Start Recipe (Podman AI Lab builds application containers, creates pod, connects model service).
* **Accessing**: Launch web application directly from the Running section via the web browser button.
* **Inspecting**: Monitor container logs, CPU/RAM usage, and active pods via Podman Desktop or CLI (`podman ps`, `podman pod ls`, `podman stats`).
* **Stopping & Deleting**: Stop AI App from `AI APPS -> Running` menu; delete operation removes associated pods and application containers while preserving reusable model services.
