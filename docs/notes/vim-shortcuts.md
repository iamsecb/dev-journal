

🧭 Vim Navigation Shortcuts Cheat Sheet

🔼 Basic Movement
| Shortcut | Description                            | Example / Notes       |
| -------- | -------------------------------------- | --------------------- |
| `h`      | Move left                              |                       |
| `l`      | Move right                             |                       |
| `j`      | Move down                              |                       |
| `k`      | Move up                                |                       |
| `0`      | Move to beginning of line              |                       |
| `^`      | Move to first non-whitespace character |                       |
| `$`      | Move to end of line                    |                       |
| `gg`     | Go to beginning of file                |                       |
| `G`      | Go to end of file                      |                       |
| `:n`     | Go to line `n`                         | `:42` goes to line 42 |
| `zz`     | Center current line in window          | Great for readability |


📦 Word/Block Movement
| Shortcut | Description                          | Example / Notes        |
| -------- | ------------------------------------ | ---------------------- |
| `w`      | Move to beginning of next word       |                        |
| `e`      | Move to end of current word          |                        |
| `b`      | Move to beginning of previous word   |                        |
| `ge`     | Move to end of previous word         |                        |
| `%`      | Jump to matching bracket/parenthesis | Useful for code blocks |



🔍 Search & Navigate
| Shortcut   | Description                           | Example / Notes |
| ---------- | ------------------------------------- | --------------- |
| `/pattern` | Search forward for `pattern`          | `/AuthMethod`   |
| `?pattern` | Search backward                       |                 |
| `n`        | Repeat last search forward            |                 |
| `N`        | Repeat last search backward           |                 |
| `*`        | Search for word under cursor forward  |                 |
| `#`        | Search for word under cursor backward |                 |




🚀 Advanced Navigation
| Shortcut            | Description                        | Example / Notes             |
| ------------------- | ---------------------------------- | --------------------------- |
| `''` or \`\`\`\`    | Return to previous cursor position | After jumping around        |
| `Ctrl + o`          | Go to older cursor position        | Like a back button          |
| `Ctrl + i`          | Go to newer cursor position        | Like a forward button       |
| `H`                 | Move to top of screen              |                             |
| `M`                 | Move to middle of screen           |                             |
| `L`                 | Move to bottom of screen           |                             |
| `:bnext` / `:bn`    | Next buffer                        | When editing multiple files |
| `:bprev` / `:bp`    | Previous buffer                    |                             |
| `:ls` or `:buffers` | List open buffers                  |                             |


📁 File Navigation
| Shortcut            | Description                   | Example / Notes                              |
| ------------------- | ----------------------------- | -------------------------------------------- |
| `:e <file>`         | Open a file                   | `:e main.go`                                 |
| `:Ex` or `:Explore` | Open file browser (netrw)     | Navigate folders inside Vim                  |
| `gf`                | Go to file under cursor       | Opens the file if it exists                  |
| `:vsplit <file>`    | Open file in vertical split   | Side-by-side editing                         |
| `:split <file>`     | Open file in horizontal split |                                              |
| `Ctrl + w, h/j/k/l` | Navigate between splits       | Like Vim’s version of arrow keys for windows |



### Selecting a Function block

🧠 Explanation

`va{`: selects the function block in characterwise visual mode.

`V`  : changes it to a linewise selection.

`O`  : switches the active end of the visual selection to the top.

`k`  : moves it up, including the comment line above the function.


Use the following to select the funtion comment for example via `O`. It also shows navigation options 
surrounding the function.

| Action                    | Keys      | Effect                                |
| ------------------------- | --------- | ------------------------------------- |
| **Extend selection up**   | `O` + `k` | Moves the *start* of the selection up |
| **Extend selection down** | `o` + `j` | Moves the *end* of the selection down |
