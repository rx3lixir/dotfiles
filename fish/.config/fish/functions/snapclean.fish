# Cleans up snapshots timeline
function snapclean
  sudo snapper -c root cleanup timeline
  and sudo snapper -c root cleanup number
end
