{
  runCommand,
  gowin-eda-education,
}:

{
  gowin-eda-education-launch = runCommand "gowin-eda-education-launch-check" { } ''
    set -euo pipefail

    fail() {
      echo "FAIL: $*" >&2
      exit 1
    }

    pass() {
      echo "PASS: $*"
    }

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export XDG_CONFIG_HOME="$TMPDIR/config"

    export QT_QPA_PLATFORM=offscreen

    gw_sh_status=0
    printf 'puts HELLO\n' | ${gowin-eda-education}/bin/gw_sh > gw_sh.log 2>&1 || gw_sh_status=$?
    if [ "$gw_sh_status" -ne 0 ]; then
      cat gw_sh.log >&2
      fail "gw_sh exited with status $gw_sh_status"
    fi
    if ! grep -q HELLO gw_sh.log; then
      cat gw_sh.log >&2
      fail "gw_sh did not print expected output"
    fi
    pass "gw_sh"

    gw_ide_status=0
    timeout 15 ${gowin-eda-education}/bin/gw_ide > gw_ide.log 2>&1 || gw_ide_status=$?
    if [ "$gw_ide_status" -ne 124 ]; then
      cat gw_ide.log >&2
      fail "gw_ide exited before the timeout with status $gw_ide_status"
    fi
    pass "gw_ide"

    touch "$out"
  '';
}
