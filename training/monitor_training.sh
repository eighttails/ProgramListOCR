#!/bin/bash
$1 2>&1 |grep -e 'Error rate' -e 'wrote checkpoint'
