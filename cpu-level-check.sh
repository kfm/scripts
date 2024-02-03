#!/usr/bin/sh
set -e

verbose=
while getopts v OPTLET; do
  case "$OPTLET" in
    v) verbose=1;;
    \?) exit 2;;
  esac
done

flags=$(grep '^flags\b' </proc/cpuinfo | head -n 1)
flags=" ${flags#*:} "

has_flags () {
  for flag; do
    case "$flags" in
      *" $flag "*) :;;
      *)
        if [ -n "$verbose" ]; then
          echo >&2 "Missing $flag for the next level"
        fi
        return 1;;
    esac
  done
}

determine_level () {
  level="N/A [Use -v to see missing flag(s)]"
  has_flags lm cmov cx8 fpu fxsr mmx syscall sse2 || return 0
  level=x86-64-v1
  has_flags cx16 lahf_lm popcnt sse4_1 sse4_2 ssse3 || return 0
  level=x86-64-v2
  has_flags aes || return 0
  level=x86-64-v2-AES
  has_flags avx avx2 bmi1 bmi2 f16c fma abm movbe xsave aes || return 0
  level=x86-64-v3
  has_flags avx512f avx512bw avx512cd avx512dq avx512vl || return 0
  level=x86-64-v4
}

determine_level
echo "$level"
