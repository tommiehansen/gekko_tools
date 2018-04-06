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
#
# This file does include a generic compatibility layer for accessing arrays in
# zsh.
#
####

##
# Define a variable as an empty array
#
# The variable should already exist in the scope you want to use it in
#
# @param name
##
ARRAY_define() {
    local name="${1}"

    eval "${name}=()"
}

##
# Get the current amount of entries inside an existing array
#
# @param name
##
ARRAY_count() {
    local name="${1}"

    if [ -z "$(eval "echo \"\${${name}}\"")" ]; then
        echo "0"
    else
        eval "echo \"\${#${name}[@]}\""
    fi
}

##
# Get a certain index stored inside an array
#
# The index is zero based. The first entry entry is therefore supposed to be 0.
# If the used shell does only provide 1-based arrays this needs to be mapped
# inside of this function accordingly
#
# @param name
# @param index
##
ARRAY_get() {
    local name="${1}"
    local index="$((${2}+1))"

    eval "echo \"\${${name}[${index}]}\""
}

##
# Set a certain value stored to a certain index inside an array
#
# The index is zero based. The first entry entry is therefore supposed to be 0.
# If the used shell does only provide 1-based arrays this needs to be mapped
# inside of this function accordingly
#
# @param name
# @param index
# @param value
##
ARRAY_set() {
    local name="${1}"
    local index="$((${2}+1))"
    local value="${3}"

    eval "${name}[${index}]=\"${value}\""
}

##
# Push a given value to the end of the provided array name
#
# @param name
# @param value
##
ARRAY_push() {
    local name="${1}"
    local value="${2}"
    
    local index="$(($(eval "echo \${#${name}[@]}")+1))"

    eval "${name}[${index}]=\"${value}\""
}

##
# Peek at a value from the end of the provided array name without removing it
#
# @param name
##
ARRAY_peek() {
    local name="${1}"

    eval "echo \"\${${name}[\${#${name}[@]}]}\""
}

##
# Pop a value from the end of the provided array name
#
# @param name
##
ARRAY_pop() {
    local name="${1}"

    local index="$(eval "echo \${#${name}[@]}")"

    echo "$(ARRAY_peek "${name}")"
    ARRAY_unset "${name}" "$((${index}-1))"
}

##
# Unset a certain index from the given array
#
# @param name
##
ARRAY_unset() {
    local name="${1}"
    local index="$((${2}+1))"

    eval "${name}[${index}]=()"
}
