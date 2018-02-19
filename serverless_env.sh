#!/bin/bash

SLS_PROJECT="<SET PROJECT NAME>"
SLS_REGION="<SET SERVERLESS REGION>"

source_vars() {
 export \
   SLS_PROJECT \
   SLS_ENV \
   SLS_REGION \
   "$@"
}

source_vars "$@"

