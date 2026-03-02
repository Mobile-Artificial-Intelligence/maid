<div align="center" id = "top">
  <img alt="logo" height="200px" src="https://raw.githubusercontent.com/Mobile-Artificial-Intelligence/maid/main/assets/graphics/logo.svg">
</div>

# Maid - Mobile Artificial Intelligence Distribution

<div align="center">
  
[![Build Android](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-android.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/build-android.yml)
[![Test](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/test.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/test.yml)
[![Code Quality](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/github-code-scanning/codeql)
[![Website](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/deploy.yml/badge.svg)](https://github.com/Mobile-Artificial-Intelligence/maid/actions/workflows/deploy.yml)

</div>

<div align="center">
<a href="https://github.com/Mobile-Artificial-Intelligence/maid/releases/latest">
<img
  src="https://raw.githubusercontent.com/NeoApplications/Neo-Backup/refs/heads/main/badge_github.png"
  alt="Get it on GitHub"
  width="210" 
/>
</a>
<a href='https://play.google.com/store/apps/details?id=com.danemadsen.maid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'>
<img 
  src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png'
  alt='Get it on Google Play'
  height="80"
/>
</a>
</div>

Maid is a free and open source application for interfacing with llama.cpp models locally, and with Anthropic, DeepSeek, Ollama, Mistral and OpenAI models remotely. Maid is built using React Native and is available for Android. The application is designed to be fast, efficient and user-friendly, making it easy for users to interact with their models on the go.

For text to speech functionality check out Maid's companion app [Maise](https://github.com/Mobile-Artificial-Intelligence/maise).

## Features

- **Local inference** — run GGUF models fully on-device via llama.cpp; no internet required
- **Remote providers** — connect to Anthropic, DeepSeek, Mistral, Ollama, and OpenAI with your own API key
- **One-tap model downloads** — browse and download curated Hugging Face models (Qwen, Phi, LFM, TinyLlama, and more) directly from the app
- **Bring your own model** — load any GGUF file from local storage
- **Conversation management** — create, rename, delete, export, and import chats as JSON
- **Customisable parameters** — tune temperature, top-p, top-k, context length, and other generation parameters per session
- **Custom system prompt** — set a global system prompt and assistant persona
- **Voice output** — pair with [Maise](https://github.com/Mobile-Artificial-Intelligence/maise) for text-to-speech
- **Optional account sync** — register / log in to back up settings and chat history via Supabase
- **Material You theming** — light and dark themes that follow your system preference
- **Fully open source** — MIT licensed, no telemetry, no ads

## Manual

The user manual is available from [releases](https://github.com/Mobile-Artificial-Intelligence/maid/releases/latest) in PDF format, or can be built from source using the instructions below.

## Cloning
To clone the repository, use the following command:

```bash
git clone https://github.com/Mobile-Artificial-Intelligence/maid.git
```

## Setup
Run the following command to install dependencies:

```bash
yarn install
```

## Testing
Run the test suite with:

```bash
yarn test
```

## Building
To build the project, use the following command:

```bash
yarn build-android
```

The output APK will be located in the `android/app/build/outputs/apk/release` directory.

## Star History

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=Mobile-Artificial-Intelligence/maid&type=Date&theme=dark" />
  <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=Mobile-Artificial-Intelligence/maid&type=Date" />
  <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=Mobile-Artificial-Intelligence/maid&type=Date" />
</picture>

## Disclaimer

Maid is distributed under the MIT licence and is provided without warranty of any kind, express or implied. Maid is not affiliated with Huggingface, Meta (Facebook), MistralAi, OpenAI, Google, Microsoft or any other company providing a model compatible with this application.

## Signing

### Signing Key Fingerprint

>MD5: `BE:AC:29:41:F5:41:D2:26:42:DD:D1:A3:85:21:E1:16`

>SHA-1: `48:F6:DC:73:09:CE:19:C6:A9:70:7E:A2:9A:B7:6F:42:2D:41:32:30`

>SHA-256: `83:5E:D2:2E:D8:95:C4:C2:72:D6:98:AA:6E:4E:48:DB:0B:4E:36:DC:CF:70:10:D5:DE:15:03:4A:C9:E1:B9:6F`

### Upload Key Fingerprint

>MD5: `C0:86:A0:F3:E8:E5:4D:46:60:8A:37:4E:DB:11:CC:C7`

>SHA-1: `77:FC:77:2B:21:5E:9F:36:31:79:09:DF:7D:F4:1F:CA:96:0C:39:17`

>SHA-256: `54:EE:B9:9F:14:38:D9:68:9B:C2:C6:7F:F9:DD:A3:E3:D8:28:D3:80:76:46:B7:24:46:71:9F:61:D9:63:E6:98`

## License

This project is licensed under the [MIT License](LICENSE).
