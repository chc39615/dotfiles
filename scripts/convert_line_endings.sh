#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

FOLDER="$1"

echo "Select the target line ending format:"
select FORMAT in "unix (LF)" "dos (CRLF)" "mac (CR)"; do
  case $REPLY in
    1)
      NEWLINE=$'\n'
      EXT="LF (Unix)"
      break
      ;;
    2)
      NEWLINE=$'\r\n'
      EXT="CRLF (DOS/Windows)"
      break
      ;;
    3)
      NEWLINE=$'\r'
      EXT="CR (Old Mac)"
      break
      ;;
    *)
      echo "Invalid selection. Please choose 1, 2, or 3."
      ;;
  esac
done

# List of directories to ignore
IGNORE_DIRS=(
  ".git"
  ".venv"
  "node_modules"
  "__pycache__"
)

# Build find exclude expression
EXCLUDES=()
for dir in "${IGNORE_DIRS[@]}"; do
  EXCLUDES+=(-path "$FOLDER/$dir" -prune -o)
done

echo "Converting files under: $FOLDER -> $EXT"

# Use find with prune to skip excluded dirs
find "$FOLDER" "${EXCLUDES[@]}" -type f -print0 | while IFS= read -r -d '' file; do
  if file "$file" | grep -qE 'text'; then
    echo "Converting: $file"
    perl -0777 -pe 's/\r\n|\n|\r/'"$NEWLINE"'/g' "$file" > "${file}.tmp" && \
    orig_mode=$(stat -f "%Lp" "$file") && \
    chmod "$orig_mode" "${file}.tmp" && \
    mv "${file}.tmp" "$file"
  else
    echo "Skipping binary file: $file"
  fi
done
