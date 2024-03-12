local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function hasValue(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function getBranchesLocal()
    local handle = io.popen("git branch -a 2>&1")
    local result = handle:read("*a")
    handle:close()

    local branches = {}
    if startsWith(result, "fatal") == false then
        for branch in string.gmatch(result, "[* ]%s.%S+") do
            branch = string.gsub(branch, "^%*%s*", "")
            branch = string.gsub(branch, "^%s*remotes/", "")
            branch = string.gsub(branch, "^%s+", "")
            table.insert(branches, branch)
        end
    end
    return branches
end

local function getBranchesRemote()
    local handle = io.popen("git remote -v 2>&1")
    local result = handle:read("*a")
    handle:close()

    local branches = {}
    if startsWith(result, "fatal") == false then
        for branch in string.gmatch(result, "%S+") do
            if string.sub(branch, 0, 1) ~= "(" and startsWith(branch, "http") == false then
                table.insert(branches, branch)
            end
        end
    end
    return branches
end

local status = {
    arg = "status",
    flags = { "-s", "-b", "--show-stash", "-v" },
    description = {
        ["status"] = "Show the working tree status"
    },
    flagDescriptions = {
        ["-s"] = "Give the output in the short-format.",
        ["-b"] = "Show the branch and tracking info even in short-format.",
        ["--show-stash"] = "Show the number of entries currently stashed away.",
        ["-v"] = "Also show the textual changes that are staged to be committed."
    }
}

local show = {
    arg = "show",
    flags = { "--name-only", "--name-status", "--oneline", "--stat", "--summary", "--patch" },
    description = {
        ["show"] = "Show various types of objects",
    },
    flagDescriptions = {
        ["--name-only"] = "Show only names of changed files.",
        ["--name-status"] = "Show only names and status of changed files.",
        ["--oneline"] = "Show each commit as a single line.",
        ["--stat"] = "Generate a diffstat.",
        ["--summary"] =
        "Output a condensed summary of extended header information such as creations, renames and mode changes.",
        ["--patch"] = "Generate patch (see section on generating patches)."
    }
}

local diff = {
    arg = "diff",
    flags = { "-p", "-u", "-s" },
    description = {
        ["diff"] = "Show changes between commits, commit and working tree, etc",
    },
    flagDescriptions = {
        ["-p"] = "Generate patch (see section on generating patches).",
        ["-u"] = "Generate patch in unified diff format.",
        ["-s"] = "Show only names and not the contents."
    }
}

local add = {
    arg = "add",
    flags = { "-n", "-v", "-f" },
    description = {
        ["add"] = "Add file contents to the index.",
    },
    flagDescriptions = {
        ["-n"] = "Don't actually add the file(s), just show if they exist.",
        ["-v"] = "Be verbose.",
        ["-f"] = "Allow adding otherwise ignored files."
    }
}

local bisect = {
    arg = "bisect",
    description = {
        ["bisect"] = "Find by binary search the change that introduced a bug."
    }
}

local branch = {
    arg = "branch",
    flags = { "-d", "-D", "-m", "-M", "-a", "-u", "-v", "--merged", "--no-merged" },
    description = {
        ["branch"] = "List, create, or delete branches."
    },
    flagDescriptions = {
        ["-d"] = "Delete a branch.",
        ["-D"] = "Force delete a branch.",
        ["-m"] = "Move a branch.",
        ["-M"] = "Force move a branch.",
        ["-a"] = "List both remote-tracking branches and local branches.",
        ["-u"] = "Set up a tracking connection with a remote branch.",
        ["-v"] = "Show SHA-1 and commit subject line for each head.",
        ["--merged"] = "Only list branches whose tips are reachable from the specified commit.",
        ["--no-merged"] = "Only list branches whose tips are not reachable from the specified commit."
    }
}

local checkout = {
    arg = "checkout",
    flags = { "-b", "-B", "-l", "-t", "-f", "-m", "-M", "--detach", "--orphan" },
    description = {
        ["checkout"] = "Switch branches or restore working tree files."
    },
    flagDescriptions = {
        ["-b"] = "Create a new branch and start it at <start-point>.",
        ["-B"] = "Create a new branch and start it at <start-point>.",
        ["-l"] = "Create the new branch’s reflog.",
        ["-t"] = "Track a remote branch.",
        ["-f"] = "Force the checkout.",
        ["-m"] = "When switching branches, if you have local modifications to one or more files that are different between the current branch and the branch to which you are switching, the command refuses to switch branches in order to preserve your modifications in context.",
        ["-M"] = "When switching branches, if you have local modifications to one or more files that are different between the current branch and the branch to which you are switching, the command refuses to switch branches in order to preserve your modifications in context.",
        ["--detach"] = "Detach the HEAD at the named commit.",
        ["--orphan"] = "Create a new orphan branch."
    }
}

local clone = {
    arg = "clone",
    flags = { "-l", "-s", "-n", "--bare", "--mirror", "--template", "--reference", "--dissociate", "--separate-git-dir" },
    description = {
        ["clone"] = "Clone a repository into a new directory."
    },
    flagDescriptions = {
        ["-l"] = "When the repository to clone is on the local machine, this flag bypasses the normal " ..
            "git aware transport mechanism and clones the repository by making a copy of the source repository.",
        ["-s"] = "When the repository to clone is on the local machine, instead of using hard links, " ..
            "automatically setup .git/objects/info/alternates to share the objects with the source repository.",
        ["-n"] = "Do not checkout the HEAD.",
        ["--bare"] = "Make a bare Git repository.",
        ["--mirror"] = "Set up a mirror of the source repository.",
        ["--template"] = "Specify the directory from which templates will be used.",
        ["--reference"] = "If the reference repository is on the local machine, automatically setup " ..
            ".git/objects/info/alternates to obtain objects from the reference repository.",
        ["--dissociate"] = "Use this option to clone a repository and then remove the association " ..
            "with the source repository.",
        ["--separate-git-dir"] = "Instead of placing the cloned repository where it is supposed to be, " ..
            "use this option to place the cloned repository at the specified directory."
    }
}

local commit = {
    arg = "commit",
    flags = { "-a", "-p", "-C", "-c", "--amend", "--no-edit", "--fixup", "--squash", "--reset-author", "--short", "--branch", "--edit" },
    description = {
        ["commit"] = "Record changes to the repository."
    },
    flagDescriptions = {
        ["-a"] = "Automatically stage files that have been modified and deleted.",
        ["-p"] = "Interactively stage hunks in the commit.",
        ["-C"] = "Use the commit message from a specific commit.",
        ["-c"] = "Use the commit message from a specific commit.",
        ["--amend"] = "Replace the tip of the current branch by creating a new commit.",
        ["--no-edit"] = "Use the selected commit message without launching an editor.",
        ["--fixup"] = "Construct a commit that fixes the changes in a previous commit.",
        ["--squash"] = "Construct a commit that is a squash of the changes in a previous commit.",
        ["--reset-author"] = "When used with -C/-c/--amend, the authorship details will be updated.",
        ["--short"] = "When used with -C/-c/--amend, the authorship details will be updated.",
        ["--branch"] = "When used with -C/-c/--amend, the authorship details will be updated.",
        ["--edit"] = "Use the selected commit message and launch an editor."
    }
}

local fetch = {
    arg = "fetch",
    flags = { "-a", "-f", "-k", "-p", "-t", "-u", "-v", "--all", "--append", "--depth", "--unshallow", "--update-shallow", "--dry-run", "--force", "--keep", "--prune", "--no-tags", "--tags" },
    description = {
        ["fetch"] = "Download objects and refs from another repository."
    },
    flagDescriptions = {
        ["-a"] = "Fetch all remotes.",
        ["-f"] = "Force the fetch.",
        ["-k"] = "Keep downloaded pack.",
        ["-p"] = "Prune remote-tracking branches no longer on remote.",
        ["-t"] = "Fetch all tags.",
        ["-u"] = "Fetch and update the remote-tracking branches.",
        ["-v"] = "Be verbose.",
        ["--all"] = "Fetch all remotes.",
        ["--append"] = "Append ref names and object names of fetched refs to the existing contents of .git/FETCH_HEAD.",
        ["--depth"] = "Limit fetching to the specified number of commits from the tip of each remote branch history.",
        ["--unshallow"] = "Convert a shallow repository to a complete one.",
        ["--update-shallow"] = "After fetching, remove any references that no longer exist on the remote.",
        ["--dry-run"] = "Show what would be done, without making any changes.",
        ["--force"] = "Force the fetch.",
        ["--keep"] = "Keep downloaded pack.",
        ["--prune"] = "Prune remote-tracking branches no longer on remote.",
        ["--no-tags"] = "Don't fetch any tags.",
        ["--tags"] = "Fetch all tags."
    }
}

local grep = {
    arg = "grep",
    flags = { "-i", "-I", "-v", "-h", "-H", "-n", "-l", "-L", "-e", "-E", "-G", "-F", "-w", "-c", "-o", "-q", "--text", "--binary", "--files-with-matches", "--files-without-match", "--count", "--name-only", "--full-name", "--line-number", "--no-messages", "--color", "--break", "--heading", "--show-function", "--show-function-line", "--null", "--after-context", "--before-context", "--context", "--group-separator", "--exclude-standard", "--exclude", "--include", "--exclude-from", "--include-from", "--relative", "--recurse-submodules", "--untracked", "--ignore-submodules", "--no-index", "--cached", "--no-textconv", "--textconv", "--max-depth", "--extended-regexp", "--perl-regexp", "--basic-regexp", "--fixed-strings", "--ignore-case", "--word-regexp", "--invert-match", "--show-function", "--show-function-line", "--only-matching", "--count", "--null-data", "--null", "--before-context", "--after-context", "--context", "--group-separator", "--break", "--heading", "--line-number", "--with-filename", "--no-filename", "--label", "--exclude", "--include", "--exclude-from", "--include-from", "--relative", "--recurse-submodules", "--untracked", "--ignore-submodules", "--no-index", "--cached", "--no-textconv", "--textconv", "--max-depth", "--extended-regexp", "--perl-regexp", "--basic-regexp", "--fixed-strings", "--ignore-case", "--word-regexp", "--invert-match", "--show-function", "--show-function-line", "--only-matching", "--count", "--null-data", "--null", "--before-context", "--after-context", "--context", "--group-separator", "--break", "--heading", "--line-number", "--with-filename", "--no-filename", "--label" },
    description = {
        ["grep"] = "Print lines matching a pattern."
    },
    flagDescriptions = {
        ["-i"] = "Ignore case.",
        ["-I"] = "Don't match binary files.",
        ["-v"] = "Invert the sense of matching.",
        ["-h"] = "Do not output the file names.",
        ["-H"] = "Always output the file names.",
        ["-n"] = "Prefix each line of output with the 1-based line number within its input file.",
        ["-l"] = "Show only the names of files with matching lines.",
        ["-L"] = "Show only the names of files with no matching lines.",
        ["-e"] = "Use the next argument as the pattern.",
        ["-E"] = "Use extended regular expression.",
        ["-G"] = "Use basic regular expression.",
        ["-F"] = "Use fixed strings.",
        ["-w"] = "Match the whole word.",
        ["-c"] = "Show the number of matching lines.",
        ["-o"] = "Show only the matching part of the lines.",
        ["-q"] = "Suppress all normal output.",
        ["--text"] = "Treat all files as text.",
        ["--binary"] = "Treat all files as binary.",
        ["--files-with-matches"] = "Show only the names of files with matching lines.",
        ["--files-without-match"] = "Show only the names of files with no matching lines.",
        ["--count"] = "Show the number of matching lines.",
        ["--name-only"] = "Show only the names of files with matching lines.",
        ["--full-name"] = "Show the full file name.",
        ["--line-number"] = "Prefix each line of output with the 1-based line number within its input file.",
        ["--no-messages"] = "Suppress all normal output.",
        ["--color"] = "Show the matching strings in color.",
        ["--break"] = "Print a newline after each match.",
        ["--heading"] = "Print the file name before each match.",
        ["--show-function"] = "Show the matching function name.",
        ["--show-function-line"] = "Show the matching function name and line number.",
        ["--null"] = "Print a null after the file name.",
        ["--after-context"] = "Print lines after the match.",
        ["--before-context"] = "Print lines"
    }
}

local init = {
    arg = "init",
    flags = { "--bare", "--template", "--separate-git-dir", "--shared", "--quiet", "--no-quiet", "--initial-branch" },
    description = {
        ["init"] = "Create an empty Git repository or reinitialize an existing one."
    },
    flagDescriptions = {
        ["--bare"] = "Create a bare repository.",
        ["--template"] = "Specify the directory from which templates will be used.",
        ["--separate-git-dir"] = "Instead of placing the cloned repository where it is supposed to be, " ..
            "use this option to place the cloned repository at the specified directory.",
        ["--shared"] = "Specify the sharing mode for the repository.",
        ["--quiet"] = "Only print error and warning messages.",
        ["--no-quiet"] = "Print all messages.",
        ["--initial-branch"] = "Specify the name of the initial branch."
    }
}

local log = {
    arg = "log",
    flags = { "-p", "-u", "-S", "-G", "-L", "-n", "--stat", "--shortstat", "--name-only", "--name-status", "--abbrev-commit", "--oneline", "--encoding", "--full-diff", "--log-size" },
    description = {
        ["log"] = "Show commit logs."
    },
    flagDescriptions = {
        ["-p"] = "Generate patch (see section on generating patches).",
        ["-u"] = "Generate patch in unified diff format.",
        ["-S"] = "Look for differences that introduce or remove an instance of <string>.",
        ["-G"] = "Look for differences whose patch text contains <string>.",
        ["-L"] = "Trace the evolution of the line range given by '<start>,<end>' in the <file>.",
        ["-n"] = "Limit the number of commits to output.",
        ["--stat"] = "Generate a diffstat.",
        ["--shortstat"] = "Output only the last line of the --stat format containing the total number of modified files, as well as the number of added and deleted lines.",
        ["--name-only"] = "Show only names of changed files.",
        ["--name-status"] = "Show only names and status of changed files.",
        ["--abbrev-commit"] = "Show only the first few characters of the SHA-1.",
        ["--oneline"] = "Show each commit as a single line.",
        ["--encoding"] = "Show the commit message given a particular encoding.",
        ["--full-diff"] = "Show the full diff.",
        ["--log-size"] = "Show the size of the log."
    }
}

local merge = {
    arg = "merge",
    flags = { "--no-commit", "--no-ff", "--ff-only", "--ff", "--squash", "--commit", "--edit", "--no-edit", "--verify-signatures", "--no-verify-signatures", "--gpg-sign", "--no-gpg-sign", "--allow-unrelated-histories", "--strategy", "--strategy-option", "--rerere-autoupdate", "--no-rerere-autoupdate", "--quiet", "--verbose" },
    description = {
        ["merge"] = "Join two or more development histories together."
    },
    flagDescriptions = {
        ["--no-commit"] = "Perform the merge but pretend the merge failed and do not autocommit.",
        ["--no-ff"] = "Create a merge commit even when the merge resolves as a fast-forward.",
        ["--ff-only"] = "Refuse to merge and exit with a non-zero status unless the current HEAD is already up-to-date or the merge can be resolved as a fast-forward.",
        ["--ff"] = "Allow the merge to be resolved as a fast-forward.",
        ["--squash"] = "Construct a commit that is a squash of the changes in a previous commit.",
        ["--commit"] = "Perform the merge and commit the result.",
        ["--edit"] = "Use the selected commit message and launch an editor.",
        ["--no-edit"] = "Use the selected commit message without launching an editor.",
        ["--verify-signatures"] = "Verify that the tip commit of the side branch being merged is signed with a valid key.",
        ["--no-verify-signatures"] = "Do not verify the signatures.",
        ["--gpg-sign"] = "GPG-sign the resulting merge commit.",
        ["--no-gpg-sign"] = "Do not GPG-sign the resulting merge commit.",
        ["--allow-unrelated-histories"] = "Allow the merge to be performed even if the histories being merged have no common commit.",
        ["--strategy"] = "Use the given merge strategy.",
        ["--strategy-option"] = "Pass the argument through to the merge strategy.",
        ["--rerere-autoupdate"] = "Allow the rerere mechanism to update the index with the result of auto-conflict resolution if possible."
    }
}

local mv = {
    arg = "mv",
    flags = { "-f", "-k", "-n", "-v" },
    description = {
        ["mv"] = "Move or rename a file, a directory, or a symlink."
    },
    flagDescriptions = {
        ["-f"] = "Force the move/rename.",
        ["-k"] = "Skip move/rename actions which would lead to an error.",
        ["-n"] = "Do not overwrite an existing file.",
        ["-v"] = "Be verbose."
    }
}

local pull = {
    arg = "pull",
    flags = { "--rebase", "--no-rebase", "--ff-only", "--no-ff", "--ff", "--squash", "--commit", "--edit", "--no-edit", "--verify-signatures", "--no-verify-signatures", "--gpg-sign", "--no-gpg-sign", "--allow-unrelated-histories", "--strategy", "--strategy-option", "--rerere-autoupdate", "--no-rerere-autoupdate", "--quiet", "--verbose" },
    description = {
        ["pull"] = "Fetch from and integrate with another repository or a local branch."
    },
    flagDescriptions = {
        ["--rebase"] = "Rebase the current branch on top of the upstream branch after fetching.",
        ["--no-rebase"] = "Merge the current branch on top of the upstream branch after fetching.",
        ["--ff-only"] = "Refuse to merge and exit with a non-zero status unless the current HEAD is already up-to-date or the merge can be resolved as a fast-forward.",
        ["--no-ff"] = "Create a merge commit even when the merge resolves as a fast-forward.",
        ["--ff"] = "Allow the merge to be resolved as a fast-forward.",
        ["--squash"] = "Construct a commit that is a squash of the changes in a previous commit.",
        ["--commit"] = "Perform the merge and commit the result.",
        ["--edit"] = "Use the selected commit message and launch an editor.",
        ["--no-edit"] = "Use the selected commit message without launching an editor.",
        ["--verify-signatures"] = "Verify that the tip commit of the side branch being merged is signed with a valid key.",
        ["--no-verify-signatures"] = "Do not verify the signatures.",
        ["--gpg-sign"] = "GPG-sign the resulting merge commit.",
        ["--no-gpg-sign"] = "Do not GPG-sign the resulting merge commit.",
        ["--allow-unrelated-histories"] = "Allow the merge to be performed even if the histories being merged have no common commit.",
        ["--strategy"] = "Use the given merge strategy.",
        ["--strategy-option"] = "Pass the argument through to the merge strategy.",
        ["--rerere-autoupdate"] = "Allow the rerere mechanism to update the index with the result of auto-conflict resolution if possible."
    }
}

local push = {
    arg = "push",
    flags = { "--all", "--prune", "--mirror", "--delete", "--tags", "--follow-tags", "--no-follow-tags", "--signed", "--no-signed", "--force", "--force-with-lease", "--dry-run", "--receive-pack", "--exec", "--thin", "--no-thin", "--quiet", "--verbose", "--progress", "--recurse-submodules", "--no-recurse-submodules", "--verify", "--no-verify" },
    description = {
        ["push"] = "Update remote refs along with associated objects."
    },
    flagDescriptions = {
        ["--all"] = "Push all branches.",
        ["--prune"] = "Remove remote branches that don't have a local counterpart.",
        ["--mirror"] = "Mirror all refs.",
        ["--delete"] = "Remove remote branches.",
        ["--tags"] = "Push tags.",
        ["--follow-tags"] = "Push annotated tags along with the branch.",
        ["--no-follow-tags"] = "Do not push annotated tags along with the branch.",
        ["--signed"] = "GPG-sign the push.",
        ["--no-signed"] = "Do not GPG-sign the push.",
        ["--force"] = "Force the push.",
        ["--force-with-lease"] = "Force the push but only if the remote ref is unchanged.",
        ["--dry-run"] = "Show what would be done, without making any changes.",
        ["--receive-pack"] = "Specify the receive pack.",
        ["--exec"] = "Specify the receive pack.",
        ["--thin"] = "Use the thin pack.",
        ["--no-thin"] = "Do not use the thin pack.",
        ["--quiet"] = "Suppress all normal output.",
        ["--verbose"] = "Be verbose.",
        ["--progress"] = "Be verbose.",
        ["--recurse-submodules"] = "Push the submodules.",
        ["--no-recurse-submodules"] = "Do not push the submodules.",
        ["--verify"] = "Verify the push.",
        ["--no-verify"] = "Do not verify the push."
    }
}

local rebase = {
    arg = "rebase",
    flags = { "--onto", "--continue", "--skip", "--abort", "--quit", "--edit-todo", "--show-current-patch", "--verbose", "--quiet", "--autosquash", "--no-autosquash", "--autostash", "--no-autostash", "--fork-point", "--ignore-date", "--committer-date-is-author-date", "--ignore-whitespace", "--whitespace", "--ignore-space-change", "--ignore-all-space", "--ignore-blank-lines", "--ignore-cr-at-eol", "--apply", "--3way", "--force-rebase", "--no-ff", "--ff-only", "--keep-empty", "--root", "--onto", "--preserve-merges", "--rebase-merges", "--strategy", "--strategy-option", "--interactive", "--exec", "--onto", "--continue", "--skip", "--abort", "--quit", "--edit-todo", "--show-current-patch", "--verbose", "--quiet", "--autosquash", "--no-autosquash", "--autostash", "--no-autostash", "--fork-point", "--ignore-date", "--committer-date-is-author-date", "--ignore-whitespace", "--whitespace", "--ignore-space-change", "--ignore-all-space", "--ignore-blank-lines", "--ignore-cr-at-eol", "--apply", "--3way", "--force-rebase", "--no-ff", "--ff-only", "--keep-empty", "--root", "--onto", "--preserve-merges", "--rebase-merges", "--strategy", "--strategy-option", "--interactive", "--exec" },
    description = {
        ["rebase"] = "Reapply commits on top of another base tip."
    },
    flagDescriptions = {
        ["--onto"] = "Rebase the current branch onto <newbase> instead of <upstream>.",
        ["--continue"] = "Continue the rebase.",
        ["--skip"] = "Skip the current patch.",
        ["--abort"] = "Abort the rebase.",
        ["--quit"] = "Abort the rebase.",
        ["--edit-todo"] = "Edit the todo list during an interactive rebase.",
        ["--show-current-patch"] = "Show the current patch.",
        ["--verbose"] = "Be verbose.",
        ["--quiet"] = "Suppress all normal output.",
        ["--autosquash"] = "Automatically squash the commits.",
        ["--no-autosquash"] = "Do not automatically squash the commits.",
        ["--autostash"] = "Automatically stash the changes.",
        ["--no-autostash"] = "Do not automatically stash the changes.",
        ["--fork-point"] = "Use the fork point.",
        ["--ignore-date"] = "Use the current date.",
        ["--committer-date-is-author-date"] = "Use the author date.",
        ["--ignore-whitespace"] = "Ignore whitespace.",
        ["--whitespace"] = "Use the whitespace.",
        ["--ignore-space-change"] = "Ignore space change.",
        ["--ignore-all-space"] = "Ignore all space.",
        ["--ignore-blank-lines"] = "Ignore blank lines.",
        ["--ignore-cr-at-eol"] = "Ignore CR at EOL.",
        ["--apply"] = "Apply the patch.",
        ["--3way"] = "Use the 3-way merge.",
        ["--force-rebase"] = "Force the rebase.",
        ["--no-ff"] = "Create a merge commit even when the merge resolves as a fast-forward.",
        ["--ff-only"] = "Refuse to merge and exit with a non-zero status unless the current HEAD is already up-to-date or the merge can be resolved as a fast-forward.",
        ["--keep-empty"] = "Keep the empty commits.",
        ["--root"] = "Rebase all commits.",
        ["--preserve-merges"] = "Preserve the merges.",
        ["--rebase-merges"] = "Rebase the merges.",
        ["--strategy"] = "Use the given merge strategy.",
        ["--strategy-option"] = "Pass the argument through to the merge strategy.",
        ["--interactive"] = "Use the interactive rebase.",
        ["--exec"] = "Use the exec rebase."
    }
}

local reset = {
    arg = "reset",
    flags = { "--soft", "--mixed", "--hard", "--merge", "--keep", "--recurse-submodules", "--no-recurse-submodules", "--quiet", "--verbose" },
    description = {
        ["reset"] = "Reset current HEAD to the specified state."
    },
    flagDescriptions = {
        ["--soft"] = "Do not touch the index file or the working tree at all, but reset the head to <commit>.",
        ["--mixed"] = "Reset the index but not the working tree (i.e., the changed files are preserved but not marked for commit) and reports what has not been updated.",
        ["--hard"] = "Reset the index and working tree.",
        ["--merge"] = "Reset the index and update the files in the working tree that are different between <commit> and HEAD.",
        ["--keep"] = "Reset the index but not the working tree (i.e., the changed files are preserved but not marked for commit) and reports what has not been updated.",
        ["--recurse-submodules"] = "Reset the submodules.",
        ["--no-recurse-submodules"] = "Do not reset the submodules.",
        ["--quiet"] = "Suppress all normal output.",
        ["--verbose"] = "Be verbose."
    }
}

local restore = {
    arg = "restore",
    flags = { "--source", "--staged", "--worktree", "--quiet", "--source", "--staged", "--worktree", "--quiet" },
    description = {
        ["restore"] = "Restore working tree files."
    },
    flagDescriptions = {
        ["--source"] = "Restore the specified source.",
        ["--staged"] = "Restore the staged files.",
        ["--worktree"] = "Restore the working tree files.",
        ["--quiet"] = "Suppress all normal output."
    }
}

local rm = {
    arg = "rm",
    flags = { "-f", "-n", "-r", "--cached", "--quiet", "--force", "--dry-run" },
    description = {
        ["rm"] = "Remove files from the working tree and from the index."
    },
    flagDescriptions = {
        ["-f"] = "Force the removal.",
        ["-n"] = "Do not remove the files.",
        ["-r"] = "Remove the files recursively.",
        ["--cached"] = "Remove the files from the index.",
        ["--quiet"] = "Suppress all normal output.",
        ["--force"] = "Force the removal.",
        ["--dry-run"] = "Show what would be done, without making any changes."
    }
}

local commandAliases = { "add", "bisect", "branch", "checkout", "clone", "commit", "fetch", "grep", "init",
    "log", "merge", "mv", "pull", "push", "rebase", "reset", "restore", "rm", "show", "show-branch",
    "switch", "stash", "tag" }

local branchLocalAliases = { "checkout", "push", "switch" }
local branchRemoteAliases = { "branch", "diff", "fetch", "merge", "pull", "rebase", "reset", "show", "show-branch" }
local resetAliases = { "add", "mv", "restore", "rm" }

local flags = { "-n", "-v", "-f" }

local gitAutocomplete = clink.generator(10)

local function getCommands()
    local commands = {}
    table.insert(commands, status)
    table.insert(commands, show)
    table.insert(commands, diff)
    table.insert(commands, add)
    table.insert(commands, bisect)
    table.insert(commands, branch)
    table.insert(commands, checkout)
    table.insert(commands, clone)
    table.insert(commands, commit)
    table.insert(commands, fetch)
    table.insert(commands, grep)
    table.insert(commands, init)
    table.insert(commands, log)
    table.insert(commands, merge)
    table.insert(commands, mv)
    table.insert(commands, pull)
    table.insert(commands, push)
    table.insert(commands, rebase)
    table.insert(commands, reset)
    table.insert(commands, restore)
    table.insert(commands, rm)
    return commands
end

local function rebuildArgs()
    clink.argmatcher("git"):reset()
    for k, v in pairs(getCommands()) do
        local flagParser = clink.argmatcher():addflags(v.flags):adddescriptions(v.flagDescriptions)
        local parser = clink.argmatcher():addarg(v.arg .. flagParser):adddescriptions(v.description)
        parser:nofiles()
        clink.argmatcher("git"):addarg(parser):nofiles()
    end
end

function gitAutocomplete:generate(lineState, match_builder)
    if lineState:getword(1) ~= "git" then
        return false
    end
    local alias = lineState:getword(2)
    local matchCount = 0
    if lineState:getwordcount() > 4 then
        return false
    end
    if alias then
        if hasValue(branchLocalAliases, alias) then
            for k, v in ipairs(getBranchesLocal()) do
                match_builder:addmatch(v)
                matchCount = matchCount + 1
            end
        elseif hasValue(branchRemoteAliases, alias) then
            for k, v in ipairs(getBranchesRemote()) do
                match_builder:addmatch(v)
                matchCount = matchCount + 1
            end
            for k, v in ipairs(getBranchesLocal()) do
                match_builder:addmatch(v)
                matchCount = matchCount + 1
            end
        end
    end

    return matchCount > 0
end

rebuildArgs()
