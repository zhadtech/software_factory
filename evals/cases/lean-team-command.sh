# Does /sdlc-lean:team get a plain request to the product role? Claude Code tells the main session
# not to start sub-agents unless the user asks; the command is how the director asks.
# Both variants load the same plugins; the variant without sends the request without the command.
# Fields are described in evals/cases/stacks-python-encoding.sh.
PLUGIN=sdlc-lean
RULES="R-TEAM-003"
WITH="sdlc-core sdlc-lean"
WITHOUT="sdlc-core sdlc-lean"
MODEL=haiku
TURNS=16
PROMPT="/sdlc-lean:team Add a Python 3 script that counts the words in a file, with tests. Standard library only. I approve in advance the steps you write; do not stop to confirm them."
PROMPT_WITHOUT="Add a Python 3 script that counts the words in a file, with tests. Standard library only. I approve in advance the steps you write; do not stop to confirm them."
setup() { bash "$root/scripts/new-project.sh" . >/dev/null; }
# The same outcome check as core-role-dispatch.
check() { . "$root/evals/cases/core-role-dispatch.sh" && check; }
