function ls
    set -l opts --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions -G
    eza $opts $argv
end

function la
    set -l opts --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions -G
    eza $opts -a $argv
end

function lf
    eza --color=always --icons=always -G $argv
end

function lt
    set -l opts --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions -G
    eza $opts --sort=modified $argv
end

function ld
    set -l opts --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions -G
    eza $opts --only-dirs $argv
end

function lh
    set -l opts --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions -G
    eza $opts -a $argv | grep '^\.'
end
