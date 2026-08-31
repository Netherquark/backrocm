while true; do
    clear

    pid=$(pgrep -n -f 'clang-19 -cc1')

    if [ -n "$pid" ]; then
        cmd=$(ps -p "$pid" -o cmd=)

        echo "=== ACTIVE COMPILATION ==="
        echo

        ps -p "$pid" -o \
            "pid=PID,ppid=PPID,stat=STATE,etime=ELAPSED,%cpu=CPU,%mem=MEM"

        echo
        echo "Source:"
        echo "$cmd" |
            grep -oE -- '-main-file-name [^ ]+' |
            head -1

        echo
        echo "GPU architecture:"
        echo "$cmd" |
            grep -oE -- '-target-cpu gfx[^ ]+' |
            head -1

        echo
        echo "Output:"
        echo "$cmd" |
            grep -oE -- '-o /tmp/[^ ]+' |
            head -1

    else
        echo "No active clang-19 compilation."
    fi

    sleep 1
done