#!/bin/bash

REPO=$1

REPO_C=0
REPO_H=0

  for IMAGE in $(aws ecr describe-images --repository-name ${REPO} --filter tagStatus=TAGGED | jq -c '.imageDetails[]' | jq -s -c 'sort_by(.imagePushedAt) | reverse | .[0]'); do

    DIGEST=`jq -r '.imageDigest' <<< ${IMAGE}`
    TAG=`jq -r '.imageTags[0]' <<< ${IMAGE}`

    SCAN_RESULTS=`aws ecr describe-image-scan-findings --repository-name ${REPO} --image-id imageDigest=${DIGEST} --max-results 100 | jq -c '.'`


    SCAN_FINDINGS=`jq -r '.imageScanFindings' <<< ${SCAN_RESULTS}`
    CRITICAL=`jq -r '.findingSeverityCounts.CRITICAL' <<< ${SCAN_FINDINGS}`
    HIGH=`jq -r '.findingSeverityCounts.HIGH' <<< ${SCAN_FINDINGS}`

    if [ "${CRITICAL}" != "null" ]; then
      REPO_C=$(( REPO_C + ${CRITICAL} ))
    fi

    if [ "${HIGH}" != "null" ]; then
      REPO_H=$(( REPO_H + ${HIGH} ))
    fi

  done

  echo "${REPO} with Image tag ${TAG} has ${REPO_C} Critical and ${REPO_H} High vulnerabilities"
