import json

p = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\.system_generated\logs\transcript.jsonl"
with open(p, "r", encoding="utf-8") as f:
    for line in f:
        l = json.loads(line)
        idx = l.get("step_index", 0)
        if idx in (2531, 2532, 2533, 2534, 2535, 2536, 2537, 2538, 2539, 2540, 2541, 2542, 2543, 2544, 2545):
            tc = l.get("tool_calls")
            if tc:
                for c in tc:
                    print(f"{idx}: {c.get('name')} {str(c.get('args'))}")
