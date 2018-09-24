load bash functions

# motivation
a framework to load functions developed independently in bash shell, just like other language, like python import, C include

# how to use it
just add `eval "$(SCRIPT-NAME)"`, then use `load TEMPLATE` to load functions in TEMPLATE file. SCRIPT-NAME is the name of load script, now is load-funcs.