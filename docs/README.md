# Large Language Model API's

## Supported API's

|        Parameter        | Llama.cpp | Ollama | OpenAI | MistralAI | Gemini |
| ----------------------- | --------- | ------ | ------ | --------- | ------ |
| Name                    | Yes       | Yes    | Yes    | Yes       | Yes    |
| Temperature             | Yes       | Yes    | Yes    | Yes       | Yes    |
| Response Format         | No        | Yes    | Yes    | No        | No     |
| NKeep                   | No        | Yes    | No     | No        | No     |
| NPredict                | No        | Yes    | No     | No        | Yes    |
| TopK                    | Yes       | Yes    | No     | No        | Yes    |
| TopP                    | Yes       | Yes    | Yes    | Yes       | Yes    |
| MinP                    | Yes       | No     | No     | No        | No     |
| TfsZ                    | Yes       | Yes    | No     | No        | No     |
| TypicalP                | Yes       | Yes    | No     | No        | No     |
| Repeat Last N           | Yes       | Yes    | No     | No        | No     |
| Repeat Penalty          | Yes       | Yes    | No     | No        | No     |
| Presence Penalty        | Yes       | Yes    | Yes    | No        | No     |
| Frequency Penalty       | Yes       | Yes    | Yes    | No        | No     |
| Newline Penalty         | Yes       | Yes    | No     | No        | No     |
| Stop                    | No        | Yes    | Yes    | No        | No     |
| Mirostat                | Yes       | Yes    | No     | No        | No     |
| Mirostat Tau            | Yes       | Yes    | No     | No        | No     |
| Mirostat Eta            | Yes       | Yes    | No     | No        | No     |
| Numa                    | No        | Yes    | No     | No        | No     |
| NCtx                    | Yes       | Yes    | No     | No        | No     |
| NThread                 | Yes       | Yes    | No     | No        | No     |
| NBatch                  | Yes       | Yes    | No     | No        | No     |
| NGqa                    | No        | Yes    | No     | No        | No     |
| NGpu                    | No        | Yes    | No     | No        | No     |
| Main Gpu                | Yes       | Yes    | No     | No        | No     |
| Low Vram                | No        | Yes    | No     | No        | No     |
| F16 KV                  | No        | Yes    | No     | No        | No     |
| Logits All              | Yes       | Yes    | No     | No        | No     |
| Vocab Only              | Yes       | Yes    | No     | No        | No     |
| Use Mmap                | Yes       | Yes    | No     | No        | No     |
| Use Mlock               | Yes       | Yes    | No     | No        | No     |
| Embedding Only          | Yes       | Yes    | No     | No        | No     |
| Rope Frequency Base     | Yes       | Yes    | No     | No        | No     |
| Rope Frequency Scale    | Yes       | Yes    | No     | No        | No     |
| Max Tokens              | No        | No     | Yes    | Yes       | No     |
| N                       | No        | No     | Yes    | No        | No     |
| Logit Bias              | Yes       | No     | Yes    | No        | No     |
| Functions               | No        | No     | Yes    | No        | No     |
| Function Call           | No        | No     | Yes    | No        | No     |
| User                    | No        | No     | Yes    | No        | No     |
| Safe Mode               | No        | No     | No     | Yes       | No     |

## Llama.CPP

1. On the main page ensure the LlamaCPP option is selected in the API dropdown.
2. Press the menu button on the top right and select `Model Settings` option.
3. Press the `Load Model` button to load a `GGUF` model from local storage. *
4. Navigate back to the main page and initiate a conversation. 

* Alternatively you can press the `Huggingface` button to the left of the `Load Model` button to download a model directly from the internet.