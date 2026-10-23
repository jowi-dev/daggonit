# daggonit

Layout code for drawing a directed graph in a terminal. You give it node ids and the edges between them. It tells you where each node goes and which box-drawing characters draw each edge, measured in character cells. It never touches the terminal itself: each caller turns that output into styled cells with whatever toolkit it uses.

## Why it exists

Two tools need the same terminal graph drawing:

- [vdiff](https://github.com/jowi-dev/vdiff) shows a branch's changed modules as a dependency graph. The layout code started there.
- [tskmstr](https://github.com/jowi-dev/tskmstr) (`tm`) needs to show epics and the "unlocks" links between them, meaning which epic has to finish before another can start ([tskmstr#176](https://github.com/jowi-dev/tskmstr/issues/176)).

tskmstr cannot depend on vdiff directly, because that would pull in git, Rust and Elixir parsers, and Neovim glue just to get three layout files. Copying the files would mean every layout fix has to land twice. So the layout code lives here, and both tools depend on this crate.

## Status

Empty. The code moves in from vdiff in two steps:

1. [vdiff#40](https://github.com/jowi-dev/vdiff/issues/40) moves the three modules that are already independent of vdiff:
   - `sugiyama`: layered layout. Nodes go into top-to-bottom bands. An edge that skips a band gets a placeholder slot in each band it crosses. Nodes are reordered to reduce crossings, and each one gets an x position.
   - `canvas`: routes the edges between two adjacent bands as rows of box-drawing characters, with a cap on how tall each gap can grow.
   - `rails`: a `git log --graph`-style margin, with one row per node and each edge drawn as a vertical line.
2. [vdiff#41](https://github.com/jowi-dev/vdiff/issues/41) moves `plane`, which draws a tree of containers as nested boxes with edges between them. It reads the tree through a small trait, so vdiff can supply namespaces and modules, and tskmstr can supply epics and their tickets.

## Rules for this crate

- **No terminal or GUI dependencies.** No ratatui, crossterm, or egui, and none of the callers' heavy dependencies (git2, syn, tree-sitter). Output is plain data: characters, positions, and a role for each cell (a normal edge, or an edge into or out of the focused node) that the caller maps to a color.
- **Character units.** Every position and width is a count of terminal columns or rows.
- **String node ids.** Both callers key nodes by strings, so the crate's node id type wraps a `String`.
- **Defensive about input.** An edge whose endpoint is missing, or whose two ends land in the same band or row, is dropped. It never causes a panic.
- **Sized for small graphs.** The callers draw 10 to 40 visible nodes. When a graph is too dense to draw fully, the layouts drop edges that do not touch the focused node and report how many they dropped. They do not try to scale to thousands of nodes.

## Development

```sh
direnv allow        # or: nix develop
cargo test
nix flake check
```

Callers use it as a git dependency pinned to a commit:

```toml
daggonit = { git = "https://github.com/jowi-dev/daggonit", rev = "..." }
```

There is no crates.io release.

## License

MIT or Apache-2.0, at your option.
