function __box_table --description 'Every Mac command for the homelab boxes, one line each (read by box and the completions)'
    # Fields (tab-separated): host, command, what it runs, usage, description, choices for the first
    # argument as word=description;... Add a command here and both box and Tab pick it up.
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        devbox update devbox-update '[orca|all|apt|cli|openbot]' 'Update now (default orca)' \
        'orca=Orca server .deb (default);all=everything, like the 04:45 nightly run;apt=OS packages;cli=Claude, Codex, T3 Code;openbot=OpenBot + Obsidian images, Node' \
        devbox clone devbox-clone '<git-url> [name]' 'Clone a repo into ~/code and add it to Orca' '' \
        devbox status 'ssh -t devbox devbox-status' '' 'One-screen overview: memory, services, OpenBot' '' \
        devbox t3-pair 't3-pair devbox' '[label]' 'One-time T3 Code pairing link + QR (link copied)' '' \
        devbox openbot-env 'openbot-env devbox' '[list|set KEY|unset KEY|apply]' 'Env vars for OpenBot agents (values never shown)' \
        'list=names of the variables;set=set KEY from a hidden prompt;unset=remove KEY;apply=restart OpenBot to load them' \
        devbox openbot-edit 'openbot-edit devbox' '<path under /data>' 'Edit a file an OpenBot agent asked for' '' \
        devbox ssh 'ssh devbox' '[command]' 'Shell on the devbox (user dan)' '' \
        vps update vps-update '[orca|all|cli|openbot]' 'Update now (default orca)' \
        'orca=Orca server .deb (default);all=everything, like the 04:45 nightly run;cli=Claude, Codex, T3 Code;openbot=OpenBot image, t3-tls Caddy, Node' \
        vps clone vps-clone '<git-url> [name]' 'Clone a repo into ~agent/code and add it to Orca' '' \
        vps status 'ssh -t vps vps-status' '' 'One-screen overview: memory, services, OpenBot' '' \
        vps t3-pair 't3-pair vps' '[label]' 'One-time T3 Code pairing link + QR (link copied)' '' \
        vps openbot-env 'openbot-env vps' '[list|set KEY|unset KEY|apply]' 'Env vars for OpenBot agents (values never shown)' \
        'list=names of the variables;set=set KEY from a hidden prompt;unset=remove KEY;apply=restart OpenBot to load them' \
        vps openbot-edit 'openbot-edit vps' '<path under /data>' 'Edit a file an OpenBot agent asked for' '' \
        vps ssh 'ssh vps' '[command]' 'Shell on the VPS (user dan; sudo -iu agent for the agents)' '' \
        forge update forge-update '[all|cts|check|host|<ctid>...]' 'Container and host maintenance (default all)' \
        'all=every CT + host report, Telegram, Kuma (default);cts=every CT, no report;check=list pending updates, change nothing;host=upgrade Proxmox itself (asks first)' \
        forge gaming forge-gaming '[status|on|off]' 'Bazzite gaming VM' \
        'status=is it running, what is paused;on=make room and start Bazzite;off=shut Bazzite down, give memory back' \
        forge ci forge-ci '[status|route|pause|resume]' 'GitHub Actions runners on forge' \
        'status=slots and jobs;route=where jobs run now (forge or GitHub);pause=stop taking jobs;resume=take jobs again' \
        forge ssh 'ssh forge' '[command]' 'Root shell on the Proxmox host (home network only)' ''
end
