"""Command-line entry point for pack-builder."""

from __future__ import annotations

from pathlib import Path

import click
import yaml
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from .loader import load_pack_source
from .packager import build_pack
from .rag import answer as rag_answer
from .rag import make_backend
from .retriever import TrailpackReader
from .safety import classify
from .schemas import (
    ValidationResult,
    validate_frontmatter,
    validate_manifest,
    validate_safety_rules,
)

console = Console()


def _validate_source(pack_dir: Path) -> ValidationResult:
    src = load_pack_source(pack_dir)
    result = ValidationResult()
    validate_manifest(src.manifest, result)
    validate_safety_rules(src.safety_rules, result)
    for cf in src.content_files:
        validate_frontmatter(cf.relative_path, cf.frontmatter, result)
    return result


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
def main() -> None:
    """pack-builder: compile pack source dirs into .trailpack files."""


@main.command()
@click.argument("pack_dir", type=click.Path(exists=True, file_okay=False, path_type=Path))
def validate(pack_dir: Path) -> None:
    """Validate a pack source directory against the schemas."""
    result = _validate_source(pack_dir)
    if result.errors:
        console.print(f"[red]✗ {len(result.errors)} error(s)[/red]")
        for e in result.errors:
            console.print(f"  [red]ERROR[/red] {e}")
    if result.warnings:
        console.print(f"[yellow]⚠ {len(result.warnings)} warning(s)[/yellow]")
        for w in result.warnings:
            console.print(f"  [yellow]WARN[/yellow] {w}")
    if result.ok:
        console.print("[green]✓ valid[/green]")
    else:
        raise SystemExit(1)


@main.command()
@click.argument("pack_dir", type=click.Path(exists=True, file_okay=False, path_type=Path))
@click.option("--out", "-o", required=True, type=click.Path(path_type=Path),
              help="Output .trailpack path")
@click.option("--no-embed", is_flag=True, help="Skip embeddings (faster, retrieval will be keyword-only)")
def build(pack_dir: Path, out: Path, no_embed: bool) -> None:
    """Compile a pack source dir into a .trailpack."""
    result = _validate_source(pack_dir)
    if result.errors:
        console.print("[red]Validation failed — fix errors before building.[/red]")
        for e in result.errors:
            console.print(f"  [red]ERROR[/red] {e}")
        raise SystemExit(1)

    src = load_pack_source(pack_dir)
    with console.status(f"Building {out.name}..."):
        manifest = build_pack(src, out, embed=not no_embed)

    summary = Table(show_header=False, box=None, pad_edge=False)
    summary.add_row("[bold]pack id[/bold]", str(manifest.get("id")))
    summary.add_row("[bold]version[/bold]", str(manifest.get("version")))
    summary.add_row("[bold]chunks[/bold]", str(manifest.get("chunk_count")))
    summary.add_row("[bold]sources[/bold]", str(manifest.get("source_count")))
    summary.add_row("[bold]size[/bold]", f"{manifest.get('size_bytes', 0) / 1024:.1f} KB")
    summary.add_row("[bold]output[/bold]", str(out))
    console.print(Panel(summary, title="✓ Pack built", border_style="green"))


@main.command()
@click.argument("pack_path", type=click.Path(exists=True, dir_okay=False, path_type=Path))
def inspect(pack_path: Path) -> None:
    """Print the manifest and basic stats for a built .trailpack."""
    import zipfile

    with zipfile.ZipFile(pack_path, "r") as zf:
        with zf.open("manifest.yaml") as f:
            manifest = yaml.safe_load(f)

    console.print(Panel(yaml.safe_dump(manifest, sort_keys=False), title=str(pack_path)))


@main.command()
@click.argument("query_text", type=str)
@click.option("--pack", "-p", required=True, type=click.Path(exists=True, path_type=Path),
              help="Path to .trailpack file")
@click.option("-k", default=5, help="Number of chunks to return")
def query(query_text: str, pack: Path, k: int) -> None:
    """Run a hybrid keyword+vector query against a built pack."""
    with TrailpackReader(pack) as reader:
        # Pull safety rules out of the pack
        import yaml as _yaml
        with (reader.root / "safety_rules.yaml").open() as f:
            rules = _yaml.safe_load(f) or []

        decision = classify(query_text, rules)
        results = reader.query(query_text, k=k)

    # Show safety decision
    risk_color = {
        "low": "green",
        "medium": "yellow",
        "high": "red",
        "critical": "bold red",
    }.get(decision.risk, "white")
    console.print(
        Panel(
            f"[bold]Intent:[/bold] {decision.intent}\n"
            f"[bold]Risk:[/bold] [{risk_color}]{decision.risk}[/{risk_color}]\n"
            f"[bold]Answer mode:[/bold] {decision.answer_mode}",
            title="Safety routing",
            border_style=risk_color,
        )
    )

    if decision.must_include:
        for m in decision.must_include:
            console.print(f"  [yellow]⚠[/yellow] {m}")

    if decision.answer_mode == "refuse_with_warning":
        console.print(
            "\n[red]This query is refused for safety reasons. "
            "No chunks will be returned.[/red]"
        )
        return

    console.print(f"\n[bold]Top {len(results)} chunks for:[/bold] {query_text!r}\n")
    for i, c in enumerate(results, 1):
        hl_color = {
            "low": "green",
            "medium": "yellow",
            "high": "red",
            "critical": "bold red",
        }.get(c.hazard_level, "white")
        header = (
            f"[bold]{i}. {c.section_title}[/bold]  "
            f"[{hl_color}]{c.hazard_level}[/{hl_color}]  "
            f"[dim]({c.domain}, hybrid={c.score_hybrid:.3f}, "
            f"kw={c.score_keyword:.3f}, vec={c.score_vector:.3f})[/dim]"
        )
        body = c.text
        src = f"[dim]source: {c.source_title} — {c.source_publisher}[/dim]"
        console.print(Panel(f"{body}\n\n{src}", title=header, title_align="left"))


@main.command()
@click.argument("query_text", type=str)
@click.option("--pack", "-p", required=True, type=click.Path(exists=True, path_type=Path),
              help="Path to .trailpack file")
@click.option("-k", default=5, help="Number of chunks to retrieve")
@click.option("--backend", default="print",
              type=click.Choice(["print", "anthropic", "mlx", "llama-cpp"]),
              help="LLM backend: 'print' shows the prompt without an LLM call")
@click.option("--model", default=None, help="Model id/path for the chosen backend")
@click.option("--temperature", default=0.3, type=float)
@click.option("--max-tokens", default=512, type=int)
def rag(
    query_text: str,
    pack: Path,
    k: int,
    backend: str,
    model: str | None,
    temperature: float,
    max_tokens: int,
) -> None:
    """End-to-end RAG: retrieve + safety route + prompt build + (optional) LLM answer."""
    backend_kwargs: dict[str, str] = {}
    if model:
        if backend == "anthropic":
            backend_kwargs["model"] = model
        elif backend == "mlx":
            backend_kwargs["model_id"] = model
        elif backend == "llama-cpp":
            backend_kwargs["model_path"] = model

    try:
        be = make_backend(backend, **backend_kwargs)
    except Exception as e:
        console.print(f"[red]Failed to initialize {backend} backend: {e}[/red]")
        raise SystemExit(2)

    console.print(Panel(f"[bold]Query:[/bold] {query_text}", title="RAG"))

    streamed_chunks: list[str] = []

    def on_token(tok: str) -> None:
        streamed_chunks.append(tok)
        console.out(tok, end="", highlight=False)

    result = rag_answer(
        query=query_text,
        pack_path=pack,
        backend=be,
        k=k,
        temperature=temperature,
        max_tokens=max_tokens,
        on_token=on_token if backend != "print" else None,
    )

    console.print()  # newline after stream

    # Summary panel
    risk_color = {"low": "green", "medium": "yellow", "high": "red",
                  "critical": "bold red"}.get(result.risk, "white")
    summary = Table(show_header=False, box=None, pad_edge=False)
    summary.add_row("[bold]intent[/bold]", result.intent)
    summary.add_row("[bold]risk[/bold]", f"[{risk_color}]{result.risk}[/{risk_color}]")
    summary.add_row("[bold]mode[/bold]", result.answer_mode)
    summary.add_row("[bold]backend[/bold]", result.backend)
    summary.add_row("[bold]chunks[/bold]", str(len(result.retrieved_chunks)))
    summary.add_row("[bold]citations valid[/bold]",
                    ", ".join(result.citations_valid) or "(none)")
    if result.citations_invalid_stripped:
        summary.add_row("[bold red]citations stripped[/bold red]",
                        ", ".join(result.citations_invalid_stripped))
    console.print(Panel(summary, title="Result", border_style=risk_color))

    # For print backend, the streamed output WAS the result. Otherwise show the
    # post-validation answer (may differ from streamed if citations were stripped).
    if backend != "print":
        console.print(Panel(result.answer, title="Final answer (post-validation)"))


if __name__ == "__main__":
    main()
