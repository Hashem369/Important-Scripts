for file in *; do
  if [ -f "$file" ]; then
    # Process the file here
    gedit $file
  fi
done
