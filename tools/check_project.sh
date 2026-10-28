#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PHP_BIN="${PHP_BIN:-php}"

if ! command -v "$PHP_BIN" >/dev/null 2>&1; then
  echo "PHP CLI not found: $PHP_BIN" >&2
  echo "On macOS XAMPP, run: PHP_BIN=/Applications/XAMPP/xamppfiles/bin/php ./tools/check_project.sh" >&2
  exit 2
fi

php_count=0
while IFS= read -r -d '' file; do
  "$PHP_BIN" -l "$file" >/dev/null
  printf 'PHP OK  %s\n' "${file#"$ROOT/"}"
  php_count=$((php_count + 1))
done < <(find "$ROOT/app" "$ROOT/config" "$ROOT/public" "$ROOT/tools" -type f -name '*.php' -print0)

js_count=0
if command -v node >/dev/null 2>&1; then
  while IFS= read -r -d '' file; do
    node --check "$file" >/dev/null
    printf 'JS OK   %s\n' "${file#"$ROOT/"}"
    js_count=$((js_count + 1))
  done < <(find "$ROOT/public/assets" -type f -name '*.js' -print0)
else
  echo "Skipping standalone JavaScript checks (Node.js not installed)."
fi

shell_count=0
while IFS= read -r -d '' file; do
  bash -n "$file"
  printf 'SH OK   %s\n' "${file#"$ROOT/"}"
  shell_count=$((shell_count + 1))
done < <(find "$ROOT/tools" -type f -name '*.sh' -print0)

css_count=0
if command -v python3 >/dev/null 2>&1 && python3 -c 'import tinycss2' >/dev/null 2>&1; then
  python3 - "$ROOT" <<'PYCSS'
import pathlib, sys, tinycss2
root = pathlib.Path(sys.argv[1])
failed = False
count = 0

def check_rules(rules, path):
    global failed, count
    for rule in rules:
        if rule.type == 'error':
            print(f"CSS ERROR {path}: {rule.message} at {rule.source_line}:{rule.source_column}")
            failed = True
            continue
        if rule.type == 'qualified-rule':
            decls = tinycss2.parse_declaration_list(rule.content, skip_whitespace=True, skip_comments=True)
            for decl in decls:
                if decl.type == 'error':
                    print(f"CSS ERROR {path}: {decl.message} at {decl.source_line}:{decl.source_column}")
                    failed = True
        elif rule.type == 'at-rule' and rule.content is not None:
            nested = tinycss2.parse_rule_list(rule.content, skip_whitespace=True, skip_comments=True)
            check_rules(nested, path)

for path in sorted((root / 'public' / 'assets').glob('*.css')):
    rules = tinycss2.parse_stylesheet(path.read_text(encoding='utf-8'), skip_whitespace=True, skip_comments=True)
    check_rules(rules, path.relative_to(root))
    print(f"CSS OK  {path.relative_to(root)}")
    count += 1
if failed:
    raise SystemExit(1)
print(f"CSS check passed: {count} stylesheets.")
PYCSS
  css_count=$(find "$ROOT/public/assets" -type f -name '*.css' | wc -l | tr -d ' ')
else
  echo "Skipping detailed CSS parsing (install Python tinycss2 to enable it)."
fi

printf '\nStatic checks passed: %s PHP files, %s standalone JavaScript files, %s shell scripts, %s CSS files parsed.\n' "$php_count" "$js_count" "$shell_count" "$css_count"
echo "Note: static checks do not verify database migrations, browser behavior, or live Judge0 execution. Follow tests/REGRESSION_CHECKLIST.md."
