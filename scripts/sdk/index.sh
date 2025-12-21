source "$(dirname "${BASH_SOURCE[0]}")/../utils/import.sh"

# Utils scripts
import utils/print
import utils/spinner
import utils/error
import utils/delimmap

# SDK scripts
import ./paths
import ./execute
import ./enable
import ./install
import ./list
import ./version

sdk_eval() {
  "$@"
  # All stdout lines that start with "EVAL: " are evaluated in parent process
  echo "$@" >>"$_SDKVM_EVAL_FILE"
}
