#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

# source scripts/common.lib.sh ; ATTEMPTS=2 SLEEP=2 TRIES=3 MY_PE_HOST=10.21.82.37 Check_Prism_API_Up 'PE'
@test "Is PE up?" {
  result="$(source ./scripts/common.lib.sh ; \
  ATTEMPTS=2 SLEEP=2 TRIES=3 MY_PE_HOST=10.21.82.37 MY_PE_PASSWORD='tbd' Check_Prism_API_Up 'PE' )"
  [ "$result" -ne 0 ]
}
