# P8 Clean Stitch MCP Extract

## Access

- Requested project by exact resource name: `projects/9558614255557019910`
- Returned project resource: `projects/9558614255557019910`
- Returned project display name: `app`
- Project type: `TEXT_TO_UI_PRO`
- Device type: `MOBILE`
- Access result: success

## Screen Gate

`get_project` returned historical hidden screen instances plus exactly five non-hidden screen instances. Hidden historical instances were ignored. The five active visible screen areas map to the intended target set, so the gate passed.

## Active Visible Screens

| Order | Route | Screen title | Screen ID | Size |
| --- | --- | --- | --- | --- |
| 1 | Today | 今日：高阶生产力指挥台 (Final Synthesis) | `33d5787b9aa14ed3bbc64dbb7ba6ef69` | 780 x 3682 |
| 2 | Habits | 习惯：比例优化版 (Scale & Proportion Refinement) | `4fbdd980797e4663b750b614412b0eb5` | 780 x 3040 |
| 3 | Plan | 计划：自律指挥台 (Discipline Dashboard) | `24b8c867362e461fbf02a9c7c1e610a2` | 780 x 4212 |
| 4 | Focus | 专注：高阶执行指挥中心 (Final Synthesis) | `4085425157906743431` | 780 x 2568 |
| 5 | My / Settings | 我的：个人性能中心 (Performance Hub) | `8565560408798541609` | 780 x 3278 |

## Fresh Local References

- `.ai_reference/stitch/screenshots/01_today.png`
- `.ai_reference/stitch/screenshots/02_habits.png`
- `.ai_reference/stitch/screenshots/03_plan.png`
- `.ai_reference/stitch/screenshots/04_focus.png`
- `.ai_reference/stitch/screenshots/05_my_settings.png`
- `.ai_reference/stitch/html/01_today.html`
- `.ai_reference/stitch/html/02_habits.html`
- `.ai_reference/stitch/html/03_plan.html`
- `.ai_reference/stitch/html/04_focus.html`
- `.ai_reference/stitch/html/05_my_settings.html`
- `.ai_reference/stitch/metadata/screen_index.json`

## Fetch Notes

Direct shell and Node fetches to the returned Googleusercontent URLs were blocked by sandbox socket policy. The browser tool could access the MCP-returned refs. HTML was saved from the browser download event, and screenshots were saved from the exact screenshot image elements exposed by the MCP `screenshot.downloadUrl` refs.

Verdict: `STITCH_CLEAN_PROJECT_5_VISIBLE_SCREENS_CONFIRMED`
