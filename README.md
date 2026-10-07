# comments-by-humans

The model writes the code. You explain it.

comments-by-humans stops an AI coding assistant after every chunk of code it writes until you have explained that chunk, in your own words, in a comment above it. The assistant grades your comment against a fixed rubric and asks one question at a time until it passes, without giving you the answer. The stop is enforced mechanically: while a comment is pending, the assistant's write and shell tools are denied. Pointed at existing code, the same loop becomes a chunk-by-chunk review tool.

It runs two ways on one gate engine:

- **Claude Code plugin**, enforced by Claude Code hooks.
- **Standalone agent** (`comments-by-humans/agent/cbh.py`) for any model: Anthropic, OpenAI, Gemini, Ollama, any OpenAI-compatible server, or any command-line model.

Full documentation is in the [plugin README](comments-by-humans/README.md); the design spec is in [docs/comments-by-humans-spec.md](docs/comments-by-humans-spec.md).

## Requirements

- Python 3, from any install: `py`, `python3` or `python` on `PATH`, or the path in `CBH_PYTHON`. The hooks skip the Microsoft Store aliases that Windows installs without a real interpreter.
- Claude Code, for the plugin front end only. On Windows, hooks run in Git Bash, Claude Code's default shell there; PowerShell-only setups are not supported.

## Install

**Claude Code:**

```
/plugin marketplace add aidanfritzke/comments-by-humans
/plugin install comments-by-humans@comments-by-humans
```

To install from a branch, pin it when adding the marketplace: `/plugin marketplace add aidanfritzke/comments-by-humans#<branch>`. From a shell, use `claude plugin marketplace add ...` and `claude plugin install ...`.

**Any other model:** clone this repository and run the standalone agent. It has no dependencies beyond Python 3.

```
python3 comments-by-humans/agent/cbh.py --help
```

Either way, add `.comments-by-humans/` to your project's `.gitignore`. The gate keeps its state there.

## Usage

| Claude Code | Standalone agent | What it does |
| --- | --- | --- |
| `/comments-by-humans:build <task>` | `cbh.py build "<task>"` | Build the task one chunk at a time, gating each chunk on your explanation. |
| `/comments-by-humans:review <path or diff range> [--inline]` | `cbh.py review <target>` | Review existing code chunk by chunk and write a report. |
| `/comments-by-humans:pause` | `/pause` in a session | Lift the gate. Only you can run it. |
| `/comments-by-humans:status` | `cbh.py status` | Show the mode, the lock and per-chunk attempts. |

The standalone agent needs a provider (`--provider` or `CBH_PROVIDER`) and, for every provider except `anthropic`, a model (`--model`). With no action it opens an interactive session. Gate settings live in `.comments-by-humans/config.json` in your project.

## Repository layout

```
.claude-plugin/marketplace.json   marketplace catalog
LICENSE                           MIT license
comments-by-humans/               the plugin and the standalone agent
├── .claude-plugin/plugin.json    plugin manifest
├── skills/                       build, review, pause, status
├── hooks/hooks.json              hook wiring; every hook calls scripts/gate.sh
├── scripts/                      gate engine, its Python launcher and comment-syntax handling
├── agent/                        standalone agent, providers and eval runner
├── tests/                        deterministic tests and the install test
└── evals/                        model-graded eval cases and scripted learner
docs/                             design spec
```

## Development

```
python3 -m unittest discover -s comments-by-humans/tests -v
```

Model-graded evals, the scripted-learner driver and the install test are described in the plugin README's [Development](comments-by-humans/README.md#development) section.

## License

MIT. See [LICENSE](LICENSE).
