#!/usr/bin/env bash


function usage() {
    cat << EOF
Rbash: Prepare R code execution
usage: Rbash options

OPTIONS:
   -f fileName.R   Specify a file to source
   -h              Show this message
   -o name=val     Set an option that will be loaded like options(name=val)
   -q              Quiet mode
   -c              Clean after run: if option is set, then temp files (output, log and source are removed)

EXAMPLE:
   # Run a R file
   Rbash.sh -f commands.R
   # Source multiple files
   Rbash.sh -f overrideTestValue.R -f commands.R
   # set some option then run a R file
   Rbash.sh -o test2=\"valueFromShell\" -f overrideTestValue.R -f commands.R
   Rbash.sh -o test2=\"valueFromShell\" -f overrideTestValue.R -o test2=\"valueFromShell2\" -f commands.R

EOF
}


function callR() {
    Rscript --vanilla $IN
}


# Initialize
QUIET=FALSE
SCRIPT=
CLEAN=FALSE

# Read the arguments
while getopts "chf:o:q" OPTION
do
    case $OPTION in
        c)
            CLEAN=true
            ;;
		f)
            SCRIPT="${SCRIPT}source(\"${OPTARG}\")\n"
			;;
		o)
            ARG=$OPTARG
            if [[ $OPTARG =~(.*)=(.*) ]]; then
                SCRIPT="${SCRIPT}options(${BASH_REMATCH[1]}=${BASH_REMATCH[2]})\n"
            else
                echo "WARNING: Unable to parse option $OPTARG"
            fi
			;;
		h)
			usage
			exit 1
			;;
		q)
			QUIET=true
			;;
		?)
			usage
			exit
		;;
	esac
done

if [ ! -z "$SCRIPT" ]
then

    IN=$(mktemp ./Rbash.R-XXXXXXXX)
    OUT=$(mktemp ./Rbash.log-XXXXXXXX)
    ERR=$(mktemp ./Rbash.err-XXXXXXXX)

    printf $SCRIPT > $IN

    if $QUIET
    then
        callR > $ERR 2>&1 | tee $OUT
    else
        callR | tee $OUT
    fi
fi

if $CLEAN
then
    rm Rbash*.{err,log,R-}* &>/dev/null
fi
