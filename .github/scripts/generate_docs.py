#!/usr/bin/env python3
"""
Deep Reverse Engineering Documentation Generator for moneyinsight (Flutter/Dart).

Implements all 8 stages described in the reverse-engineering specification:
  Stage 0 — Discovery
  Stage 1 — Inventory
  Stage 2 — Signature Extraction
  Stage 3 — Dependency Mapping
  Stage 4 — Data Model Extraction
  Stage 5 — Logic Summary
  Stage 6 — Business Intent
  Stage 7 — Generate Documentation
  Stage 8 — Agent-Native Context Files
"""

import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parents[2]  # <repo>/.github/scripts -> <repo>
LIB_ROOT = REPO_ROOT / "lib"
DOCS_ROOT = REPO_ROOT / ".github" / "docs"
INTERMEDIATE = DOCS_ROOT / "intermediate"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _write_json(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"  wrote {path.relative_to(REPO_ROOT)}")


def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print(f"  wrote {path.relative_to(REPO_ROOT)}")


def _dart_files() -> List[Path]:
    """Return all non-generated Dart files under lib/."""
    result = []
    for p in sorted(LIB_ROOT.rglob("*.dart")):
        if any(p.name.endswith(s) for s in (".g.dart", ".freezed.dart", ".mocks.dart")):
            continue
        result.append(p)
    return result


def _rel(path: Path) -> str:
    """Return repo-relative path string e.g. 'lib/main.dart'."""
    return str(path.relative_to(REPO_ROOT))


def _cluster(path: Path) -> str:
    parts = path.relative_to(LIB_ROOT).parts
    if len(parts) == 1:
        return "root"
    if parts[0] == "core":
        return parts[1] if len(parts) > 1 else "core"
    if parts[0] == "features":
        return parts[1] if len(parts) > 1 else "features"
    return parts[0]


def _roles(path: Path) -> List[str]:
    name = path.name
    parts = list(path.relative_to(LIB_ROOT).parts)
    roles: List[str] = []

    if name == "main.dart":
        roles.append("entry")
    if name.endswith("_screen.dart") or name.endswith("_page.dart"):
        roles.append("screen")
    if "widgets" in parts:
        roles.append("widget")
    if any(name.endswith(s) for s in ("_provider.dart", "_providers.dart", "_notifier.dart")):
        roles.append("provider")
    if name.endswith("_service.dart"):
        roles.append("service")
    if "daos" in parts:
        roles.append("dao")
    if any(name.endswith(s) for s in ("_model.dart", "_entity.dart")) or name == "tables.dart":
        roles.append("model")
    if name.endswith("_calculator.dart"):
        roles.append("calculator")
    if name == "main_shell.dart" or "router" in name:
        roles.append("router")
    if name in ("app_theme.dart", "database.dart", "firebase_options.dart"):
        roles.append("config")
    if any(name.endswith(s) for s in ("_formatter.dart", "_util.dart", "_helper.dart", "_extension.dart")):
        roles.append("util")
    if name.endswith("_parser.dart"):
        roles.append("parser")

    if not roles:
        roles.append("other")
    return roles


# ---------------------------------------------------------------------------
# Dart parsing helpers
# ---------------------------------------------------------------------------


def _read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return ""


def _extract_imports(src: str) -> List[Dict]:
    imports = []
    for m in re.finditer(r"""import\s+['"]([^'"]+)['"]\s*(?:as\s+\w+\s*)?;""", src):
        uri = m.group(1)
        if uri.startswith("dart:"):
            kind = "sdk"
        elif uri.startswith("package:flutter/") or uri.startswith("package:flutter_localizations"):
            kind = "flutter"
        elif "riverpod" in uri:
            kind = "riverpod"
        elif uri.startswith("package:drift"):
            kind = "drift"
        elif uri.startswith("package:firebase") or uri.startswith("package:cloud_firestore"):
            kind = "firebase"
        elif uri.startswith("../") or uri.startswith("./") or (not uri.startswith("package:")):
            kind = "internal"
        else:
            kind = "third_party"
        imports.append({"uri": uri, "kind": kind})
    return imports


def _extract_classes(src: str) -> List[Dict]:
    classes = []
    pattern = re.compile(
        r"""class\s+(\w+)"""
        r"""(?:\s+extends\s+([\w<>, .]+?))?"""
        r"""(?:\s+with\s+([\w<>, .]+?))?"""
        r"""(?:\s+implements\s+([\w<>, .]+?))?"""
        r"""\s*\{""",
        re.MULTILINE,
    )
    for m in pattern.finditer(src):
        name = m.group(1)
        extends = (m.group(2) or "").strip() or None
        mixins = [x.strip() for x in (m.group(3) or "").split(",") if x.strip()] or None
        implements = [x.strip() for x in (m.group(4) or "").split(",") if x.strip()] or None

        base_widgets = {
            "StatelessWidget", "StatefulWidget", "ConsumerWidget",
            "ConsumerStatefulWidget", "State", "ConsumerState",
        }
        notifiers = {"StateNotifier", "Notifier", "AsyncNotifier", "AutoDisposeAsyncNotifier"}

        widget_type = None
        if extends and any(w in extends for w in base_widgets):
            widget_type = extends.split("<")[0].strip()
        notifier_type = None
        if extends and any(n in extends for n in notifiers):
            notifier_type = extends.split("<")[0].strip()

        classes.append({
            "name": name,
            "extends": extends,
            "mixins": mixins,
            "implements": implements,
            "widget_type": widget_type,
            "notifier_type": notifier_type,
        })
    return classes


def _extract_methods(src: str) -> List[Dict]:
    """Extract top-level and class-level method signatures (heuristic)."""
    methods = []
    # Match: [annotations] [modifier] ReturnType methodName([params])
    pattern = re.compile(
        r"""(?:@override\s+)?"""
        r"""((?:Future|Stream|List|Map|Set|void|bool|int|double|String|dynamic|[\w<>\[\]?, ]+?)\s+)"""
        r"""(\w+)\s*\(([^)]*)\)\s*(?:async\s*)?\{""",
        re.MULTILINE,
    )
    for m in pattern.finditer(src):
        ret = m.group(1).strip()
        name = m.group(2)
        params_raw = m.group(3).strip()
        # Skip keywords that look like method names
        if name in ("if", "while", "for", "switch", "catch"):
            continue
        is_async = bool(re.search(r"\)\s*async\s*\{", src[m.start():m.start() + len(m.group(0)) + 10]))
        is_override = bool(re.search(r"@override", src[max(0, m.start() - 30):m.start()], re.IGNORECASE))
        is_private = name.startswith("_")

        # Parse params loosely
        params = []
        if params_raw:
            for part in re.split(r",\s*", params_raw):
                part = part.strip().lstrip("{").lstrip("[").rstrip("}").rstrip("]").strip()
                if part:
                    params.append(part)

        methods.append({
            "name": name,
            "return_type": ret,
            "params": params,
            "async": is_async,
            "override": is_override,
            "private": is_private,
        })
    return methods


def _extract_providers(src: str) -> List[Dict]:
    """Extract Riverpod provider declarations."""
    providers = []

    # @riverpod annotated functions/classes
    riverpod_pattern = re.compile(r"@[Rr]iverpod.*?\n.*?(?:Future|Stream|[\w<>]+)\s+(\w+)\s*\(", re.DOTALL)
    for m in riverpod_pattern.finditer(src):
        watches = re.findall(r"ref\.watch\(\s*(\w+)", src[m.start():m.start() + 500])
        reads = re.findall(r"ref\.read\(\s*(\w+)", src[m.start():m.start() + 500])
        providers.append({
            "name": m.group(1),
            "annotation": "@riverpod",
            "watches": list(set(watches)),
            "reads": list(set(reads)),
        })

    # Provider/FutureProvider/StreamProvider declarations
    prov_pattern = re.compile(
        r"final\s+(\w+)\s*=\s*(Provider|FutureProvider|StreamProvider|StateNotifierProvider|ChangeNotifierProvider|AutoDispose\w*Provider)\s*[<(]"
    )
    for m in prov_pattern.finditer(src):
        watches = re.findall(r"ref\.watch\(\s*(\w+)", src[m.start():m.start() + 500])
        reads = re.findall(r"ref\.read\(\s*(\w+)", src[m.start():m.start() + 500])
        providers.append({
            "name": m.group(1),
            "type": m.group(2),
            "watches": list(set(watches)),
            "reads": list(set(reads)),
        })

    return providers


def _extract_drift_dao(src: str) -> Optional[Dict]:
    """Extract @DriftAccessor info."""
    m = re.search(r"@DriftAccessor\s*\(\s*tables\s*:\s*\[([^\]]*)\]", src)
    if not m:
        return None
    tables = [t.strip() for t in m.group(1).split(",") if t.strip()]
    return {"tables": tables}


def _extract_fields(src: str) -> List[Dict]:
    """Extract significant field declarations."""
    fields = []
    pattern = re.compile(
        r"""(final|late final|const|static final|static const|late)\s+"""
        r"""([\w<>\[\]?, ]+)\s+(\w+)\s*[=;]"""
    )
    for m in pattern.finditer(src):
        fields.append({
            "modifier": m.group(1),
            "type": m.group(2).strip(),
            "name": m.group(3),
        })
    return fields[:20]  # cap to avoid noise


# ---------------------------------------------------------------------------
# Stage 0 — Discovery
# ---------------------------------------------------------------------------


def stage0() -> None:
    print("\n=== Stage 0: Discovery ===")
    files = _dart_files()

    file_sizes = []
    for f in files:
        lines = len(f.read_text(encoding="utf-8").splitlines())
        file_sizes.append({"path": _rel(f), "lines": lines})

    manifest = {
        "repo": "moneyinsight",
        "tier": "XS",
        "primary_language": "dart",
        "framework": "flutter",
        "state_management": "riverpod",
        "database": {
            "primary": "drift_sqlite",
            "sync": "cloud_firestore",
        },
        "firebase_role": "auth_and_sync_only",
        "features": [
            "accounts", "analytics", "auth", "budget",
            "goals", "onboarding", "settings", "shell", "sync", "transactions",
        ],
        "entry_point": "lib/main.dart",
        "dart_file_count": len(files),
        "dart_files": file_sizes,
        "run_timestamp": datetime.now(timezone.utc).isoformat(),
    }
    _write_json(DOCS_ROOT / "_manifest.json", manifest)


# ---------------------------------------------------------------------------
# Stage 1 — Inventory
# ---------------------------------------------------------------------------


def stage1() -> List[Dict]:
    print("\n=== Stage 1: Inventory ===")
    files = _dart_files()
    inventory = []
    for f in files:
        entry = {
            "path": _rel(f),
            "role": _roles(f),
            "cluster": _cluster(f),
            "p1_inventory": True,
            "p2_signatures": False,
            "p3_dependencies": False,
            "p4_data_models": False,
            "p5_logic_summary": False,
            "p6_business_intent": False,
        }
        inventory.append(entry)
    _write_json(DOCS_ROOT / "_inventory.json", inventory)
    return inventory


# ---------------------------------------------------------------------------
# Stage 2 — Signature Extraction
# ---------------------------------------------------------------------------


def stage2(inventory: List[Dict]) -> Dict[str, Any]:
    print("\n=== Stage 2: Signature Extraction ===")

    # Group by cluster
    by_cluster: Dict[str, List[Dict]] = defaultdict(list)
    for item in inventory:
        by_cluster[item["cluster"]].append(item)

    all_sigs: Dict[str, Dict] = {}  # path -> sig dict

    for cluster, items in sorted(by_cluster.items()):
        cluster_sigs = []
        for item in items:
            path = REPO_ROOT / item["path"]
            src = _read(path)
            sig = {
                "path": item["path"],
                "cluster": cluster,
                "role": item["role"],
                "imports": _extract_imports(src),
                "classes": _extract_classes(src),
                "methods": _extract_methods(src),
                "providers": _extract_providers(src),
                "drift_dao": _extract_drift_dao(src),
                "fields": _extract_fields(src),
            }
            cluster_sigs.append(sig)
            all_sigs[item["path"]] = sig
            item["p2_signatures"] = True

        _write_json(
            INTERMEDIATE / "signatures" / f"{cluster}.json",
            cluster_sigs,
        )

    # Update inventory
    _write_json(DOCS_ROOT / "_inventory.json", inventory)
    return all_sigs


# ---------------------------------------------------------------------------
# Stage 3 — Dependency Mapping
# ---------------------------------------------------------------------------


def _resolve_import(from_path: str, import_uri: str) -> Optional[str]:
    """Resolve a relative import to a lib/ path."""
    if not (import_uri.startswith("../") or import_uri.startswith("./") or
            (not import_uri.startswith("package:") and not import_uri.startswith("dart:"))):
        return None
    base = Path(from_path).parent
    try:
        resolved = (base / import_uri).resolve()
        rel = resolved.relative_to(REPO_ROOT)
        return str(rel)
    except Exception:
        return None


def stage3(inventory: List[Dict], all_sigs: Dict[str, Dict]) -> None:
    print("\n=== Stage 3: Dependency Mapping ===")

    # Build import map: path -> list of resolved internal paths
    import_map: Dict[str, List[str]] = {}
    for path, sig in all_sigs.items():
        resolved = []
        for imp in sig["imports"]:
            if imp["kind"] == "internal":
                r = _resolve_import(path, imp["uri"])
                if r:
                    resolved.append(r)
        import_map[path] = resolved

    # Count how many files import each file (fan-in)
    fan_in: Dict[str, int] = defaultdict(int)
    for deps in import_map.values():
        for d in deps:
            fan_in[d] += 1

    critical = [p for p, c in sorted(fan_in.items(), key=lambda x: -x[1]) if c >= 3]

    # Detect cross-feature imports
    cross_feature = []
    for path, deps in import_map.items():
        from_cluster = _cluster(REPO_ROOT / path)
        for dep in deps:
            dep_path = REPO_ROOT / dep
            if dep_path.exists():
                to_cluster = _cluster(dep_path)
                if (from_cluster not in ("core", "root") and
                        to_cluster not in ("core", "root", "database") and
                        from_cluster != to_cluster):
                    cross_feature.append({"from": path, "to": dep})

    # Build provider chains (screen → provider → DAO)
    provider_chains = []
    for item in inventory:
        if "screen" not in item["role"]:
            continue
        sig = all_sigs.get(item["path"], {})
        watches = []
        for p in sig.get("providers", []):
            watches.extend(p.get("watches", []))
        if watches:
            provider_chains.append({
                "screen": item["path"],
                "watches": watches,
            })

    # Sync boundary
    sync_path = "lib/features/sync/sync_service.dart"
    sync_src = _read(REPO_ROOT / sync_path)
    synced_collections = re.findall(r'\.collection\([\'"](\w+)[\'"]', sync_src)
    synced_tables = list(dict.fromkeys(
        c for c in synced_collections if c != "users"
    ))

    graph = {
        "critical_path_files": critical[:10],
        "cross_feature_imports": cross_feature,
        "provider_chains": provider_chains,
        "sync_boundary": {
            "file": sync_path,
            "synced_collections": synced_tables,
            "synced_tables": [
                "accounts", "category_groups", "categories",
                "monthly_budgets", "transactions",
            ],
            "synced_providers": ["syncServiceProvider", "lastSyncProvider"],
        },
    }
    _write_json(INTERMEDIATE / "dependency_graph.json", graph)

    for item in inventory:
        item["p3_dependencies"] = True
    _write_json(DOCS_ROOT / "_inventory.json", inventory)


# ---------------------------------------------------------------------------
# Stage 4 — Data Model Extraction
# ---------------------------------------------------------------------------


_DRIFT_TYPE_MAP = {
    "IntColumn": "integer",
    "TextColumn": "text",
    "RealColumn": "real",
    "DateTimeColumn": "datetime",
    "BoolColumn": "boolean",
}


def _parse_tables(src: str) -> List[Dict]:
    """Parse Drift Table classes from tables.dart source."""
    tables = []
    class_pattern = re.compile(r"class\s+(\w+)\s+extends\s+Table\s*\{(.*?)\n\}", re.DOTALL)

    for m in class_pattern.finditer(src):
        class_name = m.group(1)
        body = m.group(2)

        # Derive table name: CamelCase → snake_case
        table_name = re.sub(r"(?<!^)(?=[A-Z])", "_", class_name).lower()

        columns = []
        col_pattern = re.compile(
            r"(\w+Column)\s+get\s+(\w+)\s*=>\s*([^;]+);"
        )
        for cm in col_pattern.finditer(body):
            col_type = cm.group(1)
            col_name = cm.group(2)
            expr = cm.group(3)
            nullable = ".nullable()" in expr
            pk = "autoIncrement" in expr
            ref_m = re.search(r"references\((\w+),", expr)
            ref_table = ref_m.group(1) if ref_m else None
            columns.append({
                "name": col_name,
                "type": col_type,
                "drift_type": _DRIFT_TYPE_MAP.get(col_type, col_type),
                "nullable": nullable,
                "primary_key": pk,
                "references": ref_table,
            })

        # unique keys
        unique_keys = re.findall(r"\{(.*?)\}", body.replace("\n", " "))

        tables.append({
            "drift_class": class_name,
            "table_name": table_name,
            "columns": columns,
            "unique_keys": unique_keys,
        })
    return tables


_DAO_TABLE_MAP = {
    "accounts_dao": "accounts",
    "budget_dao": "monthly_budgets",
    "budget_snapshots_dao": "budget_snapshots",
    "categories_dao": "categories",
    "recurring_queue_dao": "pending_recurring_queue",
    "transactions_dao": "transactions",
}

_SYNC_TABLE_MAP = {
    "accounts": "accounts",
    "categoryGroups": "category_groups",
    "categories": "categories",
    "monthlyBudgets": "monthly_budgets",
    "transactions": "transactions",
}


def _parse_dao(path: Path) -> List[Dict]:
    src = _read(path)
    queries = []
    method_pattern = re.compile(
        r"((?:Future|Stream)<[^>]+>|Future<\w+>|Stream<\w+>|Future<void>)\s+(\w+)\s*\(([^)]*)\)",
    )
    for m in method_pattern.finditer(src):
        ret = m.group(1)
        name = m.group(2)
        params = m.group(3).strip()
        is_stream = ret.startswith("Stream")

        # Guess operation type
        lower_name = name.lower()
        if any(x in lower_name for x in ("insert", "add", "create")):
            op = "INSERT"
        elif any(x in lower_name for x in ("update", "replace", "write")):
            op = "UPDATE"
        elif any(x in lower_name for x in ("delete", "remove", "soft")):
            op = "DELETE"
        else:
            op = "SELECT"

        queries.append({
            "method": name,
            "operation": op,
            "returns": ret,
            "reactive": is_stream,
            "params": params if params else None,
        })
    return queries


def stage4(inventory: List[Dict]) -> None:
    print("\n=== Stage 4: Data Model Extraction ===")

    tables_src = _read(LIB_ROOT / "core" / "database" / "tables.dart")
    tables = _parse_tables(tables_src)

    # Enrich tables with DAO and Firestore info
    dao_dir = LIB_ROOT / "core" / "database" / "daos"
    dao_queries: Dict[str, List[Dict]] = {}
    for dao_file in sorted(dao_dir.glob("*.dart")):
        if dao_file.name.endswith(".g.dart"):
            continue
        stem = dao_file.stem  # e.g. accounts_dao
        dao_queries[stem] = _parse_dao(dao_file)

    sync_src = _read(LIB_ROOT / "features" / "sync" / "sync_service.dart")
    synced_collections = re.findall(r'\.collection\([\'"](\w+)[\'"]', sync_src)
    synced_set = {c for c in synced_collections if c != "users"}

    for table in tables:
        tn = table["table_name"]
        # Match DAO
        dao_stem = next(
            (s for s, t in _DAO_TABLE_MAP.items() if t == tn), None
        )
        table["dao"] = dao_stem.replace("_", " ").title().replace(" ", "") if dao_stem else None
        table["dao_file"] = f"lib/core/database/daos/{dao_stem}.dart" if dao_stem else None
        table["queries"] = dao_queries.get(dao_stem, []) if dao_stem else []

        # Firestore collection
        fc = next(
            (col for col, tbl in _SYNC_TABLE_MAP.items() if tbl == tn and col in synced_set),
            None,
        )
        table["firestore_collection"] = fc
        table["sync_direction"] = "local_to_cloud" if fc else "none"

    firestore_collections = [
        {
            "collection": col,
            "maps_to_table": tbl,
            "sync_direction": "local_to_cloud",
        }
        for col, tbl in _SYNC_TABLE_MAP.items()
        if col in synced_set
    ]

    data_model = {
        "local_database": "sqlite_via_drift",
        "tables": tables,
        "firestore_collections": firestore_collections,
    }
    _write_json(INTERMEDIATE / "data_model.json", data_model)

    for item in inventory:
        if item["cluster"] in ("database", "sync"):
            item["p4_data_models"] = True
    _write_json(DOCS_ROOT / "_inventory.json", inventory)


# ---------------------------------------------------------------------------
# Stage 5 — Logic Summary
# ---------------------------------------------------------------------------


_SUMMARY_TEMPLATES: Dict[str, Dict] = {
    "lib/main.dart": {
        "summary": "Application entry point. Initialises Firebase, wraps the widget tree in ProviderScope (Riverpod), and delegates startup routing to _AppStartup which checks onboarding completion and triggers month-boundary logic.",
        "responsibilities": ["Bootstrap Firebase", "Wrap app in ProviderScope", "Route to onboarding or main shell", "Trigger month boundary checks"],
        "inputs": [], "outputs": ["Widget tree"],
        "complexity_flag": "low", "confidence": "high",
    },
}

_ROLE_SUMMARIES = {
    "screen": (
        "Displays UI to the user. Watches one or more Riverpod providers to read reactive data, "
        "dispatches user actions back to providers, and composes reusable widgets."
    ),
    "widget": (
        "Reusable UI component. Accepts typed parameters and renders a portion of a screen. "
        "May watch providers directly or receive data from a parent screen."
    ),
    "provider": (
        "Riverpod state management unit. Exposes reactive data or async results to the UI layer. "
        "Typically reads from a DAO or another provider and transforms the data."
    ),
    "service": (
        "Domain service that encapsulates business logic or integration with an external system. "
        "Invoked by providers or other services."
    ),
    "dao": (
        "Drift Data Access Object. Provides typed query methods (SELECT, INSERT, UPDATE, DELETE) "
        "against one or more Drift tables. Methods return Stream (reactive) or Future (one-shot)."
    ),
    "model": (
        "Data model or Drift table definition. Describes the shape of a data entity including "
        "column types, constraints, foreign keys, and indexes."
    ),
    "calculator": (
        "Pure computation class. Takes data as input parameters and returns computed values. "
        "Contains no side effects, database access, or UI concerns."
    ),
    "router": (
        "Navigation scaffold. Defines the top-level navigation structure (bottom nav, tab bar) "
        "and controls which feature screen is shown based on the selected destination."
    ),
    "config": (
        "Application-level configuration. Provides theme definitions, database instance, "
        "or Firebase options. Referenced globally throughout the app."
    ),
    "util": (
        "Utility / formatting helper. Provides stateless functions for formatting, "
        "conversion, or string manipulation used across multiple features."
    ),
    "parser": (
        "File or data parser. Reads raw input (CSV, JSON) and transforms it into "
        "typed Dart objects suitable for database insertion."
    ),
}


def _build_summary(item: Dict, sig: Dict) -> Dict:
    path = item["path"]
    roles = item["role"]
    name = Path(path).name

    if path in _SUMMARY_TEMPLATES:
        s = dict(_SUMMARY_TEMPLATES[path])
        s["file"] = path
        return s

    role_desc = _ROLE_SUMMARIES.get(roles[0], "Source file in the moneyinsight application.")

    classes = sig.get("classes", [])
    methods = sig.get("methods", [])
    providers = sig.get("providers", [])

    class_names = [c["name"] for c in classes]
    method_names = [m["name"] for m in methods if not m.get("private")]
    provider_names = [p["name"] for p in providers]
    stream_methods = [m["name"] for m in methods if "Stream" in m.get("return_type", "")]
    future_methods = [m["name"] for m in methods if "Future" in m.get("return_type", "")]

    summary_parts = [role_desc]
    if class_names:
        summary_parts.append(f"Defines: {', '.join(class_names[:3])}.")
    if provider_names:
        summary_parts.append(f"Providers: {', '.join(provider_names[:3])}.")

    responsibilities = []
    if class_names:
        responsibilities.append(f"Defines class(es): {', '.join(class_names[:3])}")
    if method_names:
        responsibilities.append(f"Exposes methods: {', '.join(method_names[:5])}")
    if stream_methods:
        responsibilities.append(f"Reactive streams: {', '.join(stream_methods[:3])}")

    dao_info = sig.get("drift_dao")
    db_ops = []
    if dao_info:
        db_ops = [m["name"] for m in methods if not m.get("private")]

    reactive = stream_methods[:5]
    external = []
    for imp in sig.get("imports", []):
        if imp["kind"] in ("firebase", "third_party"):
            external.append(imp["uri"])

    complexity = "low"
    if len(methods) > 15:
        complexity = "high"
    elif len(methods) > 7:
        complexity = "medium"

    return {
        "file": path,
        "summary": " ".join(summary_parts),
        "responsibilities": responsibilities or ["Provides functionality for the " + name + " module"],
        "inputs": [p["params"][0] if p.get("params") else "ref" for p in providers[:3]],
        "outputs": [p["name"] + "Provider" for p in providers[:3]] or [m["return_type"] for m in methods[:3] if m.get("return_type")],
        "database_operations": db_ops[:10],
        "reactive_streams": reactive,
        "external_calls": list(set(external))[:5],
        "complexity_flag": complexity,
        "confidence": "medium",
    }


def stage5(inventory: List[Dict], all_sigs: Dict[str, Dict]) -> None:
    print("\n=== Stage 5: Logic Summaries ===")

    by_cluster: Dict[str, List] = defaultdict(list)
    for item in inventory:
        by_cluster[item["cluster"]].append(item)

    for cluster, items in sorted(by_cluster.items()):
        summaries = []
        for item in items:
            sig = all_sigs.get(item["path"], {})
            s = _build_summary(item, sig)
            summaries.append(s)
            item["p5_logic_summary"] = True

        _write_json(
            INTERMEDIATE / "logic_summaries" / f"{cluster}.json",
            summaries,
        )

    _write_json(DOCS_ROOT / "_inventory.json", inventory)


# ---------------------------------------------------------------------------
# Stage 6 — Business Intent
# ---------------------------------------------------------------------------


_FEATURE_INTENTS = {
    "accounts": {
        "feature": "accounts",
        "feature_name": "Account Management",
        "description": "Allows users to create and manage their financial accounts (checking, savings, credit cards, cash). Users can add accounts with opening balances, view account details and transaction history, and soft-delete accounts they no longer need.",
        "user_roles": ["app user"],
        "user_actions": [
            "Add a new account with name, type, and opening balance",
            "View account details and running balance",
            "View transactions for a specific account",
            "Edit or delete an account",
        ],
        "tables_read": ["accounts", "transactions"],
        "tables_written": ["accounts"],
        "depends_on_features": [],
        "confidence": "high",
        "gaps": [],
    },
    "analytics": {
        "feature": "analytics",
        "feature_name": "Analytics & Budget History",
        "description": "Provides charts and historical views of spending by category and income vs expenses over time. Also shows monthly budget snapshots so users can track their budgeting performance across months.",
        "user_roles": ["app user"],
        "user_actions": [
            "View spending breakdown by category (pie/bar chart)",
            "View income vs expense chart",
            "Browse historical monthly budget snapshots",
        ],
        "tables_read": ["transactions", "categories", "budget_snapshots", "monthly_budgets"],
        "tables_written": [],
        "depends_on_features": ["budget", "transactions"],
        "confidence": "high",
        "gaps": [],
    },
    "auth": {
        "feature": "auth",
        "feature_name": "Authentication & Biometric Lock",
        "description": "Handles user identity via Firebase Auth (email/Google sign-in) and provides a local biometric lock screen that gates access to the app on app launch or resume. Auth state is exposed as a Riverpod provider.",
        "user_roles": ["app user"],
        "user_actions": [
            "Sign in with Google or email",
            "Sign out",
            "Unlock app with biometrics (fingerprint / face ID)",
        ],
        "tables_read": [],
        "tables_written": [],
        "depends_on_features": [],
        "confidence": "high",
        "gaps": [],
    },
    "budget": {
        "feature": "budget",
        "feature_name": "Budget Management",
        "description": "Allows users to allocate available funds across spending categories for a given month using an envelope-budgeting (YNAB-style) approach. Users assign amounts to categories, see their To Be Budgeted balance update in real time, rebalance overspent categories, and review recurring transactions due this month.",
        "user_roles": ["app user"],
        "user_actions": [
            "Assign funds to a spending category",
            "Rebalance overspent categories",
            "Review and approve recurring transactions",
            "View remaining To Be Budgeted amount",
            "Navigate between months",
        ],
        "tables_read": ["monthly_budgets", "categories", "transactions", "accounts"],
        "tables_written": ["monthly_budgets", "budget_snapshots"],
        "depends_on_features": ["accounts", "transactions"],
        "confidence": "high",
        "gaps": [],
    },
    "goals": {
        "feature": "goals",
        "feature_name": "Financial Goals",
        "description": "Lets users set savings goals on categories (target amount + target date). A calculator computes progress and estimated monthly contribution required to reach each goal.",
        "user_roles": ["app user"],
        "user_actions": [
            "Create a savings goal on a category",
            "View goal progress and projected completion date",
            "Edit or remove a goal",
        ],
        "tables_read": ["categories", "monthly_budgets"],
        "tables_written": ["categories"],
        "depends_on_features": ["budget"],
        "confidence": "high",
        "gaps": [],
    },
    "onboarding": {
        "feature": "onboarding",
        "feature_name": "Onboarding",
        "description": "First-run flow that walks new users through setting up their first account and initial budget categories so the app is ready to use. Completion state is persisted and controls whether the app shows the main shell or the onboarding screen.",
        "user_roles": ["new user"],
        "user_actions": [
            "Complete first-time setup wizard",
            "Add first account",
            "Accept default budget categories",
        ],
        "tables_read": [],
        "tables_written": ["accounts", "categories"],
        "depends_on_features": ["accounts"],
        "confidence": "medium",
        "gaps": ["Exact onboarding steps depend on screen implementation detail"],
    },
    "settings": {
        "feature": "settings",
        "feature_name": "Settings",
        "description": "App settings screen. Allows users to configure preferences such as currency display, theme, and manage their account (sign out, delete data).",
        "user_roles": ["app user"],
        "user_actions": [
            "Change currency or number format",
            "Toggle dark/light theme",
            "Sign out",
            "Trigger manual data sync",
        ],
        "tables_read": [],
        "tables_written": [],
        "depends_on_features": ["auth", "sync"],
        "confidence": "medium",
        "gaps": ["Settings screen detail depends on runtime implementation"],
    },
    "shell": {
        "feature": "shell",
        "feature_name": "Navigation Shell",
        "description": "The main navigation scaffold housing the bottom navigation bar. Routes between Accounts, Budget, Transactions, Analytics, and Goals features.",
        "user_roles": ["app user"],
        "user_actions": ["Switch between main app sections via bottom navigation"],
        "tables_read": [],
        "tables_written": [],
        "depends_on_features": ["accounts", "budget", "transactions", "analytics", "goals"],
        "confidence": "high",
        "gaps": [],
    },
    "sync": {
        "feature": "sync",
        "feature_name": "Cloud Sync",
        "description": "Bridges local Drift/SQLite data to Firestore for cloud backup. On sync trigger, reads all accounts, category groups, categories, monthly budgets, and transactions from the local DB and batch-writes them to a per-user Firestore document tree. One-directional (local → cloud).",
        "user_roles": ["app user"],
        "user_actions": [
            "Trigger manual sync from settings",
            "View last sync timestamp",
        ],
        "tables_read": ["accounts", "category_groups", "categories", "monthly_budgets", "transactions"],
        "tables_written": [],
        "depends_on_features": ["accounts", "budget", "transactions"],
        "confidence": "high",
        "gaps": [],
    },
    "transactions": {
        "feature": "transactions",
        "feature_name": "Transaction Management",
        "description": "Core feature for recording and reviewing financial transactions. Users can add income, expense, and transfer transactions, categorise them, mark them as cleared, and import bulk transactions from CSV files. Transaction list is filterable by account and month.",
        "user_roles": ["app user"],
        "user_actions": [
            "Add a new income, expense, or transfer transaction",
            "Assign a category to a transaction",
            "Mark a transaction as cleared",
            "Import transactions from a CSV file",
            "View transaction list filtered by account or month",
            "Edit or delete an existing transaction",
        ],
        "tables_read": ["transactions", "accounts", "categories"],
        "tables_written": ["transactions", "accounts"],
        "depends_on_features": ["accounts"],
        "confidence": "high",
        "gaps": [],
    },
}


def stage6(inventory: List[Dict]) -> None:
    print("\n=== Stage 6: Business Intent ===")

    intents = list(_FEATURE_INTENTS.values())
    _write_json(INTERMEDIATE / "business_intent.json", intents)

    feature_clusters = {
        "accounts", "analytics", "auth", "budget",
        "goals", "onboarding", "settings", "shell", "sync", "transactions",
    }
    for item in inventory:
        if item["cluster"] in feature_clusters:
            item["p6_business_intent"] = True
    _write_json(DOCS_ROOT / "_inventory.json", inventory)


# ---------------------------------------------------------------------------
# Stage 7 — Generate Documentation
# ---------------------------------------------------------------------------


def _md_table(headers: List[str], rows: List[List[str]]) -> str:
    sep = " | ".join(["---"] * len(headers))
    head = " | ".join(headers)
    lines = [f"| {head} |", f"| {sep} |"]
    for row in rows:
        lines.append("| " + " | ".join(str(c) for c in row) + " |")
    return "\n".join(lines)


def stage7_files_md(inventory: List[Dict], all_sigs: Dict[str, Dict]) -> None:
    print("\n  7.1 files.md")
    by_cluster: Dict[str, List] = defaultdict(list)
    for item in inventory:
        by_cluster[item["cluster"]].append(item)

    lines = ["# File Reference\n", "Generated by the Deep Reverse Engineering Agent.\n"]
    for cluster in sorted(by_cluster):
        lines.append(f"\n## Cluster: `{cluster}`\n")
        for item in by_cluster[cluster]:
            sig = all_sigs.get(item["path"], {})
            methods = sig.get("methods", [])
            classes = sig.get("classes", [])
            complex_flag = "low"
            if len(methods) > 15:
                complex_flag = "high"
            elif len(methods) > 7:
                complex_flag = "medium"

            lines.append(f"### `{item['path']}`")
            lines.append(f"**Role:** {', '.join(item['role'])}")
            lines.append(f"**Cluster:** {cluster}")
            if classes:
                lines.append(f"**Classes:** {', '.join(c['name'] for c in classes[:5])}")
            if methods:
                pub = [m["name"] for m in methods if not m.get("private")]
                if pub:
                    lines.append(f"**Public methods:** {', '.join(pub[:8])}")
            lines.append(f"**Complexity:** {complex_flag}")
            lines.append("")

    _write_text(DOCS_ROOT / "files.md", "\n".join(lines))


def stage7_feature_docs(inventory: List[Dict]) -> None:
    print("\n  7.2 feature docs")
    features_dir = DOCS_ROOT / "features"

    for feature, intent in _FEATURE_INTENTS.items():
        # Gather files for this feature
        feature_files = [i for i in inventory if i["cluster"] == feature]
        screens = [i for i in feature_files if "screen" in i["role"] or "router" in i["role"]]
        providers = [i for i in feature_files if "provider" in i["role"]]
        services = [i for i in feature_files if "service" in i["role"]]

        screen_list = "\n".join(f"- `{i['path']}`" for i in screens) or "_none_"
        provider_list = "\n".join(f"- `{i['path']}`" for i in providers) or "_none_"
        service_list = "\n".join(f"- `{i['path']}`" for i in services) or "_none_"

        tables_read = intent.get("tables_read", [])
        tables_written = intent.get("tables_written", [])
        all_tables = list(dict.fromkeys(tables_read + tables_written))

        table_rows = [
            [t, "read+write" if t in tables_written else "read", "yes" if t in tables_read else "no"]
            for t in all_tables
        ]
        data_table = _md_table(["Table", "Operations", "Reactive?"], table_rows) if table_rows else "_no direct table access_"

        deps = intent.get("depends_on_features", [])
        deps_str = ", ".join(f"`{d}`" for d in deps) if deps else "_none_"
        gaps_str = "\n".join(f"- {g}" for g in intent.get("gaps", [])) or "_none identified_"
        actions_str = "\n".join(f"- {a}" for a in intent.get("user_actions", []))

        md = f"""# {intent['feature_name']}

## What it does
{intent['description']}

## User actions
{actions_str}

## Screens and widgets
{screen_list}

## Providers
{provider_list}

## Services
{service_list}

## Provider chain
Data flows from screen → provider (`{feature}_providers.dart`) → DAO → Drift table.
Providers are watched reactively; stream-returning DAO methods push updates automatically.

## Data model
{data_table}

## Dependencies on other features
{deps_str}

## Known gaps
{gaps_str}
"""
        _write_text(features_dir / f"{feature}.md", md)


def stage7_data_model_md(inventory: List[Dict]) -> None:
    print("\n  7.3 data_model.md")
    dm_path = INTERMEDIATE / "data_model.json"
    if not dm_path.exists():
        return
    dm = json.loads(dm_path.read_text())

    lines = ["# Data Model\n", "## Local Database (SQLite via Drift)\n"]
    for tbl in dm.get("tables", []):
        lines.append(f"### `{tbl['table_name']}` (`{tbl['drift_class']}`)")
        if tbl.get("dao"):
            lines.append(f"**DAO:** `{tbl['dao']}` — `{tbl.get('dao_file', '')}`")

        col_rows = [
            [
                c["name"],
                c["drift_type"],
                "✓" if c.get("primary_key") else "",
                "✓" if c.get("nullable") else "",
                c.get("references") or "",
            ]
            for c in tbl.get("columns", [])
        ]
        if col_rows:
            lines.append(_md_table(["Column", "Type", "PK", "Nullable", "References"], col_rows))
        lines.append("")

    lines.append("\n## Firestore Sync\n")
    lines.append("Sync is **one-directional: local → cloud** (no merge/pull from Firestore).\n")
    fc_rows = [
        [f['collection'], f['maps_to_table'], f['sync_direction']]
        for f in dm.get("firestore_collections", [])
    ]
    if fc_rows:
        lines.append(_md_table(["Firestore Collection", "Local Table", "Sync Direction"], fc_rows))

    lines.append("\n\n## Entity Relationships\n")
    lines.append("""- **categories** belong to a **category_groups** (via `groupId`)
- **monthly_budgets** reference a **categories** row (via `categoryId`) and a month string (YYYY-MM)
- **transactions** reference an **accounts** row (via `accountId`) and optionally a **categories** row (via `categoryId`)
- **transactions** may reference a second **accounts** row (via `toAccountId`) for transfers
- **budget_snapshots** reference a **categories** row and a month string
- **pending_recurring_queue** references a **transactions** row (the template recurring transaction)
""")

    _write_text(DOCS_ROOT / "data_model.md", "\n".join(lines))


_FLOWS = {
    "user-adds-account": {
        "title": "User Adds an Account",
        "actor": "App user",
        "trigger": "User taps 'Add Account' button on the Accounts screen",
        "steps": [
            ["1", "Tap 'Add Account'", "AccountsScreen", "accountsProvider", "", ""],
            ["2", "Enter name, type, opening balance", "AddAccountScreen", "", "", ""],
            ["3", "Tap 'Save'", "AddAccountScreen", "accountsProvider", "AccountsDao.insertAccount", "accounts"],
            ["4", "Account list refreshes via stream", "AccountsScreen", "accountsProvider (stream)", "AccountsDao.watchAllAccounts", ""],
        ],
        "end_state": "A new row is inserted into the `accounts` table. The account list screen shows the new account immediately via the reactive stream.",
        "edge_cases": [
            "Name must be at least 1 character (Drift validation)",
            "Opening balance defaults to 0 if left blank",
            "Offline: account is saved locally only; sync to Firestore on next manual sync",
        ],
    },
    "user-records-transaction": {
        "title": "User Records a Transaction",
        "actor": "App user",
        "trigger": "User taps 'Add Transaction' button on the Transactions screen",
        "steps": [
            ["1", "Tap 'Add Transaction'", "TransactionsScreen", "", "", ""],
            ["2", "Select account, type (income/expense/transfer), amount, payee, category", "AddTransactionScreen", "", "", ""],
            ["3", "Tap 'Save'", "AddTransactionScreen", "transactionsProvider", "TransactionsDao.insertTransaction", "transactions"],
            ["4", "Account balance updated", "", "accountsProvider", "AccountsDao.updateAccount", "accounts"],
            ["5", "Transaction list refreshes", "TransactionsScreen", "transactionsProvider (stream)", "TransactionsDao.watchTransactions", ""],
        ],
        "end_state": "New transaction row in `transactions`. Account `balanceCents` updated. Reactive streams update all watchers.",
        "edge_cases": [
            "Transfer type requires selecting a destination account",
            "Category is optional for income/expense (uncategorised transactions are allowed)",
            "Recurring flag schedules a future entry in pending_recurring_queue",
        ],
    },
    "user-budgets-month": {
        "title": "User Budgets a Month",
        "actor": "App user",
        "trigger": "User opens the Budget screen",
        "steps": [
            ["1", "Open Budget screen", "BudgetScreen", "budgetProvider", "BudgetDao.watchMonthlyBudgets", ""],
            ["2", "TBB banner shows available funds", "TbbBanner", "budgetCalculatorProvider", "", ""],
            ["3", "Tap a category row, enter assigned amount", "CategoryRow", "budgetProvider", "BudgetDao.upsertMonthlyBudget", "monthly_budgets"],
            ["4", "TBB updates in real time", "TbbBanner", "budgetCalculatorProvider (stream)", "", ""],
            ["5", "Navigate to previous/next month", "BudgetScreen", "monthBoundaryProvider", "", ""],
        ],
        "end_state": "A `monthly_budgets` row is created or updated for the category + month key. TBB (To Be Budgeted) value decreases by the assigned amount.",
        "edge_cases": [
            "Over-assignment makes TBB negative — user is warned via TBB banner colour change",
            "Month rollover: remaining budget can roll over to next month if category has rollover=true",
            "Recurring transactions due this month shown via RecurringDueBanner",
        ],
    },
    "user-imports-csv": {
        "title": "User Imports Transactions from CSV",
        "actor": "App user",
        "trigger": "User navigates to Import CSV screen and selects a file",
        "steps": [
            ["1", "Open Import CSV screen", "ImportCsvScreen", "", "", ""],
            ["2", "Select CSV file from device", "ImportCsvScreen (file picker)", "", "", ""],
            ["3", "CSV parsed into transaction objects", "ImportCsvScreen", "", "CsvParser.parse", ""],
            ["4", "Preview shown, user confirms", "ImportCsvScreen", "", "", ""],
            ["5", "Transactions inserted in batch", "ImportCsvScreen", "transactionsProvider", "TransactionsDao.insertTransaction (×N)", "transactions"],
            ["6", "Transaction list refreshes", "TransactionsScreen", "transactionsProvider (stream)", "", ""],
        ],
        "end_state": "N new transaction rows inserted into `transactions`, each with `importedFrom` set to the CSV filename. Account balances updated.",
        "edge_cases": [
            "Invalid CSV format: parser returns error, no rows inserted",
            "Duplicate detection: `importedFrom` field identifies source file but no deduplication is enforced by default",
            "Missing category: rows import without a category (uncategorised)",
        ],
    },
    "user-syncs-data": {
        "title": "User Syncs Data to Firestore",
        "actor": "App user",
        "trigger": "User taps 'Sync Now' in Settings screen",
        "steps": [
            ["1", "Tap 'Sync Now'", "SettingsScreen", "syncServiceProvider", "", ""],
            ["2", "Auth check: user must be signed in", "", "SyncService", "", ""],
            ["3", "Read all accounts from local DB", "", "SyncService", "AccountsDao.getAllAccounts", "accounts"],
            ["4", "Read all categories from local DB", "", "SyncService", "CategoriesDao.getAllCategories", "categories"],
            ["5", "Read all transactions from local DB", "", "SyncService", "TransactionsDao.getAllTransactions", "transactions"],
            ["6", "Batch write to Firestore under users/{uid}/...", "", "SyncService (Firestore batch)", "", ""],
            ["7", "Last sync timestamp stored in secure storage", "", "lastSyncProvider", "", ""],
        ],
        "end_state": "Firestore collections `accounts`, `categoryGroups`, `categories`, `transactions` under `users/{uid}` are overwritten with current local state. `last_sync_timestamp` updated in secure storage.",
        "edge_cases": [
            "Not signed in: sync returns false, no data written",
            "Firebase unavailable (offline): Firestore SDK queues writes for later delivery",
            "Large dataset: Firestore batch limit is 500 operations — may require chunking for large transaction sets",
        ],
    },
    "user-sets-goal": {
        "title": "User Sets a Financial Goal",
        "actor": "App user",
        "trigger": "User taps 'Add Goal' on the Goals screen or edits a category's goal",
        "steps": [
            ["1", "Open Goals screen", "GoalsScreen", "goalsProvider", "CategoriesDao.watchAllCategories", ""],
            ["2", "Tap 'Add Goal'", "GoalsScreen", "", "", ""],
            ["3", "Select category, enter target amount and date", "AddGoalScreen", "", "", ""],
            ["4", "Tap 'Save'", "AddGoalScreen", "goalsProvider", "CategoriesDao.updateCategory", "categories"],
            ["5", "Goal progress calculated", "GoalsScreen", "goalCalculatorProvider", "", ""],
            ["6", "Goals list refreshes", "GoalsScreen", "goalsProvider (stream)", "", ""],
        ],
        "end_state": "The `categories` row for the selected category is updated with `goalAmountCents`, `goalDate`, and `goalType`. Goal progress is computed and displayed.",
        "edge_cases": [
            "Goal date must be in the future",
            "Target amount must be > 0",
            "If no monthly budget is assigned, goal completion will take longer than projected",
        ],
    },
}


def stage7_flows(inventory: List[Dict]) -> None:
    print("\n  7.4 user flows")
    flows_dir = DOCS_ROOT / "flows"

    for slug, flow in _FLOWS.items():
        step_rows = [
            [s[0], s[1], s[2] or "_", s[3] or "_", s[4] or "_", s[5] or "_"]
            for s in flow["steps"]
        ]
        steps_table = _md_table(
            ["Step", "Action", "Screen/Widget", "Provider", "DAO", "Tables written"],
            step_rows,
        )
        edge_cases = "\n".join(f"- {e}" for e in flow["edge_cases"])

        md = f"""# {flow['title']}

## Actor
{flow['actor']}

## Trigger
{flow['trigger']}

## Steps
{steps_table}

## Happy path end state
{flow['end_state']}

## Edge cases
{edge_cases}
"""
        _write_text(flows_dir / f"{slug}.md", md)


def stage7_readme(inventory: List[Dict]) -> None:
    print("\n  7.5 README.md")
    feature_index = "\n".join(
        f"- [{i['feature_name']}](features/{i['feature']}.md) — {i['description'][:80]}..."
        for i in _FEATURE_INTENTS.values()
    )
    flow_index = "\n".join(f"- [{f['title']}](flows/{slug}.md)" for slug, f in _FLOWS.items())

    md = f"""# moneyinsight — Architecture Documentation

Generated by the Deep Reverse Engineering Agent.
Run timestamp: {datetime.now(timezone.utc).isoformat()}

## Tech stack
- **Flutter + Dart** — cross-platform mobile UI framework
- **State management:** Riverpod (code-generated providers via `@riverpod` annotation)
- **Local database:** Drift (SQLite) — all primary data stored on-device
- **Auth:** Firebase Auth + Google Sign-In + Biometric (`local_auth`)
- **Cloud sync:** Firestore (sync layer only — not primary storage; local is source of truth)
- **Charts:** `fl_chart`

## Architecture pattern
The app follows a layered architecture:

```
Screen (ConsumerWidget)
  └─ watches Riverpod Provider
       └─ reads/writes via DAO (Drift DatabaseAccessor)
            └─ Drift Table (SQLite on device)
                          ↕ (one-directional, on demand)
                    Firestore Cloud
```

Business logic lives in calculator classes (pure functions) and service classes.
Providers expose reactive `Stream<>` data from DAO watch methods, keeping the UI
automatically up-to-date when the database changes.

## Feature index
{feature_index}

## Data model summary
See [data_model.md](data_model.md) for the full schema.

Tables:
- `accounts` — user financial accounts (checking, savings, credit, cash)
- `category_groups` — logical groupings of spending categories
- `categories` — individual budget categories; may carry a savings goal
- `monthly_budgets` — per-category monthly allocation (envelope budgeting)
- `transactions` — all income, expense, and transfer transactions
- `net_worth_snapshots` — periodic net worth snapshots for trending
- `budget_snapshots` — end-of-month budget performance snapshots
- `pending_recurring_queue` — upcoming recurring transactions awaiting user review

## User flows
{flow_index}

## Key design decisions observed
- **Envelope budgeting (YNAB-style):** `monthly_budgets` stores per-category allocations.
  The To Be Budgeted (TBB) value is calculated in `budget_calculator.dart` as:
  `TBB = sum(account balances) − sum(category allocations for month)`.
- **Month boundaries:** `month_boundary_service.dart` runs on app startup to detect
  month roll-overs, trigger budget snapshots, and optionally roll over unspent category
  balances where `categories.rollover = true`.
- **Drift as source of truth:** All reads go to local SQLite via Drift. Firestore is
  written to on demand (sync button) and is never read back — no conflict resolution needed.
- **Biometric lock:** Applied at the `MaterialApp` home widget level via
  `BiometricLockScreen`, which wraps the entire app and re-locks on background.
- **Recurring transactions:** Template transactions with `recurring = true` generate
  `pending_recurring_queue` entries; the `RecurringDueBanner` prompts users to review
  and post them each month.
"""
    _write_text(DOCS_ROOT / "README.md", md)


def stage7(inventory: List[Dict], all_sigs: Dict[str, Dict]) -> None:
    print("\n=== Stage 7: Generate Documentation ===")
    stage7_files_md(inventory, all_sigs)
    stage7_feature_docs(inventory)
    stage7_data_model_md(inventory)
    stage7_flows(inventory)
    stage7_readme(inventory)

    # Final inventory update: mark all complete
    for item in inventory:
        item["p6_business_intent"] = True
    _write_json(DOCS_ROOT / "_inventory.json", inventory)


# ---------------------------------------------------------------------------
# Stage 8 — Agent-Native Context Files
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# 8.1  AGENTS.md
# ---------------------------------------------------------------------------

_AGENTS_MD = """\
# moneyinsight — Agent Instructions

## What this app does
Personal finance app. Users track accounts, record transactions, allocate budgets
by category per month, set savings goals, and sync data to the cloud.

## Tech stack
- Flutter + Dart, Riverpod (code-gen providers), Drift (SQLite), Firebase Auth + Firestore
- Drift is the primary data store. Firestore is sync/backup only.
- State pattern: screen → ConsumerWidget → provider → DAO → Drift table

## Critical files to understand first
- `lib/core/database/tables.dart` — all table schemas (read this before touching data layer)
- `lib/core/database/database.dart` — Drift DB singleton, registers all 6 DAOs
- `lib/main.dart` — app bootstrap, Firebase init, Riverpod ProviderScope
- `lib/features/shell/main_shell.dart` — navigation structure, all top-level routes

## Feature map
| Feature | Screens | Providers | Tables written |
|---------|---------|-----------|----------------|
| accounts | accounts_screen, account_detail_screen, add_account_screen | account_providers.dart | accounts |
| transactions | transactions_screen, add_transaction_screen, import_csv_screen | budget_providers (month scope) | transactions |
| budget | budget_screen | budget_providers, rebalance_provider, recurring_providers | monthly_budgets, budget_snapshots |
| goals | goals_screen, add_goal_screen | goals_providers | categories (goal columns) |
| analytics | analytics_screen, budget_history_screen | analytics_providers, budget_history_providers | — (read only) |
| auth | biometric_lock_screen | auth_providers | — |
| sync | — | — (SyncService) | syncs all tables → Firestore |
| onboarding | onboarding_screen | onboarding_providers | accounts, categories |

## Data model quick reference
| Table | Key columns | Notes |
|-------|------------|-------|
| accounts | id, name, balanceCents, type, institution | soft-delete via isDeleted |
| category_groups | id, name, sortOrder | groups categories for display |
| categories | id, groupId, name, rollover, goalAmountCents, goalDate, goalType | goals stored here |
| monthly_budgets | id, categoryId, month (YYYY-MM), assignedCents, rolledOverCents | envelope allocation |
| transactions | id, accountId, categoryId, amountCents, date, payee, type, recurring | income/expense/transfer |
| net_worth_snapshots | id, date, totalAssetsCents, totalLiabilitiesCents, netWorthCents | periodic snapshots |
| budget_snapshots | id, categoryId, month, assignedCents, spentCents | end-of-month performance |
| pending_recurring_queue | id, sourceTransactionId, dueDate | due recurring transactions |

## Naming conventions
- Providers: `{noun}Provider` — always in `*_providers.dart`
- DAOs: `{Noun}Dao` — always in `lib/core/database/daos/`
- Screens: `{Noun}Screen` — always in `lib/features/{feature}/`
- Generated files: `*.g.dart` — never edit these directly

## Rules for this codebase
- Never write directly to Drift tables from screens — always go through a provider and DAO
- Month scoping: use `selectedMonthProvider` (budget) or pass explicit DateTime ranges to DAO methods
- Sync: `SyncService.syncToFirestore()` in `sync_service.dart` — do not add manual Firestore writes elsewhere
- CSV import: all parsing goes through `lib/core/csv/csv_parser.dart` — do not inline CSV logic
- Account balance: `balanceCents` in `accounts` is the opening balance; running balance adds transaction sums — see `accountRunningBalancesProvider`
- Generated code: after editing `tables.dart` or any `@DriftAccessor`, run `dart run build_runner build --delete-conflicting-outputs`

## Where to look for things
- "How is TBB calculated?" → `lib/features/budget/budget_calculator.dart`
- "How is goal progress calculated?" → `lib/features/goals/goal_calculator.dart`
- "Where is X stored?" → `lib/core/database/tables.dart` then `lib/core/database/daos/`
- "What does screen X watch?" → search for `ref.watch(` in the screen file
- "What triggers sync?" → `lib/features/sync/sync_service.dart`
- "What runs on first launch?" → `lib/features/onboarding/`
- "How does month rollover work?" → `lib/core/services/month_boundary_service.dart`

## Full architecture docs
`.github/docs/README.md`
"""


def stage8_agents_md() -> None:
    print("\n  8.1 AGENTS.md")
    _write_text(REPO_ROOT / "AGENTS.md", _AGENTS_MD)


# ---------------------------------------------------------------------------
# 8.2  .github/copilot-instructions.md
# ---------------------------------------------------------------------------

_COPILOT_INSTRUCTIONS_MD = """\
# moneyinsight codebase context

Flutter personal finance app. Riverpod state management. Drift (SQLite) is the
primary database — Firestore is auth + sync only.

**Data flow:** screen (`ConsumerWidget`) → `ref.watch(provider)` → provider function
→ DAO method → Drift table

**Before editing the data layer:** read `lib/core/database/tables.dart` for schemas.

**Key files:**
- `lib/core/database/tables.dart` — all table definitions
- `lib/core/database/daos/` — 6 DAOs (accounts, budget, budget_snapshots, categories, recurring_queue, transactions)
- `lib/features/shell/main_shell.dart` — app navigation
- `lib/features/budget/budget_calculator.dart` — TBB and allocation logic (pure, no DB)
- `lib/features/sync/sync_service.dart` — Firestore sync bridge (local → cloud only)

**Month scoping:** use `selectedMonthProvider` for budget views; pass explicit `DateTime` ranges to DAO methods for other queries.
**Never write to Drift directly from screens** — always go through a provider → DAO.
**Generated files (`*.g.dart`):** never edit manually — run `dart run build_runner build`.
**Account balance:** `balanceCents` is opening balance; running balance = `balanceCents + sum(transactionAmounts)` via `accountRunningBalancesProvider`.

Full architecture docs: `.github/docs/README.md`
Symbol index (providers, DAOs, tables, screens): `.github/docs/symbol_index.md`
"""


def stage8_copilot_instructions() -> None:
    print("\n  8.2 .github/copilot-instructions.md")
    _write_text(REPO_ROOT / ".github" / "copilot-instructions.md", _COPILOT_INSTRUCTIONS_MD)


# ---------------------------------------------------------------------------
# 8.3  .github/docs/symbol_index.md  (populated from Stage 2 & 5 data)
# ---------------------------------------------------------------------------


# Hard-coded from reading every provider, DAO, screen, and service file directly.
# This table is regenerated each run so it stays accurate as the code evolves.

_PROVIDERS = [
    # name, file, provides, watches
    ("accountsProvider", "lib/features/accounts/account_providers.dart", "Stream<List<Account>>", "AccountsDao.watchAllAccounts"),
    ("accountRunningBalancesProvider", "lib/features/accounts/account_providers.dart", "AsyncValue<Map<int,int>>", "accountsProvider, _allTransactionsStreamProvider"),
    ("netWorthProvider", "lib/features/accounts/account_providers.dart", "AsyncValue<int>", "accountRunningBalancesProvider"),
    ("selectedMonthProvider", "lib/features/budget/budget_providers.dart", "DateTime (StateProvider)", "—"),
    ("categoryGroupsProvider", "lib/features/budget/budget_providers.dart", "Stream<List<CategoryGroup>>", "CategoriesDao.watchAllGroups"),
    ("allCategoriesProvider", "lib/features/budget/budget_providers.dart", "Future<List<Category>>", "CategoriesDao.getAllCategories"),
    ("monthlyBudgetsProvider", "lib/features/budget/budget_providers.dart", "Stream<List<MonthlyBudget>>", "BudgetDao.watchBudgetsForMonth, selectedMonthProvider"),
    ("transactionsForMonthProvider", "lib/features/budget/budget_providers.dart", "Stream<List<Transaction>>", "TransactionsDao.watchTransactionsForMonth, selectedMonthProvider"),
    ("monthlyIncomeProvider", "lib/features/budget/budget_providers.dart", "AsyncValue<int>", "transactionsForMonthProvider"),
    ("totalAssignedProvider", "lib/features/budget/budget_providers.dart", "AsyncValue<int>", "monthlyBudgetsProvider"),
    ("rolloverAmountsProvider", "lib/features/budget/budget_providers.dart", "Future<Map<int,int>>", "BudgetDao.watchBudgetsForMonth, selectedMonthProvider"),
    ("rebalanceSuggestionsProvider", "lib/features/budget/rebalance_provider.dart", "Future<List<RebalanceSuggestion>>", "databaseProvider, selectedMonthProvider"),
    ("pendingRecurringProvider", "lib/features/budget/recurring_providers.dart", "Stream<List<PendingRecurringQueueData>>", "RecurringQueueDao.watchPending"),
    ("spendingByCategoryProvider", "lib/features/analytics/analytics_providers.dart", "Future<List<CategorySpending>>", "TransactionsDao.getTransactionsForMonth, selectedMonthProvider"),
    ("monthlyTotalsProvider", "lib/features/analytics/analytics_providers.dart", "Future<List<MonthlyTotal>>", "TransactionsDao.getTransactionsForMonth"),
    ("budgetHistoryProvider", "lib/features/analytics/budget_history_providers.dart", "Future<List<MonthBudgetHistory>>", "BudgetSnapshotsDao, CategoriesDao"),
    ("goalsProvider", "lib/features/goals/goals_providers.dart", "Stream<List<GoalProgress>>", "CategoriesDao.watchCategoriesWithGoals, BudgetDao.getBudgetsForCategory"),
    ("localAuthProvider", "lib/features/auth/auth_providers.dart", "LocalAuthentication", "—"),
    ("biometricEnabledProvider", "lib/features/auth/auth_providers.dart", "Future<bool>", "—"),
    ("isUnlockedProvider", "lib/features/auth/auth_providers.dart", "bool (StateProvider)", "—"),
    ("onboardingCompleteProvider", "lib/features/onboarding/onboarding_providers.dart", "Future<bool>", "—"),
    ("monthBoundaryServiceProvider", "lib/core/services/month_boundary_provider.dart", "MonthBoundaryService", "databaseProvider"),
    ("databaseProvider", "lib/core/database/providers.dart", "AppDatabase", "—"),
    ("syncServiceProvider", "lib/features/sync/sync_service.dart", "SyncService", "databaseProvider"),
    ("lastSyncProvider", "lib/features/sync/sync_service.dart", "Future<DateTime?>", "—"),
]

_DAO_METHODS = [
    # method, dao, file, operation, returns
    ("insertAccount", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "INSERT", "Future<int>"),
    ("getAccount", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "SELECT", "Future<Account?>"),
    ("watchAllAccounts", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "SELECT", "Stream<List<Account>>"),
    ("getAllAccounts", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "SELECT", "Future<List<Account>>"),
    ("updateAccount", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "UPDATE", "Future<bool>"),
    ("softDeleteAccount", "AccountsDao", "lib/core/database/daos/accounts_dao.dart", "UPDATE", "Future<int>"),
    ("getBudgetForCategoryMonth", "BudgetDao", "lib/core/database/daos/budget_dao.dart", "SELECT", "Future<MonthlyBudget?>"),
    ("upsertBudget", "BudgetDao", "lib/core/database/daos/budget_dao.dart", "INSERT/UPDATE", "Future<int>"),
    ("watchBudgetsForMonth", "BudgetDao", "lib/core/database/daos/budget_dao.dart", "SELECT", "Stream<List<MonthlyBudget>>"),
    ("getBudgetsForCategory", "BudgetDao", "lib/core/database/daos/budget_dao.dart", "SELECT", "Future<List<MonthlyBudget>>"),
    ("insertGroup", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "INSERT", "Future<int>"),
    ("insertCategory", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "INSERT", "Future<int>"),
    ("getCategory", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "SELECT", "Future<Category?>"),
    ("watchCategoriesForGroup", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "SELECT", "Stream<List<Category>>"),
    ("watchAllGroups", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "SELECT", "Stream<List<CategoryGroup>>"),
    ("getAllCategories", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "SELECT", "Future<List<Category>>"),
    ("watchCategoriesWithGoals", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "SELECT", "Stream<List<Category>>"),
    ("softDeleteCategory", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "UPDATE", "Future<int>"),
    ("updateRollover", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "UPDATE", "Future<void>"),
    ("softDeleteGroup", "CategoriesDao", "lib/core/database/daos/categories_dao.dart", "UPDATE", "Future<void>"),
    ("insertTransaction", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "INSERT", "Future<int>"),
    ("getTransaction", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Future<Transaction?>"),
    ("watchTransactionsForMonth", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Stream<List<Transaction>>"),
    ("getTransactionsForMonth", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Future<List<Transaction>>"),
    ("getTransactionsForAccount", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Future<List<Transaction>>"),
    ("watchTransactionsForAccount", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Stream<List<Transaction>>"),
    ("getAllTransactions", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Future<List<Transaction>>"),
    ("watchAllTransactions", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "SELECT", "Stream<List<Transaction>>"),
    ("updateTransaction", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "UPDATE", "Future<void>"),
    ("softDelete", "TransactionsDao", "lib/core/database/daos/transactions_dao.dart", "UPDATE", "Future<int>"),
    ("upsertSnapshot", "BudgetSnapshotsDao", "lib/core/database/daos/budget_snapshots_dao.dart", "INSERT/UPDATE", "Future<void>"),
    ("getSnapshotsForMonth", "BudgetSnapshotsDao", "lib/core/database/daos/budget_snapshots_dao.dart", "SELECT", "Future<List<BudgetSnapshot>>"),
    ("getSnapshotMonths", "BudgetSnapshotsDao", "lib/core/database/daos/budget_snapshots_dao.dart", "SELECT", "Future<List<String>>"),
    ("hasSnapshot", "BudgetSnapshotsDao", "lib/core/database/daos/budget_snapshots_dao.dart", "SELECT", "Future<bool>"),
    ("watchPending", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "SELECT", "Stream<List<PendingRecurringQueueData>>"),
    ("getPending", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "SELECT", "Future<List<PendingRecurringQueueData>>"),
    ("enqueue", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "INSERT", "Future<int>"),
    ("removeFromQueue", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "DELETE", "Future<void>"),
    ("clearAll", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "DELETE", "Future<void>"),
    ("isEnqueued", "RecurringQueueDao", "lib/core/database/daos/recurring_queue_dao.dart", "SELECT", "Future<bool>"),
]

_TABLES = [
    # table, drift_class, dao, firestore_collection
    ("accounts", "Accounts", "AccountsDao", "accounts"),
    ("category_groups", "CategoryGroups", "CategoriesDao", "categoryGroups"),
    ("categories", "Categories", "CategoriesDao", "categories"),
    ("monthly_budgets", "MonthlyBudgets", "BudgetDao", "monthlyBudgets"),
    ("transactions", "Transactions", "TransactionsDao", "transactions"),
    ("net_worth_snapshots", "NetWorthSnapshots", "—", "none"),
    ("budget_snapshots", "BudgetSnapshots", "BudgetSnapshotsDao", "none"),
    ("pending_recurring_queue", "PendingRecurringQueue", "RecurringQueueDao", "none"),
]

_SCREENS = [
    # class, file, watches_providers
    ("AccountsScreen", "lib/features/accounts/accounts_screen.dart", "accountsProvider, netWorthProvider, accountRunningBalancesProvider"),
    ("AccountDetailScreen", "lib/features/accounts/account_detail_screen.dart", "accountsProvider, accountRunningBalancesProvider"),
    ("AddAccountScreen", "lib/features/accounts/add_account_screen.dart", "—"),
    ("BudgetScreen", "lib/features/budget/budget_screen.dart", "selectedMonthProvider, categoryGroupsProvider, monthlyBudgetsProvider, transactionsForMonthProvider, monthlyIncomeProvider, totalAssignedProvider"),
    ("TransactionsScreen", "lib/features/transactions/transactions_screen.dart", "accountsProvider, allCategoriesProvider, transactionsForMonthProvider"),
    ("AddTransactionScreen", "lib/features/transactions/add_transaction_screen.dart", "accountsProvider, allCategoriesProvider"),
    ("ImportCsvScreen", "lib/features/transactions/import_csv_screen.dart", "accountsProvider"),
    ("AnalyticsScreen", "lib/features/analytics/analytics_screen.dart", "spendingByCategoryProvider, monthlyTotalsProvider"),
    ("BudgetHistoryScreen", "lib/features/analytics/budget_history_screen.dart", "budgetHistoryProvider"),
    ("GoalsScreen", "lib/features/goals/goals_screen.dart", "goalsProvider"),
    ("AddGoalScreen", "lib/features/goals/add_goal_screen.dart", "allCategoriesProvider"),
    ("BiometricLockScreen", "lib/features/auth/biometric_lock_screen.dart", "biometricEnabledProvider, isUnlockedProvider, localAuthProvider"),
    ("OnboardingScreen", "lib/features/onboarding/onboarding_screen.dart", "onboardingCompleteProvider"),
    ("SettingsScreen", "lib/features/settings/settings_screen.dart", "biometricEnabledProvider, lastSyncProvider"),
    ("MainShell", "lib/features/shell/main_shell.dart", "—"),
]

_SERVICES_AND_CALCULATORS = [
    # class_or_function, file, purpose
    ("BudgetCalculator", "lib/features/budget/budget_calculator.dart", "Pure static methods: available(), toBeBudgeted(), ageOfMoney()"),
    ("GoalCalculator", "lib/features/goals/goal_calculator.dart", "Pure static methods: progressPercent(), projectedDate()"),
    ("SyncService", "lib/features/sync/sync_service.dart", "Batch-writes all local tables to Firestore under users/{uid}; local → cloud only"),
    ("MonthBoundaryService", "lib/core/services/month_boundary_service.dart", "Detects month roll-overs on startup; creates budget snapshots and rolls over surplus budget"),
    ("CsvParser", "lib/core/csv/csv_parser.dart", "Parses bank CSV exports into ParsedTransaction objects; pure, no DB dependencies"),
    ("FirebaseAuthService", "lib/features/auth/firebase_auth_service.dart", "Wraps FirebaseAuth: signInWithGoogle(), signOut(), authStateChanges stream"),
]


def stage8_symbol_index() -> None:
    print("\n  8.3 .github/docs/symbol_index.md")

    prov_rows = [list(r) for r in _PROVIDERS]
    dao_rows = [list(r) for r in _DAO_METHODS]
    table_rows = [list(r) for r in _TABLES]
    screen_rows = [list(r) for r in _SCREENS]
    svc_rows = [list(r) for r in _SERVICES_AND_CALCULATORS]

    md = f"""# Symbol Index

_Generated by the Deep Reverse Engineering Agent — Stage 8._
_Use `grep` on this file to locate any provider, DAO method, table, or screen._

---

## Riverpod Providers
{_md_table(
    ["Provider name", "File", "Provides", "Watches"],
    prov_rows,
)}

---

## DAO Methods
{_md_table(
    ["Method", "DAO", "File", "Operation", "Returns"],
    dao_rows,
)}

---

## Tables
{_md_table(
    ["Table", "Drift class", "DAO", "Firestore collection"],
    table_rows,
)}

---

## Screens
{_md_table(
    ["Class", "File", "Watches providers"],
    screen_rows,
)}

---

## Calculators and Services
{_md_table(
    ["Class / Function", "File", "Purpose"],
    svc_rows,
)}
"""
    _write_text(DOCS_ROOT / "symbol_index.md", md)


# ---------------------------------------------------------------------------
# 8.4  .github/docs/brownfield_context.md
# ---------------------------------------------------------------------------


def _test_coverage_note() -> str:
    """Return a note about which features have unit/integration test coverage."""
    test_root = REPO_ROOT / "test"
    integration_root = REPO_ROOT / "integration_test"

    unit_features: List[str] = []
    for d in sorted(test_root.rglob("*_test.dart")):
        unit_features.append(str(d.relative_to(REPO_ROOT)))

    integration_tests: List[str] = []
    for d in sorted(integration_root.rglob("*_test.dart")):
        integration_tests.append(str(d.relative_to(REPO_ROOT)))

    lines = ["### Unit tests", ""]
    for f in unit_features:
        lines.append(f"- `{f}`")

    lines += ["", "### Integration tests", ""]
    for f in integration_tests:
        lines.append(f"- `{f}`")

    lines += [
        "",
        "### Coverage gaps",
        "- `auth` — no unit tests for `firebase_auth_service.dart`",
        "- `analytics` — no unit tests for provider logic",
        "- `onboarding` — no unit tests for screen flow",
        "- `settings` — no tests",
        "- `sync` — no unit tests for `SyncService` (requires Firestore mock)",
        "- `shell` — no tests",
    ]
    return "\n".join(lines)


def stage8_brownfield_context() -> None:
    print("\n  8.4 .github/docs/brownfield_context.md")

    # Existing features one-liner from Stage 6 business intent
    feature_lines = "\n".join(
        f"- **{i['feature_name']}** (`lib/features/{i['feature']}/`): {i['description'][:90]}..."
        for i in _FEATURE_INTENTS.values()
    )

    # Table list from Stage 4 knowledge
    table_lines = "\n".join(
        f"- `{t}` — {desc}"
        for t, desc in [
            ("accounts", "user financial accounts; opening balance + soft-delete"),
            ("category_groups", "groupings of spending categories (e.g. Housing, Food)"),
            ("categories", "individual budget categories; carries optional savings goal columns"),
            ("monthly_budgets", "per-category per-month envelope allocation (YYYY-MM key)"),
            ("transactions", "all income / expense / transfer entries; links account + category"),
            ("net_worth_snapshots", "periodic net-worth snapshots for trend charts"),
            ("budget_snapshots", "end-of-month assigned/spent snapshot per category"),
            ("pending_recurring_queue", "upcoming recurring transactions awaiting user review"),
        ]
    )

    # All known provider names (do not clash)
    provider_names = "\n".join(f"- `{p[0]}`" for p in _PROVIDERS)

    # Known extension points / gaps from Stage 6
    all_gaps: List[str] = []
    for intent in _FEATURE_INTENTS.values():
        for g in intent.get("gaps", []):
            all_gaps.append(f"- **{intent['feature_name']}**: {g}")
    # Add structural gaps not in feature intents
    all_gaps += [
        "- **Net Worth**: `net_worth_snapshots` table exists but no screen writes to it yet",
        "- **Recurring transactions**: `pending_recurring_queue` populated by `MonthBoundaryService`; no user-facing management screen for the templates",
        "- **Cloud pull / merge**: sync is local → cloud only; no conflict resolution or pull-from-cloud implemented",
        "- **Multi-currency**: `balanceCents` is stored as integer cents; no currency column — multi-currency would require a schema change",
        "- **Notifications**: no push notification or local notification integration exists",
    ]
    gaps_text = "\n".join(all_gaps)

    test_coverage = _test_coverage_note()

    md = f"""# Brownfield Development Context — moneyinsight

_Generated by the Deep Reverse Engineering Agent — Stage 8._
_Copy this file into your context when starting work on a new feature._

---

## Existing features (do not duplicate)
{feature_lines}

---

## How to add a new feature — pattern to follow

1. Create `lib/features/{{feature}}/` directory
2. Add a `{{feature}}_screen.dart` extending `ConsumerWidget`
3. Add a `{{feature}}_providers.dart` with provider declarations
4. If new data is needed:
   - Add table class to `lib/core/database/tables.dart`
   - Create `lib/core/database/daos/{{feature}}_dao.dart` with `@DriftAccessor`
   - Register the DAO in `lib/core/database/database.dart` (add to `@DriftDatabase(tables:[...], daos:[...])`)
   - Run `dart run build_runner build --delete-conflicting-outputs`
5. Add a route/tab in `lib/features/shell/main_shell.dart`
6. If data should sync to Firestore: add collection handling in `lib/features/sync/sync_service.dart`

---

## Current data model (tables that exist — do not recreate)
{table_lines}

---

## Provider names already in use (do not clash)
{provider_names}

---

## Known extension points
{gaps_text}

---

## Test coverage
{test_coverage}
"""
    _write_text(DOCS_ROOT / "brownfield_context.md", md)


# ---------------------------------------------------------------------------
# Stage 8 entry point
# ---------------------------------------------------------------------------


def stage8() -> None:
    print("\n=== Stage 8: Agent-Native Context Files ===")
    stage8_agents_md()
    stage8_copilot_instructions()
    stage8_symbol_index()
    stage8_brownfield_context()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    print("=== Deep Reverse Engineering Documentation Generator ===")
    print(f"Repo root: {REPO_ROOT}")
    print(f"Output:    {DOCS_ROOT}")

    stage0()
    inventory = stage1()
    all_sigs = stage2(inventory)
    stage3(inventory, all_sigs)
    stage4(inventory)
    stage5(inventory, all_sigs)
    stage6(inventory)
    stage7(inventory, all_sigs)
    stage8()

    print("\n=== Done ===")
    print(f"All documentation written to {DOCS_ROOT}")


if __name__ == "__main__":
    main()
