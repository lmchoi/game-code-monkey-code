Switch to main, pull latest, and delete the previously checked-out branch if it has been merged.

Steps:
1. Note the current branch name
2. Run `git status` — if there are any uncommitted changes (modified or untracked files that aren't in .gitignore), warn the user and ask whether to proceed
3. Run `git checkout main && git pull`
4. Delete the previous branch with `git branch -d <branch>` (safe delete — won't delete if unmerged)
5. Report what was updated and confirm the branch was cleaned up
