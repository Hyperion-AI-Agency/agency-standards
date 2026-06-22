"""Agency coding-standards MCP server.

Exposes the agency-standards markdown library as on-demand tools so coding agents
query the relevant standard instead of loading everything into context.

Tools: list_standards, get_standard, search_standards.

Run (self-contained, no global install):
    uv run --with mcp python mcp/standards_server.py
Point it at the standards dir via env STANDARDS_DIR (defaults to ../standards
relative to this file).
"""

from __future__ import annotations

import os
from pathlib import Path

from mcp.server.fastmcp import FastMCP

STANDARDS_DIR = Path(
    os.environ.get("STANDARDS_DIR", Path(__file__).resolve().parent.parent / "standards")
).resolve()

mcp = FastMCP("agency-standards")


def _all_files() -> list[Path]:
    return sorted(STANDARDS_DIR.rglob("*.md"))


def _id(path: Path) -> str:
    return path.relative_to(STANDARDS_DIR).with_suffix("").as_posix()


def _summary(path: Path) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith("#"):
            return stripped[:140]
    return ""


def _do_list() -> str:
    if not STANDARDS_DIR.is_dir():
        return f"ERROR: standards dir not found: {STANDARDS_DIR}"
    lines = ["Available standards (id — summary). Use get_standard(id) to read one."]
    for path in _all_files():
        lines.append(f"- {_id(path)} — {_summary(path)}")
    return "\n".join(lines)


def _do_get(standard_id: str) -> str:
    target = (STANDARDS_DIR / f"{standard_id.strip().removesuffix('.md')}.md").resolve()
    # confine to STANDARDS_DIR (no path traversal)
    if STANDARDS_DIR not in target.parents or not target.is_file():
        return f"ERROR: unknown standard id '{standard_id}'. Call list_standards first."
    return target.read_text(encoding="utf-8")


def _do_search(query: str) -> str:
    needle = query.strip().lower()
    if not needle:
        return "ERROR: empty query."
    hits: list[str] = []
    for path in _all_files():
        matched = [
            ln.strip()
            for ln in path.read_text(encoding="utf-8").splitlines()
            if needle in ln.lower()
        ]
        if matched:
            hits.append(f"## {_id(path)}")
            hits.extend(f"  {m[:160]}" for m in matched[:5])
    return "\n".join(hits) if hits else f"No matches for '{query}'."


@mcp.tool()
def list_standards() -> str:
    """List every available coding standard as 'id — summary'. Call this first."""
    return _do_list()


@mcp.tool()
def get_standard(standard_id: str) -> str:
    """Return the full markdown of one standard by id (e.g. 'patterns/design-patterns')."""
    return _do_get(standard_id)


@mcp.tool()
def search_standards(query: str) -> str:
    """Search all standards for a keyword; returns matching ids + line snippets."""
    return _do_search(query)


if __name__ == "__main__":
    mcp.run()
