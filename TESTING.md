# Testing component modules

You must read and follow [rbenv installation and setup](https://criticalmedia.atlassian.net/wiki/spaces/SYS/pages/486014993/rbenv+installation+and+setup) first.


## The test commands

Since the gems were not installed globally, you will have to prepend the testing
commands with `bundle exec`. Testing will be done via rake tasks. To get a list
of all the rake tasks run `bundle exec rake help`. Generally you will only use:

```console
$ bundle exec rake precommit
```

## git pre-commit hook

The rake tasks are intended to save time by not having to wait for a puppet run
to fail before you know if there is an error. To ensure the `precommit`
task runs automatically, you should set a pre-commit hook. The following will
suffice:

```console
$ cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
git stash save -q --keep-index --include-untracked
bundle exec rake precommit
RESULT=$?
git stash pop -q
[ $RESULT -ne 0 ] && exit 1
exit 0
EOF
$ chmod +x .git/hooks/pre-commit
```

If the commit fails it will tell you why allowing you to fix it and re-commit.
Once the commit goes through, you should be ready to push with some extra
confidence that your changes didn't break anything.

[comment]: <> ( vim: set ts=8 sw=8 et: )
