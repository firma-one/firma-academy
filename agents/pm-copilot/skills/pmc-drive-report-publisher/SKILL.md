---
name: pmc-drive-report-publisher
description: "Use when the Project Manager asks to save, publish, or export a report or governance artefact to Google Drive — e.g. 'save the steering pack to Drive', 'put the report on Drive', 'export this to Drive'. Writes the finished artefact as a Microsoft Office file (.docx / .xlsx / .pptx) into the Atlas Shared Drive. This is a WRITE skill: creating an internal artefact on Drive is permitted directly; it does not distribute to external stakeholders."
---

# Drive Report Publisher

Write a finished report or governance artefact to Google Drive, in the **Atlas Shared Drive**, as a **Microsoft Office file** (`.docx`, `.xlsx`, or `.pptx`) — never as a native Google Docs/Sheets/Slides file.

## When to use
"Save the steering pack to Drive", "publish the report to Drive", "export this to Drive", "put the outcome dashboard on Drive". Use only after the content to publish already exists (produced by another skill or in the conversation) — this skill writes, it does not author from scratch.

## Prerequisite
The Google Drive connector must be connected with write access (`create_file`).

## Destination — Atlas Shared Drive (source of truth)
All files go to the **Atlas Shared Drive**, passed as `parentId`:

```
parentId = 0AGindXMKcjpZUk9PVA        # Atlas Shared Drive (root)
```

Never write to My Drive root. If the caller names a subfolder inside the Atlas Shared Drive, resolve that folder's ID (via `search_files`) and use it as `parentId` instead; otherwise default to the Shared Drive root above.

## Procedure
1. Confirm what is being published (which artefact / content) and that it's the reviewed/approved version — this skill publishes, it doesn't invent content.
2. Choose a clear, dated title, e.g. `Atlas — Steering Pack — 2026-07-29` or `Atlas — Outcome Dashboard — S13`. Do **not** append the extension to the title — Drive shows it from the file type.
3. **Build the artefact as a Microsoft Office file** (do not upload plain text or HTML for Drive to convert). Use the appropriate document skill to produce real Office bytes:
   - Reports, briefs, steering packs → **`.docx`** (use the `docx` skill).
   - Tabular artefacts (registers, metrics, dashboards) → **`.xlsx`** (use the `xlsx` skill).
   - Slide artefacts → **`.pptx`** (use the `pptx` skill).
   Write the file locally first, then read it back as base64 for upload.
4. Call the Google Drive `create_file` tool with:
   - `title` — the dated title above
   - `base64Content` — the base64-encoded Office file bytes
   - `contentMimeType` — the matching Office MIME type (see table below)
   - `disableConversionToGoogleType: true` — **required**, so Drive keeps the file as native Office rather than converting it to a Google Doc/Sheet/Slides
   - `parentId = 0AGindXMKcjpZUk9PVA` (the Atlas Shared Drive)
5. **Verify placement and format.** Check the response `parentId`/owner and `mimeType`. If the file landed in My Drive root (a `parentId` like `0AP0...` that is NOT the Atlas Shared Drive), the write went to the wrong place — see Gotcha below. If the returned `mimeType` is a `application/vnd.google-apps.*` type, conversion was **not** disabled — re-upload with `disableConversionToGoogleType: true`. Report either problem rather than claiming success.
6. Return the `viewUrl` to the PM so they can open the published file.

## Office MIME types
| Artefact | Extension | `contentMimeType` |
|---|---|---|
| Document / report | `.docx` | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` |
| Spreadsheet | `.xlsx` | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |
| Presentation | `.pptx` | `application/vnd.openxmlformats-officedocument.presentationml.presentation` |

Always pass `disableConversionToGoogleType: true` alongside these so Drive stores true Office files.

## Gotcha — Shared Drive support flags
Writing into a Shared Drive can require the API to know the parent is a shared drive (`supportsAllDrives` / `includeItemsFromAllDrives`). If `create_file` errors on the Shared Drive parent, or silently falls back to My Drive root, that flag is the likely cause. Surface this to the PM as a connector-configuration issue — do not silently write to the wrong location.

## Output shape
A short confirmation: what was published, the title, and the `viewUrl`. Announce the skill at the top: `▸ Skill: Drive Report Publisher`.

## Governance note
Writing a report to the Atlas Shared Drive is an internal-artefact action (the team's own workspace), so direct write is appropriate. Distributing to external stakeholders (email, stakeholder channels) remains draft-and-review — see the Gmail and Slack skills.
