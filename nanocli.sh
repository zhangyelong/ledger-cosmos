#!/usr/bin/env bash
#*******************************************************************************
#*   (c) 2018 ZondaX GmbH
#*
#*  Licensed under the Apache License, Version 2.0 (the "License");
#*  you may not use this file except in compliance with the License.
#*  You may obtain a copy of the License at
#*
#*      http://www.apache.org/licenses/LICENSE-2.0
#*
#*  Unless required by applicable law or agreed to in writing, software
#*  distributed under the License is distributed on an "AS IS" BASIS,
#*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*  See the License for the specific language governing permissions and
#*  limitations under the License.
#********************************************************************************

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

# PK = 0425966465974196228d1d8a72e3c4cb6b62d6d5b8ffdeeba3af6677551e5413a60c47517e0bee963af31f5606c33a9483e8a6dc102c63bc295691ca05ee2c5d5c
# SK = 0130a1c6fa9154cad78d91a8ecbbdbba7e1efbff01840997949130bba5cb38cd

# python -m ledgerblue.setupCustomCA --name dev --public 0425966465974196228d1d8a72e3c4cb6b62d6d5b8ffdeeba3af6677551e5413a60c47517e0bee963af31f5606c33a9483e8a6dc102c63bc295691ca05ee2c5d5c --targetId 0x31100003

handle_config()
{
    os_string="$(uname -s)"
    case "${os_string}" in
        Linux*)
            sudo apt-get install libusb-1.0.0 libudev-dev
            pip install -U setuptools
            pip install -U --no-cache ledgerblue ecpy
            ;;
        Darwin*)
            brew install libusb
            pip install -U ledgerblue ecpy
            ;;
        *)
            echo "OS not recognized"
            ;;
    esac

}

handle_ca()
{
    python -m ledgerblue.setupCustomCA --name dev --public 0425966465974196228d1d8a72e3c4cb6b62d6d5b8ffdeeba3af6677551e5413a60c47517e0bee963af31f5606c33a9483e8a6dc102c63bc295691ca05ee2c5d5c --targetId 0x31100003
}

# Ledger User App scripts

handle_umake()
{
    # This function works in the scope of the container
    DOCKER_IMAGE=zondax/ledger-docker-bolos
    BOLOS_SDK=/project/src/ledger-user/deps/nanos-secure-sdk
    BOLOS_ENV=/opt/bolos

    docker run -i --rm \
            -e BOLOS_SDK=${BOLOS_SDK} \
            -e BOLOS_ENV=${BOLOS_ENV} \
            -u $(id -u) \
            -v $(pwd):/project \
            ${DOCKER_IMAGE} \
            make -C /project/src/ledger-user $1
}

handle_uexec()
{
    # This function works in the scope of the container
    DOCKER_IMAGE=zondax/ledger-docker-bolos
    BOLOS_SDK=/project/src/ledger-user/deps/nanos-secure-sdk
    BOLOS_ENV=/opt/bolos

    docker run -i --rm \
            -e BOLOS_SDK=${BOLOS_SDK} \
            -e BOLOS_ENV=${BOLOS_ENV} \
            -u `id -u` \
            -v $(pwd):/project \
            ${DOCKER_IMAGE} \
            $1
}

handle_uload()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/src/ledger-user/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger-user load
}

handle_udelete()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/src/ledger-user/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger-user delete
}

# Ledger Validator App scripts

handle_vmake()
{
    # This function works in the scope of the container
    DOCKER_IMAGE=zondax/ledger-docker-bolos
    BOLOS_SDK=/project/src/ledger-val/deps/nanos-secure-sdk
    BOLOS_ENV=/opt/bolos

    docker run -i --rm \
            -e BOLOS_SDK=${BOLOS_SDK} \
            -e BOLOS_ENV=${BOLOS_ENV} \
            -u $(id -u) \
            -v $(pwd):/project \
            ${DOCKER_IMAGE} \
            make -C /project/src/ledger-val $1
}

handle_vexec()
{
    # This function works in the scope of the container
    DOCKER_IMAGE=zondax/ledger-docker-bolos
    BOLOS_SDK=/project/src/ledger-val/deps/nanos-secure-sdk
    BOLOS_ENV=/opt/bolos

    docker run -i --rm \
            -e BOLOS_SDK=${BOLOS_SDK} \
            -e BOLOS_ENV=${BOLOS_ENV} \
            -u `id -u` \
            -v $(pwd):/project \
            ${DOCKER_IMAGE} \
            $1
}

handle_vload()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/src/ledger-val/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger-val load
}

handle_vdelete()
{
    # This function works in the scope of the host
    export BOLOS_SDK=${SCRIPT_DIR}/src/ledger-val/deps/nanos-secure-sdk
    export BOLOS_ENV=/opt/bolos
    make -C ${SCRIPT_DIR}/src/ledger-val delete
}

case "$1" in
    uexec)       handle_uexec $2;;
    umake)       handle_umake $2;;
    uload)       handle_uload;;
    udelete)     handle_udelete;;

    vexec)       handle_vexec $2;;
    vmake)       handle_vmake $2;;
    vload)       handle_vload;;
    vdelete)     handle_vdelete;;

    config)     handle_config;;
    ca)         handle_ca;;
    *)
        echo "ERROR. Valid commands: exec, make, config, ca, load, delete"
        ;;
esac
