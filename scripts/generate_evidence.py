#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_DIR = ROOT / "evidence"
SCHEMA_PATH = EVIDENCE_DIR / "evidence.schema.json"
OUT_PATH = EVIDENCE_DIR / "evidence.json"
LOG_PATH = EVIDENCE_DIR / "last-forge-test-output.log"


def run_command(command: str) -> tuple[int, str]:
    proc = subprocess.run(
        command,
        shell=True,
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    output = (proc.stdout or "") + ("\n" + proc.stderr if proc.stderr else "")
    return proc.returncode, output


def parse_test_summary(output: str) -> tuple[int, int]:
    matches = re.findall(r"(\d+)\s+passed;\s+(\d+)\s+failed", output)
    if not matches:
        return 0, 0
    passed, failed = matches[-1]
    return int(passed), int(failed)


def validate_against_schema(instance, schema):
    errors = []
    if schema.get("type") == "object" and not isinstance(instance, dict):
        return ["$: expected object"]
    if schema.get("const") is not None and instance != schema["const"]:
        errors.append(f"$: expected constant value {schema['const']!r}")
    if isinstance(instance, dict):
        for key in schema.get("required", []):
            if key not in instance:
                errors.append(f"$: missing required property {key}")
        for key, value in instance.items():
            if key in schema.get("properties", {}):
                errors.extend(validate_against_schema(value, schema["properties"][key]))
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate and validate evidence for signature-validation-01")
    parser.add_argument("--validate-only", default="")
    args = parser.parse_args()

    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))

    if args.validate_only:
        candidate = json.loads((ROOT / args.validate_only).read_text(encoding="utf-8"))
        errors = validate_against_schema(candidate, schema)
        if errors:
            print("Schema validation failed:")
            for err in errors:
                print(f"- {err}")
            return 1
        print(f"Schema validation passed: {ROOT / args.validate_only}")
        return 0

    exit_code, output = run_command("forge test -vvv")
    EVIDENCE_DIR.mkdir(parents=True, exist_ok=True)
    LOG_PATH.write_text(output, encoding="utf-8")

    if exit_code != 0:
        print("forge test failed; evidence was not generated")
        print(f"See log: {LOG_PATH}")
        return exit_code

    passed, failed = parse_test_summary(output)
    evidence = {
        "schemaVersion": "1.0.0",
        "labId": "signature-validation-01",
        "execution": {
            "command": "forge test -vvv",
            "exitCode": exit_code,
            "passed": passed,
            "failed": failed,
        },
        "assertions": {
            "exploitConfirmed": "testReplayDrainsVulnerableVault" in output,
            "fixConfirmed": "testReplayFailsAgainstFixedVault" in output,
            "negativeControlConfirmed": "testNegativeControlInvalidSignerNoSignal" in output,
        },
        "generatedAt": dt.datetime.now(dt.UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    }

    errors = validate_against_schema(evidence, schema)
    if errors:
        print("Generated evidence did not validate against schema:")
        for err in errors:
            print(f"- {err}")
        return 1

    OUT_PATH.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print(f"Evidence generated: {OUT_PATH}")
    print(f"Schema validation passed: {SCHEMA_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())