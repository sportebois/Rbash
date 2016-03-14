# Rbash

Shell script to make it easy to launch R scripts from the command line.


## What is it useful for?

R can read the command line arguments. But what if you want to be able to run _exactly_  the same scripts from an IDE and from the command line, and to override some settings in a given context.
Rbash tries to offer a simple way to achieve this.


## Usage

Rbash does accept a few arguments:  
- `-f file.R` let you specify a R file to source. You can use the -f argument several times to source multiple files.
- `-o variableName=someValue` let you set a variable name and its value that will be stored in the Options collector in R. You can use the -o argument several times to set multiple options.
- `-c` Automatically delete the outputs and logs upon completion,
- `-q` Doe snot print the R console in the terminal (you can still access it in the log file, unless you use the `-c` argument)


Some files will be created:
- a .R file combining the files to source and options definitions.
- a .log file with the output (ie the R console)
- a .err file might be created, if any error occurred.
If you're only interested by the side effect of your script you can also use the `-c` (clean) argument to automatically delete these files.

## Examples


The most basic use is simply executing an R script
`Rbash.sh -f commands.R`

But it becomes interesting when you start combining multiple files and options.

The sample `commands.R` script available in this repo does source another file and set different values with some defaults :

```
# commands.R
print("sourcing 'commands.R'")

source("defaultTestValue.R")
testVal <- getOption("test",  default = "defaultTestInCommands")
print(paste0("test value is ", testVal))

testVal2 <- getOption("test2", default = "defaultTest2InCommands")
print(paste0("test2 value is ", testVal2))
```

So you can see that `commands.R` set defaults for `test` and `test2`. And source `defaultTestValue.R`.

Here's the defaultTestValue's code:

```
# defaultTestValue.R
print("sourcing 'defaultTestValue.R'")
options(test="defaultTestInSourcedFile")
```

As you can see, defaultTestValue set a value for the `test` variable. (Therefore the default in commands.R should never show up).


A similar script `overrideTestValue.R` set a default value for test2.

```
#overrideTestValue.R
print("sourcing 'overideTest2Value.R'")
options(test2="defaultTest2InOverrideFile")
```


With this content setup, you can see that the order in which you provide the code to run is taken into account: If you define the option _before_ to source the `overrideTestValue.R`, it will be overriden by the R script. But if you add the option _after_, then your command line option will override the one from the script:

```
$ ./Rbash.sh -o test2=\"valueFromShell\" -f overrideTestValue.R -f commands.R
[1] "sourcing 'overideTest2Value.R'"
[1] "sourcing 'commands.R'"
[1] "sourcing 'defaultTestValue.R'"
[1] "test value is defaultTestInSourcedFile"
[1] "test2 value is defaultTest2InOverrideFile"

$ ./Rbash.sh -f overrideTestValue.R -o test2=\"valueFromShell\"  -f commands.R
[1] "sourcing 'overideTest2Value.R'"
[1] "sourcing 'commands.R'"
[1] "sourcing 'defaultTestValue.R'"
[1] "test value is defaultTestInSourcedFile"
[1] "test2 value is valueFromShell"
```


## Pre-requisites

Obviously R must be installed and correctly accessible from the current Path.

Do not forget to chmod +x the Rbash.sh script.
