# Creates a manual snapshot with current timestamp
function snapnow
  if test (count $argv) -eq 0
      echo "Enter description: snapnow 'your description"
      return 1
  end
  sudo snapper -c root create --description "$argv - $(date '+%Y-%m-%d %H:%M')"
end
