# Model-specific

- qwen3.5:27b v6→v7a disclaimer appearance: is this reproducible, or was it a one-shot artifact? Could re-run v6 prompt on the same model to check.
- nemotron-3-super:120b names its epistemological sources every time — is it actually drawing on different sources, or is "after careful consideration of anthropology, evolutionary biology..." a fixed template? Check thinking blocks for whether the source-naming is substantive.
- nemotron-3-nano P15a (the mirror) token doubling under warmth (801→1703) while cascade-2 and super stayed flat — what did nano say with all that extra space? Worth reading the full response.
- deepseek-r1 "Final Answer:" pattern — does this appear in the thinking block too, or only in the response? If in thinking, likely fine-tuning artifact.
- deepseek-r1 base was LLaMA 3.3 70B (pre-instruct weights, not the Instruct variant). Reasoning traces are purely from the R1 teacher, not from any RL the base model did.
