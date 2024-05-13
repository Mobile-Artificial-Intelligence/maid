# Supported API's

|     Parameter     | Llama.cpp | Ollama | OpenAI | MistralAI | Gemini |
| ----------------- | --------- | ------ | ------ | --------- | ------ |
| Name              | Yes       | Yes    | Yes    | Yes       | Yes    |
| Temperature       | Yes       | Yes    | Yes    | Yes       | Yes    |
| Response Format   | No        | Yes    | Yes    | No        | No     |
| NKeep             | No        | Yes    | No     | No        | No     |
| NPredict          | No        | Yes    | No     | No        | No     |
| TopK              | Yes       | Yes    | No     | No        | No     |
| TopP              | Yes       | Yes    | Yes    | Yes       | Yes    |
| TfsZ              | Yes       | Yes    | No     | No        | No     |
| TypicalP          | Yes       | Yes    | No     | No        | No     |
| Repeat Last N     | Yes       | Yes    | No     | No        | No     |
| Repeat Penalty    | Yes       | Yes    | No     | No        | No     |
| Presence Penalty  | Yes       | Yes    | Yes    | No        | No     |
| Frequency Penalty | Yes       | Yes    | Yes    | No        | No     |
| Newline Penalty   | Yes       | Yes    | No     | No        | No     |
| Stop              | No        | Yes    | Yes    | No        | No     |
| Mirostat          | Yes       | Yes    | No     | No        | No     |
| Mirostat Tau      | Yes       | Yes    | No     | No        | No     |
| Mirostat Eta      | Yes       | Yes    | No     | No        | No     |

<div align="center">
  <table cellspacing="0" border="0">
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
