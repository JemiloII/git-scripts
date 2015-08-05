#!/bin/bash
# Expects that you have your username and password saved in the git config

# Get current branch as source.
current_branch="$(git symbolic-ref HEAD 2>/dev/null)"
current_branch=${current_branch##refs/heads/}

# Process the Reverse Merge
/usr/bin/expect <<EOF
	set timeout 9
	set env(noconflicts) false

    spawn /bin/bash
    expect_background -re .+

	send "git stash\r"
	expect {
		default {}
		"No local changes to save" {}
	}

    send "git checkout develop\r"
    expect {
    	"Switched to branch 'develop'" {}
    }

    send "git pull\r"
    expect {
    	default {}
    	"Already up-to-date." {}
    }

    send "git checkout $current_branch\r"
    expect {
    	"Switched to branch '$current_branch'" {}
    }

    send "git merge develop\r"
    expect {
		"Already up-to-date" {
			set env(noconflicts) true;
		}
    }

	send "git stash pop\r"
	expect {
		default {}
	}

    send "git status\r"
    expect {
    	"nothing added to comit" {}
    }

    puts "Reverse Merge Complete!"
EOF
