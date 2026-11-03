import json

with open(r'C:\Users\Lin\.gemini\antigravity\brain\d9eafb9d-1e01-4d36-bcb2-e9064cb02374\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        d = json.loads(line)
        if d.get('type') == 'PLANNER_RESPONSE' and d.get('tool_calls'):
            for tc in d['tool_calls']:
                cmd = str(tc.get('args', {}).get('CommandLine', ''))
                if 'tile_deck_platform' in cmd:
                    print('--- MATCH ---')
                    print(cmd)
