<div align="center">
  <picture>
    <img alt="logo" height="200px" src="assets/maid.png">
  </picture>
</div>

# Maid - Mobile Artificial Intelligence Distribution
Maid is an cross-platform free and open source application for interfacing with llama.cpp models locally, and with Ollama, Mistral, Google Gemini and OpenAI models remotely.

Maid supports sillytavern character cards to allow you to interact with all your favorite characters.

<div align="center">
  <table>
    <tr>
      <td><img src="media/demo1.jpg" width="200"></td>
      <td><img src="media/demo2.jpg" width="200"></td>
      <td><img src="media/demo3.jpg" width="200"></td>
    </tr>
    <tr>
      <td><img src="media/demo4.jpg" width="200"></td>
      <td><img src="media/demo5.jpg" width="200"></td>
      <td><img src="media/demo6.jpg" width="200"></td>
    </tr>
  </table>
  <table>
    <tr>
      <td><img src="media/demo7.png" width="600"></td>
      <td><img src="media/demo8.png" width="600"></td>
    </tr>
    <tr>
      <td><img src="media/demo9.png" width="600"></td>
      <td><img src="media/demo10.png" width="600"></td>
    </tr>
  </table>
</div>

## Cloning
Maid utilises git submodules extensively. To clone the repository, use the following command:

```bash
git clone --recursive https://github.com/Mobile-Artificial-Intelligence/maid.git
```

## Installing Build Dependencies
To install the dependencies on fedora based systems, use the following command:

```bash
sudo dnf install -y cmake ninja-build pkg-config gtk3-devel vulkan-devel
```

To install the bdependencies on debian based systems, use the following command:

```bash
sudo apt-get install -y cmake ninja-build pkg-config libgtk-3-dev libvulkan-dev
```

## Platform Support
Windows, Linux, Android.
[Releases page.](https://github.com/Mobile-Artificial-Intelligence/maid/releases)
MacOS and IOS Releases not available at this time.

## Supported API's

<div align="center">
  <table cellspacing="0" border="0">
  	<colgroup width="117"></colgroup>
  	<colgroup span="3" width="68"></colgroup>
  	<colgroup width="85"></colgroup>
  	<tr>
  		<td height="18" align="center"><b><font face="Liberation Serif">Parameter</font></b></td>
  		<td align="center"><b><font face="Liberation Serif">Local</font></b></td>
  		<td align="center"><b><font face="Liberation Serif">Ollama</font></b></td>
  		<td align="center"><b><font face="Liberation Serif">OpenAI</font></b></td>
  		<td align="center"><b><font face="Liberation Serif">MistralAI</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">model</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">seed</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">temperature</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">responseFormat</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numKeep</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numPredict</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">topK</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">topP</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">tfsZ</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">typicalP</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">repeatLastN</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">repeatPenalty</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">presencePenalty</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">frequencyPenalty</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">stop</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">mirostat</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">mirostatTau</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">mirostatEta</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">penalizeNewline</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numa</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numCtx</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numBatch</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numGqa</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numGpu</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">mainGpu</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">lowVram</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">f16KV</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">logitsAll</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">vocabOnly</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">useMmap</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">useMlock</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">embeddingOnly</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">ropeFrequencyBase</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">ropeFrequencyScale</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">numThread</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">maxTokens</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">n</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">logitBias</font></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">functions</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">functionCall</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">user</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  	</tr>
  	<tr>
  		<td height="18" align="center"><font face="Liberation Serif">safeMode</font></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#FF0000"><b><font face="Liberation Serif" color="#FFFFFF">N</font></b></td>
  		<td align="center" bgcolor="#00A933"><b><font face="Liberation Serif" color="#FFFFFF">Y</font></b></td>
  	</tr>
  </table>
</div>

## Help Wanted
- Write code comments
- Documentation
- Testing and Building on MacOS and IOS
- Spreading the word
- [Google Play Testing](https://github.com/Mobile-Artificial-Intelligence/maid/discussions/499)

## Special Thanks and Related Projects
- [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart)
- [Mobile-Artificial-Intelligence/maid_llm](https://github.com/Mobile-Artificial-Intelligence/maid_llm)

## Testing
Android version tested on a Oneplus 10 Pro 11gb phone.
Also tested on Fedora Linux, Windows 11.
Tested with calypso 3b, orcamini 3b, llama 2 7B-Chat, llama 7B and many more.
