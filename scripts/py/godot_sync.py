#!/usr/bin/env python3
import argparse
import shutil
from pathlib import Path
import sys
import re


# python3 godot_sync.py "C:\Godot\MyTemplate" --new="My New Game" --copy=input-map,autoloads,blisscode
# python3 godot_sync.py "C:\Godot\MyTemplate" "D:\Games\WeatherWizard" --new="Weather Wizard"


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        print(f"[ERROR] File not found: {path}", file=sys.stderr)
        sys.exit(1)


def write_text(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")


def find_section_bounds(text: str, section_name: str):
    """
    Find the start/end indices of a [section_name] block in a Godot project.godot-like file.
    Returns (start_idx, end_idx) or (None, None) if not found.
    """
    lines = text.splitlines(keepends=True)
    start_idx = None
    end_idx = None

    header = f"[{section_name}]"

    line_start = None
    for i, line in enumerate(lines):
        if line.strip() == header:
            line_start = i
            break

    if line_start is None:
        return None, None

    start_idx = sum(len(l) for l in lines[:line_start])

    line_end = len(lines)
    for i in range(line_start + 1, len(lines)):
        stripped = lines[i].lstrip()
        if stripped.startswith("[") and "]" in stripped:
            line_end = i
            break

    end_idx = sum(len(l) for l in lines[:line_end])
    return start_idx, end_idx


def replace_or_append_section(target_text: str, src_text: str, section_name: str) -> str:
    """
    Replace the entire [section_name] section in target_text with the section
    from src_text. If the section doesn't exist in target, append it to the end.
    """
    src_start, src_end = find_section_bounds(src_text, section_name)
    if src_start is None:
        print(f"[WARN] Section [{section_name}] not found in source project.godot, skipping.")
        return target_text

    src_section = src_text[src_start:src_end]

    tgt_start, tgt_end = find_section_bounds(target_text, section_name)

    if tgt_start is None:
        if not target_text.endswith("\n"):
            target_text += "\n"
        target_text += "\n" + src_section.strip("\n") + "\n"
        print(f"[INFO] Added new section [{section_name}] to target project.godot.")
    else:
        target_text = target_text[:tgt_start] + src_section + target_text[tgt_end:]
        print(f"[INFO] Replaced section [{section_name}] in target project.godot.")

    return target_text


def copy_folder(src_root: Path, dst_root: Path, folder_name: str):
    src_dir = src_root / folder_name
    dst_dir = dst_root / folder_name

    if not src_dir.exists():
        print(f"[WARN] Folder '{folder_name}' does not exist in source project: {src_dir}")
        return

    dst_dir.parent.mkdir(parents=True, exist_ok=True)

    print(f"[INFO] Copying folder '{folder_name}' from\n       {src_dir}\n    →  {dst_dir}")
    shutil.copytree(src_dir, dst_dir, dirs_exist_ok=True)


def safe_folder_name(name: str) -> str:
    """
    Convert a human project name into a safe folder name.
    Example: 'My New Project' -> 'My_New_Project'
    """
    s = name.strip()
    s = s.replace(" ", "_")
    # remove weird chars, keep letters, numbers, - and _
    s = re.sub(r"[^A-Za-z0-9_\-]", "", s)
    return s or "NewProject"


def set_project_name(text: str, new_name: str) -> str:
    """
    Ensure [application] section has config/name="new_name".
    If [application] is missing, add it.
    """
    section_name = "application"
    start, end = find_section_bounds(text, section_name)
    line = f'config/name="{new_name}"\n'

    if start is None:
        # No [application] section at all
        print(f"[INFO] Adding [application] section with config/name='{new_name}'.")
        if not text.endswith("\n"):
            text += "\n"
        text += f"\n[application]\n{line}"
        return text

    section = text[start:end]
    lines = section.splitlines(keepends=True)

    name_line_index = None
    for i, l in enumerate(lines):
        if l.strip().startswith("config/name="):
            name_line_index = i
            break

    if name_line_index is not None:
        print(f"[INFO] Updating config/name in [application] to '{new_name}'.")
        lines[name_line_index] = line
    else:
        print(f"[INFO] Inserting config/name into existing [application] section.")
        # insert after header
        lines.insert(1, line)

    new_section = "".join(lines)
    return text[:start] + new_section + text[end:]


def new(src_root: Path, dst_root: Path, new_name: str):
    """
    Create a new project by copying the source project and setting its name.
    """
    src_project = src_root / "project.godot"
    
    if not src_project.exists():
        print(f"[ERROR] Source project.godot not found at: {src_project}", file=sys.stderr)
        sys.exit(1)

    # If target path does not exist, copy entire project folder
    if not dst_root.exists():
        print(f"[INFO] Target path does not exist. Cloning entire project folder:")
        print(f"       {src_root}\n    →  {dst_root}")
        shutil.copytree(src_root, dst_root)
    else:
        print(f"[INFO] Target path already exists: {dst_root}")

    dst_project = dst_root / "project.godot"
    if not dst_project.exists():
        print(f"[ERROR] Target project.godot not found at: {dst_project}", file=sys.stderr)
        sys.exit(1)

    # Set the project name in [application]
    dst_text = read_text(dst_project)
    dst_text = set_project_name(dst_text, new_name)
    write_text(dst_project, dst_text)
    print(f"[INFO] Updated target project.godot at: {dst_project}")
    print("[DONE] New project created.")


def sync(src_root: Path, dst_root: Path, copy_items: list):
    """
    Sync selected items (sections and folders) from source to destination project.
    """
    src_project = src_root / "project.godot"
    dst_project = dst_root / "project.godot"
    
    if not src_project.exists():
        print(f"[ERROR] Source project.godot not found at: {src_project}", file=sys.stderr)
        sys.exit(1)
    
    if not dst_project.exists():
        print(f"[ERROR] Target project.godot not found at: {dst_project}", file=sys.stderr)
        sys.exit(1)

    src_text = read_text(src_project)
    dst_text = read_text(dst_project)

    # Handle input-map/autoloads
    for item in copy_items:
        if item == "input-map":
            print("[INFO] Syncing input map ([input] section)…")
            dst_text = replace_or_append_section(dst_text, src_text, "input")
        elif item == "autoloads":
            print("[INFO] Syncing autoloads ([autoload] section)…")
            dst_text = replace_or_append_section(dst_text, src_text, "autoload")

    # Save project.godot if we touched anything
    if any(i in copy_items for i in ("input-map", "autoloads")):
        write_text(dst_project, dst_text)
        print(f"[INFO] Updated target project.godot at: {dst_project}")

    # Any other items are treated as folder names
    for item in copy_items:
        if item in ("input-map", "autoloads"):
            continue
        copy_folder(src_root, dst_root, item)

    print("[DONE] Sync complete.")


def main():
    parser = argparse.ArgumentParser(
        description="Sync selected Godot project settings and folders between projects."
    )
    parser.add_argument("src", help="Path to source Godot project (folder containing project.godot)")
    parser.add_argument(
        "dst",
        nargs="?",
        help="Path to target Godot project. "
             "If omitted, --new must be provided to auto-create a new project folder.",
    )
    parser.add_argument(
        "--copy",
        help="Comma-separated list of items to copy. "
             "Special: input-map,autoloads. "
             "Anything else is treated as a folder name from project root.",
    )
    parser.add_argument(
        "--new",
        dest="new_name",
        help="If set, treat this as the new project name. "
             "If the target path does not exist, the entire source project folder "
             "will be copied there, and config/name will be updated.",
    )

    args = parser.parse_args()

    src_root = Path(args.src).resolve()
    if not src_root.exists():
        print(f"[ERROR] Source path does not exist: {src_root}", file=sys.stderr)
        sys.exit(1)

    # Determine destination root
    if args.dst:
        dst_root = Path(args.dst).resolve()
    else:
        if not args.new_name:
            print("[ERROR] If dst is not provided, you must specify --new=ProjectName", file=sys.stderr)
            sys.exit(1)
        folder = safe_folder_name(args.new_name)
        dst_root = src_root.parent / folder
        print(f"[INFO] No dst provided. Using new folder derived from --new:\n       {dst_root}")

    # Handle --new: create new project
    if args.new_name:
        new(src_root, dst_root, args.new_name)
    
    # Handle --copy: sync items (not called yet for testing)
    # if args.copy:
    #     copy_items = [item.strip() for item in args.copy.split(",") if item.strip()]
    #     sync(src_root, dst_root, copy_items)


if __name__ == "__main__":
    main()
