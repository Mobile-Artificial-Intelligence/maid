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


## License

This project is licensed under the [MIT License](LICENSE).
