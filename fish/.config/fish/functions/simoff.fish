function simoff --description 'Shut down every iOS simulator and Android emulator to free RAM'
    set -l did 0

    if command -q xcrun
        set -l booted (xcrun simctl list devices booted 2>/dev/null | string match -r '^\s+\S.*\(Booted\)')
        if test (count $booted) -gt 0
            xcrun simctl shutdown all 2>/dev/null
            echo "iOS: shut down "(count $booted)" simulator(s)"
            set did 1
        end
    end
    if pgrep -xq Simulator
        osascript -e 'quit app "Simulator"' 2>/dev/null
        echo "iOS: quit Simulator.app"
        set did 1
    end

    # Only touch adb when an emulator is actually running, so we don't start its server for nothing.
    if pgrep -fq 'qemu-system-aarch64'
        set -l emus
        if command -q adb
            set emus (adb devices 2>/dev/null | string match -r '^emulator-\d+' )
            for e in $emus
                adb -s $e emu kill >/dev/null 2>&1
            end
        end
        sleep 3
        if pgrep -fq 'qemu-system-aarch64'
            pkill -f 'qemu-system-aarch64'
        end
        echo "Android: stopped emulator(s)"
        set did 1
    end

    test $did -eq 0; and echo "Nothing running."
    return 0
end
