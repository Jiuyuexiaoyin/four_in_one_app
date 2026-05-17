# Visual References

`docs/references` is the visual reference root for `four_in_one_app`.
Future UI agents must use files from this folder instead of relying on chat
memory.

## Folder Meaning

- `current_app_ui`: screenshots of our current app. These show what must be
  improved.
- `ui_taste_board` / wanted UI screenshots: desired visual direction and mood.
- benchmark app screenshots: external references for layout, rhythm, color,
  data visualization, and interaction density.
- zip files: screenshot archives. They are historical/reference archives and
  must be indexed or unpacked before a visual agent uses their contents.

## Rules For Agents

- Do not rely on chat memory for visual direction.
- UI tasks must cite the exact reference paths they used.
- Current app screenshots must be compared against desired and benchmark
  references before implementation.
- Zip archives should not be treated as visible references until they are listed
  or unpacked by an approved step.
- Do not move, delete, or rewrite reference assets unless the user explicitly
  approves that cleanup.
