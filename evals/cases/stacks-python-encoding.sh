# Does R-PY-003 make Claude open text files with an explicit encoding?
# Fields: PLUGIN, the plugin the case tests (--changed picks cases by it); RULES, the rules it
# gives evidence for; WITH and WITHOUT, the plugins each variant loads; MODEL; TURNS; PROMPT, and
# optionally PROMPT_WITHOUT, a different prompt for the variant without;
# setup, run in an empty folder before the session; check, run there after it, with the session's
# stream-json log in $TRANSCRIPT, and exits 0 when the run passes.
PLUGIN=sdlc-stacks
RULES="R-PY-003"
WITH="sdlc-stacks"
WITHOUT=""
MODEL=haiku
TURNS=6
PROMPT="Create util.py with a function read_lines(path) that returns the lines of a text file. Write the file only; do not run anything."
setup() { git init -q .; }
check() { grep -Eq 'encoding *= *["'"'"'](utf-?8|UTF-?8)' util.py; }
