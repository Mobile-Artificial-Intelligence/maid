<div align="center">
  <picture>
    <img alt="logo" height="200px" src="https://github.com/MaidFoundation/maid/blob/main/.images/logo.png?raw=true">
  </picture>
</div>

# Maid - Mobile Artificial Intelligence Distribution
Maid is a cross-platform Flutter app for interfacing with GGUF / llama.cpp models locally, and with Ollama models remotely. The goal of Maid is to create a platform for AI that can be used freely on any device.

<div align="center">
  <table>
    <tr>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo1.jpg?raw=true" width="200"></td>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo2.jpg?raw=true" width="200"></td>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo3.jpg?raw=true" width="200"></td>
    </tr>
    <tr>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo4.jpg?raw=true" width="200"></td>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo5.jpg?raw=true" width="200"></td>
      <td><img src="https://github.com/MaidFoundation/maid/blob/main/.images/demo6.jpg?raw=true" width="200"></td>
    </tr>
  </table>
</div>

## Works on multiple devices :
Windows, Linux, Android.
[Releases page.](https://github.com/MaidFoundation/Maid/releases)
MacOS and IOS Releases not available at this time.

## Usage

### Local
To use this app in local mode, follow these steps:

1. Download the GGUF model from your chosen source.
2. Launch maid.
3. Navigate to the model settings by opening the sidebar and pressing the model button.
4. Click load model and select and your model file.
5. (Optionally) Set the preprompt and alias in the character settings.
6. Navigate back to the Home Page
7. Enter a prompt

### Remote
To use this app in remote mode, follow these steps:

1. From your computer pull your chosen model using ollama.
2. Setup Ollama for hosting on your local network as shown [here](https://github.com/jmorganca/ollama/blob/main/docs/faq.md).
3. Launch maid.
4. Toggle the remote switch in the navigation drawer.
5. Enter the IP address and port of your computer running ollama.
6. Set the model name to the name of the model you pulled in the model settings.
7. (Optionally) Set the preprompt and alias in the character settings.
8. Navigate back to the Home Page.
9. Enter a prompt.

## Help Wanted
- Write code comments
- Documentation
- Testing and Building on MacOS and IOS
- Spreading the word

## Testing
Android version tested on a Oneplus 10 Pro 11gb phone.
Also tested on Debian Linux, Windows 11.
Tested with llama 2 7B-Chat and llama 7B.

## Disclaimer
Please note that the llama.cpp models are owned and officially distributed by Meta. This app only serves as an environment for the model's 
capabilities and functionality. The developers of this app do not provide the LLaMA models and are not responsible for any issues related to their usage.
