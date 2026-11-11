#!/usr/bin/env python3
"""Token audit of Claude Code transcripts. Usage: token-audit.py [days=14] [top=15]
Reads ~/.claude/projects/**/*.jsonl (main sessions + subagents); prints totals,
model split, per-project share and the heaviest sessions."""
import json, sys, time, glob, os
from collections import defaultdict
days = int(sys.argv[1]) if len(sys.argv) > 1 else 14
top = int(sys.argv[2]) if len(sys.argv) > 2 else 15
cut = time.time() - days * 86400
root = os.path.expanduser("~/.claude/projects")
S = {}
for f in glob.glob(f"{root}/**/*.jsonl", recursive=True):
    if os.path.getmtime(f) < cut: continue
    sub = "/subagents/" in f
    s = dict(file=f, sub=sub, proj=None, inp=0, out=0, turns=0, peak=0, compacts=0,
             models=defaultdict(int), imgreads=defaultdict(int))
    try:
        for line in open(f, errors="ignore"):
            try: e = json.loads(line)
            except Exception: continue
            s["proj"] = s["proj"] or e.get("cwd")
            if e.get("type") == "system" and e.get("subtype") == "compact_boundary": s["compacts"] += 1
            m = e.get("message") or {}
            u = m.get("usage") if isinstance(m, dict) else None
            if e.get("type") == "assistant" and u:
                ctx = u.get("input_tokens",0)+u.get("cache_read_input_tokens",0)+u.get("cache_creation_input_tokens",0)
                s["inp"] += ctx; s["out"] += u.get("output_tokens",0); s["turns"] += 1
                s["peak"] = max(s["peak"], ctx); s["models"][m.get("model","?")] += ctx
                for c in m.get("content") or []:
                    if isinstance(c, dict) and c.get("type")=="tool_use" and c.get("name")=="Read":
                        p = str((c.get("input") or {}).get("file_path",""))
                        if p.lower().endswith((".png",".jpg",".jpeg")): s["imgreads"][p] += 1
    except OSError: continue
    if s["turns"]: S[f] = s
def M(n): return f"{n/1e6:,.1f}M"
tot = sum(s["inp"] for s in S.values()) or 1
print(f"Last {days} days: {sum(not s['sub'] for s in S.values())} main sessions, "
      f"{sum(s['sub'] for s in S.values())} subagent transcripts, input {M(tot)}, "
      f"output {M(sum(s['out'] for s in S.values()))}")
mod = defaultdict(int)
for s in S.values():
    for k,v in s["models"].items(): mod[k]+=v
print("\nInput by model:"); [print(f"  {k:<28}{M(v):>10} {100*v/tot:5.1f}%") for k,v in sorted(mod.items(), key=lambda x:-x[1])]
pr = defaultdict(int)
for s in S.values(): pr[os.path.basename((s["proj"] or "?").rstrip("/"))]+=s["inp"]
print("\nInput by project dir (top 10):"); [print(f"  {k:<28}{M(v):>10} {100*v/tot:5.1f}%") for k,v in sorted(pr.items(), key=lambda x:-x[1])[:10]]
big = [s for s in S.values() if s["peak"]>200_000]
print(f"\nSessions peaking >200k: {len(big)} ({100*sum(s['inp'] for s in big)/tot:.0f}% of input); compactions total {sum(s['compacts'] for s in S.values())}")
print(f"\nHeaviest {top}:")
print(f"  {'input':>9} {'turns':>6} {'peak':>6} {'cmp':>3} {'img':>4}  model / project / file")
for s in sorted(S.values(), key=lambda s:-s["inp"])[:top]:
    m = max(s["models"].items(), key=lambda x:x[1])[0].replace("claude-","")
    img = max(s["imgreads"].values(), default=0)
    print(f"  {M(s['inp']):>9} {s['turns']:>6} {s['peak']//1000:>5}k {s['compacts']:>3} {img:>4}  "
          f"{m} / {os.path.basename((s['proj'] or '?').rstrip('/'))}{' (sub)' if s['sub'] else ''} / {os.path.basename(s['file'])[:12]}")
print("\nimg = most times a single screenshot was re-read in that session.")
