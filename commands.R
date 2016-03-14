print("sourcing 'commands.R'")

source("defaultTestValue.R")
testVal <- getOption("test",  default = "defaultTestInCommands")
print(paste0("test value is ", testVal))

testVal2 <- getOption("test2", default = "defaultTest2InCommands")
print(paste0("test2 value is ", testVal2))
