# Git-Soft-Conflicts
Checks for any files modified in both your current Git directory and unmerged changed on Gerrit

### Sample usage and output:

Run from your git repo:

```
$ ruby ~/gitConflicts/conflicts.rb
```

Output:

```
You and Steven Farberov are both modifying the files: src/features/campaign-manage/components/ManageBladeTabs/SomeFile.js
See Steven Farberov's commit "This is a commit msg" at https://gerrit.rfiserve.net/1234
```

default project = ui/orion

default recency (last modified time for the change) = 2 (days)

Example with command-line args:

```
$ ruby ~/gitConflicts/conflicts.rb --project=api/fuel --recency=5
```

### Quick Run
Add an alias within your bashrc or zshrc config
```
alias conflicts='ruby /Users/userName/path-to-repo/Git-Soft-Conflicts/conflicts.rb'
```
Then simply run `conflicts` to save yourself time. 
