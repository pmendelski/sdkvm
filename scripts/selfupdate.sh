selfupdate() {
  echo "Updating sdkvm"
  git pull --rebase origin master
}

selfupdate
