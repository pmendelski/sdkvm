source $(dirname "${BASH_SOURCE[0]}")/../utils/import.sh
import utils/print
import utils/tmpdir
import utils/extract
import utils/path
import utils/delimmap

exec() {
  # All stdout lines that start with "EVAL: " are evaluated in parent process
  echo "EVAL: $@"
}
