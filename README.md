# Demo App for llama.cpp Model
This app is a demo of the llama.cpp model that tries to recreate an offline chatbot, working similar to OpenAI's ChatGPT. The source code for this app is available on GitHub.

# Works on multiple devices :
Windows, mac and android !
[Releases page](https://github.com/Bip-Rep/sherpa/releases)


The app was developed using Flutter and is built upon ggerganov/llama.cpp, recompiled to work on mobiles.

The app will prompt you for a model file, which you need to provide. This must be a GGML model is compatible with llama.cpp as of June 30th 2022. Models from previous versions of Sherpa (which used an older version of llama.cpp) may no longer be compatible until conversion. The llama.cpp repository provides tools to convert ggml models to the latest format, as well as to produce ggml models from the original datasets.

You can experiment with [Orca Mini 3B](https://huggingface.co/TheBloke/orca_mini_3B-GGML). These models (e.g. orca-mini-3b.ggmlv3.q4_0.bin from June 24 2023) are directly compatible with this version of Sherpa.

Additionally, you can fine-tune the ouput with preprompts to improve its performance.

## Working demo
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/jdw7oABjTeQ/0.jpg)](https://www.youtube.com/watch?v=jdw7oABjTeQ)
Click on the image to view the video on YouTube.
It shows a OnePlus 7 with 8Gb running Sherpa without speed up.

## Usage
To use this app, follow these steps:

1. Download the GGML model from your chosen source.
2. Rename the downloaded file to `ggml-model.bin`.
3. Place the file in your device's download folder.
4. Run the app on your mobile device.

## Disclaimer
Please note that the llama.cpp models are owned and officially distributed by Meta. This app only serves as a demo for the model's capabilities and functionality. The developers of this app do not provide the LLaMA models and are not responsible for any issues related to their usage.



