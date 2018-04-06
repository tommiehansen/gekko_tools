####
# Copyright (c) 2013, Florian Sowade <f.sowade@r9e.de>
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
# any POSIX shell.
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

    eval "${name}_COUNT=0"
}

##
# Get the current amount of entries inside an existing array
#
# @param name
##
ARRAY_count() {
    local name="${1}"

    eval "echo \"\${${name}_COUNT}\""
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

    local index="$(ARRAY_count "${name}")"

    eval "${name}_${index}='${value}'"
    eval "${name}_COUNT=$(( ${index} + 1 ))"
}

##
# Peek at a value from the end of the provided array name without removing it
#
# @param name
##
ARRAY_peek() {
    local name="${1}"

    local index="$(( $(ARRAY_count "${name}") - 1 ))"
    eval "echo \"\${${name}_${index}}\""
}

##
# Pop a value from the end of the provided array name
#
# @param name
##
ARRAY_pop() {
    local name="${1}"

    local index="$(( $(ARRAY_count "${name}") - 1 ))"
    eval "echo \"\${${name}_${index}}\""
    eval "${name}_COUNT=${index}"
    eval "unset ${name}_${index}"
}
