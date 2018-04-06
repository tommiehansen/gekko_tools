####
# Copyright (c) 2012, Jakob Westhoff <jakob@qafoo.com>
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  - Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
####

source "${COLORIZE_SH_SOURCE_DIR:-$( cd "$( dirname "${BASH_SOURCE:-${0}}" )" && pwd )}/Compatibility/compatibility.sh"

# Escape codes
COLORIZER_START=${COLORIZER_START:="\033["}
COLORIZER_END=${COLORIZER_END:="m"}

# Default colors
COLORIZER_blue=${COLORIZER_blue:="0;34"}
COLORIZER_green=${COLORIZER_green:="0;32"}
COLORIZER_cyan=${COLORIZER_cyan:="0;36"}
COLORIZER_red=${COLORIZER_red:="0;31"}
COLORIZER_purple=${COLORIZER_purple:="0;35"}
COLORIZER_yellow=${COLORIZER_yellow:="0;33"}
COLORIZER_gray=${COLORIZER_gray:="1;30"}
COLORIZER_light_blue=${COLORIZER_light_blue:="1;34"}
COLORIZER_light_green=${COLORIZER_light_green:="1;32"}
COLORIZER_light_cyan=${COLORIZER_light_cyan:="1;36"}
COLORIZER_light_red=${COLORIZER_light_red:="1;31"}
COLORIZER_light_purple=${COLORIZER_light_purple:="1;35"}
COLORIZER_light_yellow=${COLORIZER_light_yellow:="1;33"}
COLORIZER_light_gray=${COLORIZER_light_gray:="0;37"}

# Somewhat special colors
COLORIZER_black=${COLORIZER_black:="0;30"}
COLORIZER_white=${COLORIZER_white:="1;37"}
COLORIZER_none=${COLORIZER_none:="0"}

##
# Parse the input and return the ansi code output processed output
##
COLORIZER_process_input() {
    local prompt_option="${1}"
    local strip_option="${2}"
    shift 2
    local processed="${*}"
    local pseudoTag=""

    local stack
    ARRAY_define "stack"

    local result=""
    local ansiToken=""

    result="${processed%%<*}"
    if [ "${result}" != "" ] && [ "${result}" != "${processed}" ]; then
        # Cut outer content, which has been processed already
        processed="<${processed#*<}"
    fi
    while [ "${processed#*<}" != "${processed}" ]; do
        # Isolate first tag in stream
        pseudoTag="${processed#*<}"
        pseudoTag="${pseudoTag%%>*}"

        # Push/Pop tag to/from stack
        if [ "${pseudoTag:0:1}" != "/" ]; then
            ARRAY_push "stack" "${pseudoTag}"
        else
            if [ "${pseudoTag:1}" != "$(ARRAY_peek "stack")" ]; then
                echo "Mismatching colorize tag nesting at <$(ARRAY_peek "stack")>...<${pseudoTag}>"
                exit 42
            fi
            ARRAY_pop "stack" >/dev/null
        fi

        # Apply ansi formatting
        if [ -z "${strip_option}" ]; then
            pseudoTag="${pseudoTag/-/_}"
            if [ "${pseudoTag:0:1}" != "/" ]; then
                # Opening Tag
                eval "ansiToken=\"\${COLORIZER_${pseudoTag}}\""
            else
                # Closing Tag
                if [ "$(ARRAY_count "stack")" -eq 0 ]; then
                    ansiToken="${COLORIZER_none}"
                else
                    eval "ansiToken=\"\${COLORIZER_$(ARRAY_peek "stack")}\""
                fi
            fi

            # Add escape codes
            ansiToken="${COLORIZER_START}${ansiToken}${COLORIZER_END}"
            if [ "${prompt_option}" = "SET" ]; then
                ansiToken="\[${ansiToken}\]"
            fi

            result="${result}${ansiToken}"
        fi

        # Cut processed portion from stream
        processed="${processed#*>}"

        # Update result with next content part
        result="${result}${processed%%<*}"
    done

    if [ "$(ARRAY_count "stack")" -ne 0 ]; then
        echo "Could not find closing tag for <$(ARRAY_peek "stack")>"
        exit 42
    fi

    result="${result//&lt;/<}"
    result="${result//&gt;/>}"
    echo "${result}"
}

##
# Parse a given colorize string and output the correctly escaped ansi-code
# formatted string for it.
#
# This function is the only public API method to this utillity
#
# echo -e is used for output.
#
# The -n option may be specified, which will behave exactly like echo -n, aka
# omitting the newline.
#
# To use ansi in a prompt without behaving badly, using the -p option.
#
# @option -n omit the newline
# @option -p escape ansi for prompt usage
# @option -s instead of replacing with ansi, just strip the tags
# @param [string,...]
##
colorize() {
    local OPTIND=1
    local newline_option=""
    local prompt_option=""
    local strip_option=""
    local option=""
    while getopts ":nps" option; do
        case "${option}" in
            n) newline_option="SET";;
            p) prompt_option="SET";;
            s) strip_option="SET";;
            \?) echo "Invalid option (-${OPTARG}) given to colorize"; exit 42;;
        esac
    done
    shift $((OPTIND-1))

    local processed_message="$(COLORIZER_process_input "${prompt_option}" "${strip_option}" "${@}")"

    if [ "${newline_option}" = "SET" ]; then
        echo -en "${processed_message}"
    else
        echo -e "${processed_message}"
    fi
}

# Allow alternate spelling
alias colourise=colorize
