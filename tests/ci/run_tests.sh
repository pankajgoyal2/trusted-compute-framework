#! /bin/bash

# Copyright 2019 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


PY3_VERSION=$(python3 --version | sed 's/Python 3\.\([0-9]\).*/\1/')
if [[ $PY3_VERSION -lt 5 ]]; then
    echo activate python3 first
    exit
fi

SCRIPTDIR="$(dirname $(readlink --canonicalize ${BASH_SOURCE}))"
SRCDIR="$(realpath ${SCRIPTDIR}/..)"
echo_client_path="${TCF_HOME}/examples/apps/echo/client"
automation_test_path="${TCF_HOME}/tests/automation_framework"
generic_client_path="${TCF_HOME}/examples/apps/generic_client"
# Read Listener port from config file
listener_port=`grep listener_port ${TCF_HOME}/config/tcs_config.toml | awk {'print $3'}`
LISTENER_URL="localhost"

while getopts "l:lh" OPTCHAR ; do
    case $OPTCHAR in
        l )
            LISTENER_URL=$OPTARG
            ;;
        \?|h )
            BN=$(basename $0)
            echo "$BN: Run tests for Hyperledger Avalon" 1>&2
            echo "Usage: $BN [-l|-h|-?]" 1>&2
            echo "Where:" 1>&2
            echo "   -l       specify the Listener service name" 1>&2
            echo "   -? or -h print usage information" 1>&2
            echo "Examples:" 1>&2
            echo "   $BN -l avalon-listener" 1>&2
            exit 2
            ;;
    esac
done
shift `expr $OPTIND - 1`

yell() {
    echo "$0: $*" >&2;
}

die() {
    yell "$*"
    exit 111
}

try() {
    "$@" || die "test failed: $*"
}

SAVE_FILE=$(mktemp /tmp/tcf-test.XXXXXXXXX)
INPUT_FOLDERS=(json_requests worker work_orders signature)

function cleanup {
    yell "Clearing enclave files and database files"
    rm -f ${TCF_HOME}/config/Kv*
    rm -f ${SAVE_FILE}
}

trap cleanup EXIT
#------------------------------------------------------------------------------------------------

yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"
cd ${TCF_HOME}/tests
yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"

for folder in "${INPUT_FOLDERS[@]}"
do
    yell "Start testing folder:: $folder ............"
    yell "#------------------------------------------------------------------------------------------------"
    # Delay is introduced for user readability
    sleep 5s
    try python3 ${TCF_HOME}/tests/Demo.py \
        --logfile __screen__ --loglevel warn \
        --input_dir ${TCF_HOME}/tests/$folder/ \
        --connect_uri "http://$LISTENER_URL:$listener_port" work_orders/output.json > /dev/null

    yell "#------------------------------------------------------------------------------------------------"
    yell "#------------------------------------------------------------------------------------------------"
done

# TODO: Disabled echo client run with blockchain from CI until we fix the infutra http interface issue

#yell "Start testing echo client with reading registry from blockchain................"
#yell "#------------------------------------------------------------------------------------------------"
#try $echo_client_path/echo_client.py -m "Hello world" -rs -dh

yell "Start testing echo client with service uri ................"
yell "#------------------------------------------------------------------------------------------------"
try $echo_client_path/echo_client.py -m "Hello world" -s "http://$LISTENER_URL:1947" -dh

yell "Start testing generic client for echo workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "Hello"

yell "Start testing generic client for heart disease eval workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 1"

yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"
yell "Start Generic client Tests  ................"
yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"


yell "QCID_20316_Test Workorder with incorrect workerid for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 1" -o \
    --worker_id "161ccfabf1500e10504c145a8c6ee0ecdde74827961600a7c3897cfb10956da3"
yell "Test Completed"

yell "QCID_20317_Test Workorder with incorrect workerid for echo-client workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "Hello" -o \
    --worker_id "161ccfabf1500e10504c145a8c6ee0ecdde74827961600a7c3897cfb10956da3"
yell "Test Completed"

yell "QCID_18393_Test Workorder success for echo-client workload................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "Hello" -o
yell "Test Completed"

yell "QCID_18402_Test Workorder success for heart-disease-eval workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 1" -o
yell "Test Completed"

yell "QCID_18404_Test special character for heart disease eval workload............"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 * & ! @ # %" -o
yell "Test Completed"

yell "QCID_18396_Test alpha numeric characters for echo client workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "Hello12345" -o
yell "Test Completed"

yell "QCID_18397_Test workorder only digits for echo client workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "12345678" -o
yell "Test Completed"

yell "QCID_18395_Test workorder only spaces for echo client workload ................"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "     " -o
yell "Test Completed"

yell "QCID_18403_Test workorder only special character for heart disease eval workload............"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: $ @ ! %  ^ & * # * & ! @ # %" -o
yell "Test Completed"

yell "QCID_18406_Test workorder by passing paragraph for echo client workload............"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "JMeter is a performance test tool. So it runs in parallel using multi-threading. However you can also use just 1 thread group and set the thread count to one to run it in sequence" -o
yell "Test Completed"

yell "QCID_18394_Test workorder special character payload for echo client workload............"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "#@!$%@#&*()$%#" -o
yell "Test Completed"
yell "Completed Testing ..................."

yell "QCID_18411_Test workorder random incorrect indata for heart disease workload............"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: HelloWorld" -o
yell "Test Completed"

yell "QCID_18422_Test workorder with incorrect workload............"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result1" --in_data "Hello" -o
yell "Test Completed"

yell "QCID_18439_Test workorder with empty workload............"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://avalon-listener1:1947" \
    --workload_id "" --in_data "12345678" -o
yell "Test Completed"

yell "QCID_18430_Test Workorder indata by passing negative value for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 -1" -o
yell "Test Completed"

yell "QCID_18429_Test Workorder indata by passing Data:null string for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: null" -o
yell "Test Completed"

yell "QCID_18428_Test Workorder indata by passing only null string for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "null" -o
yell "Test Completed"

yell "QCID_18428_Test Workorder indata by passing only null string for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
try $generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "null" -o
yell "Test Completed"

yell "QCID_18437_Test Workorder with empty indata for echo-client workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "" -o
yell "Test Completed"

yell "QCID_20315_Test Workorder with empty indata for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" --in_data "" -o
yell "Test Completed"

yell "QCID_20316_Test Workorder with incorrect workerid for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 1" -o \
    --worker_id ""
yell "Test Completed"

yell "QCID_20318_Test Workorder with requester signature for echo-client workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "echo-result" --in_data "RequesterSignatureEnabled1" -o --requester_signature
yell "Test Completed"

yell "QCID_20319_Test Workorder with requester signature for heart-disease-eval workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "heart-disease-eval" \
    --in_data "Data: 25 10 1 67  102 125 1 95 5 10 1 11 36 1" -o \
    --requester_signature
yell "Test Completed"

yell "QCID_18401_Test Workorder different host url"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://avalon-listener1:1947" \
    --workload_id "echo-result" --in_data "Hello" -o
yell "Test Completed"

yell "QCID_18436_Test Workorder with workload and worker ID's same"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "6563686f2d726573756c74" --in_data "Hello" -o \
    --worker_id "6563686f2d726573756c74"
yell "Test Completed"

yell "QCID_20320_Test Workorder with workload valid hex value for echo-client workload"
yell "#------------------------------------------------------------------------------------------------"
$generic_client_path/generic_client.py --uri "http://$LISTENER_URL:1947" \
    --workload_id "6563686f2d726573756c74" --in_data "Hello" -o \

yell "Completed Testing ..................."

yell "Starting Demo tests ................"
yell "#------------------------------------------------------------------------------------------------"
cd ${TCF_HOME}/tests/ci/Demo_Tests
python Demo.py --input_dir ./json_inputs/ --connect_uri "http://avalon-listener:1947" ./output.json
yell "Demo Tests Completed"

yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"
yell "Start Automated Tests  ................"
yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"

cd ${TCF_HOME}/tests/automation_framework
mkdir /project/avalon/logs
echo `pwd`
pytest -m "sdk" --junitxml /project/avalon/logs/direct_docker_results.xml \
    2>&1 | tee /project/avalon/logs/direct_docker_logs.txt


yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"

yell completed all tests
yell "#------------------------------------------------------------------------------------------------"
yell "#------------------------------------------------------------------------------------------------"

exit 0
