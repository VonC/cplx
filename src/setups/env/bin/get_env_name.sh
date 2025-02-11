#!/bin/bash

env_name() {
  local envn
  envn="${USER: -1}"

  case "${envn}" in
  '2' | 'c')
    echo "DEV"
  ;;
  '1')
    echo "QAL"
  ;;
  '6')
    echo "PPD"
  ;;
  '0')
    echo "PRD"
  ;;
  *)
    echo "UNK"
  ;;
  esac
}

export env_name