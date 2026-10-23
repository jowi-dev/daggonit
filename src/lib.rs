//! Pure, toolkit-neutral DAG layout for character-cell renderers.
//!
//! Callers pass node ids and edges and get back positions and box-drawing
//! glyphs in terminal columns and rows; turning those into styled cells is
//! the caller's job. Shared by vdiff (module dependency graphs) and
//! tskmstr (epic unlocks graphs). See the README for the rules every
//! module here follows.
//!
//! The layout modules (`sugiyama`, `canvas`, `rails`, then `plane`) move
//! in from vdiff in jowi-dev/vdiff#40 and jowi-dev/vdiff#41.
