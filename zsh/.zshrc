for f in ~/.config/shell/*.sh; do
  [ -r "$f" ] && source "$f"
done

