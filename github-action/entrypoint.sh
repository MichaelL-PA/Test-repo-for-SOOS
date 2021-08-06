#!/bin/bash

PA_BASE_URI=$1
PA_PROJECT_NAME=$2
PA_MODE=$3
PA_ON_FAILURE=$4
PA_DIRECTORIES_TO_EXCLUDE=$5
PA_FILES_TO_EXCLUDE=$6
PA_ANALYSIS_RESULT_MAX_WAIT=$7
PA_ANALYSIS_RESULT_POLLING_INTERVAL=$8
PA_DEBUG_PRINT_VARIABLES=true

PA_BRANCH_URI=${10}
PA_BUILD_VERSION=${11}
PA_BUILD_URI=${12}
PA_OPERATING_ENVIRONMENT=${13}

PA_COMMIT_HASH=${GITHUB_SHA}
PA_BRANCH_NAME=${GITHUB_REF}
PA_INTEGRATION_NAME="GitHubAction"

PA_WORKING_DIRECTORY=${GITHUB_WORKSPACE}
PA_ROOT_CODE_PATH=${GITHUB_WORKSPACE}

# export PACKAGE_AWARE_ROOT_CODE_PATH=${GITHUB_WORKSPACE}
# export PACKAGE_AWARE_API_BASE_URI=${PA_BASE_URI}
# export PACKAGE_AWARE_PROJECT_NAME=${PA_PROJECT_NAME}

echo 'Starting entrypoint.sh'

if $PA_DEBUG_PRINT_VARIABLES ; then
  echo "BEGIN DEBUG :: EXPLICIT ENV/VAR *****************************"
  echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
  echo "PA_MODE: ${PA_MODE}"
  echo "PA_ON_FAILURE: ${PA_ON_FAILURE}"
  echo "PA_DIRECTORIES_TO_EXCLUDE: ${PA_DIRECTORIES_TO_EXCLUDE}"
  echo "PA_FILES_TO_EXCLUDE: ${PA_FILES_TO_EXCLUDE}"
  echo "PA_WORKING_DIRECTORY: ${PA_WORKING_DIRECTORY}"
  echo "PA_ANALYSIS_RESULT_MAX_WAIT: ${PA_ANALYSIS_RESULT_MAX_WAIT}"
  echo "PA_ANALYSIS_RESULT_POLLING_INTERVAL: ${PA_ANALYSIS_RESULT_POLLING_INTERVAL}"
  echo "PA_ROOT_CODE_PATH: ${PA_ROOT_CODE_PATH}"
  
  echo "PA_COMMIT_HASH: ${PA_COMMIT_HASH}"
  echo "PA_BRANCH_NAME: ${PA_BRANCH_NAME}"
  echo "PA_BRANCH_URI: ${PA_BRANCH_URI}"
  echo "PA_BUILD_VERSION: ${PA_BUILD_VERSION}"
  echo "PA_BUILD_URI: ${PA_BUILD_URI}"
  echo "PA_OPERATING_ENVIRONMENT: ${PA_OPERATING_ENVIRONMENT}"
  echo "PA_INTEGRATION_NAME: ${PA_INTEGRATION_NAME}"
  
  echo "END DEBUG :: EXPLICIT ENV/VAR *****************************"

  # DEBUG PRINT ALL ENV
  echo "BEGIN DEBUG :: ECHO ALL ENV/VAR *****************************"
  env
  echo "END DEBUG :: ECHO ALL ENV/VAR *****************************"
fi


# RESET HOME FOLDER
HOME=${GITHUB_WORKSPACE}

# Start off within the workspace
cd ${GITHUB_WORKSPACE}

# Create virtual environment to install requirements
virtualenv -p python .

# Create PackageAware Working directory beneath the user's checkout-root folder
mkdir -p ${GITHUB_WORKSPACE}/soos/workspace

source bin/activate

# Get Package Aware CLI
cd ${GITHUB_WORKSPACE}/soos/workspace
curl -s https://api.github.com/repos/soos-io/soos-ci-analysis-python/releases/latest | grep "tarball_url" | cut -d '"' -f 4 | xargs -n 1 curl -LO
echo | curl -s https://api.github.com/repos/soos-io/soos-ci-analysis-python/releases/latest | grep "tarball_url" | cut -d '"' -f 4 | xargs -n 1 curl -LO
sha256sum -c soos.sha256
sha256sum -c requirements.sha256

# Install Package Aware Requirements
pip install -r requirements.txt

cd ${GITHUB_WORKSPACE}

# Execute Package Aware CLI
echo "About to execute packageaware.py with commit hash ${PA_COMMIT_HASH}"

python soos/workspace/soos.py -m="${PA_MODE}" -of="${PA_ON_FAILURE}" -dte="${PA_DIRECTORIES_TO_EXCLUDE}" -fte="${PA_FILES_TO_EXCLUDE}" -wd="${PA_WORKING_DIRECTORY}" -armw="${PA_ANALYSIS_RESULT_MAX_WAIT}" -arpi="${PA_ANALYSIS_RESULT_POLLING_INTERVAL}" -buri="${PA_BASE_URI}" -scp="${PA_ROOT_CODE_PATH}" -pn="${PA_PROJECT_NAME}" -ch="${PA_COMMIT_HASH}" -bn="${PA_BRANCH_NAME}" -bruri="${PA_BRANCH_URI}" -bldver="${PA_BUILD_VERSION}" -blduri="${PA_BUILD_URI}" -oe="${PA_OPERATING_ENVIRONMENT}" -intn="${PA_INTEGRATION_NAME}"
