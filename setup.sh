#!/bin/sh

# Check if ffmpeg is installed
if ! which 'ffmpeg' > /dev/null; then
  echo "ffmpeg is not installed. Installing through Homebrew. This might take a while if you've not run 'brew update' recently."
  brew install ffmpeg
else
  echo "ffmpeg is alread installed"
fi

targetLocation="/Users/$(whoami)/Library/Services"

# Clear up the workspace in case it already exists
rm -fr workspace ||  true
mkdir workspace
for action in quick-actions/* ; do
  cp -R "$action" workspace
done

# Replace all placeholders with their proper values
for action in workspace/* ; do
  fileWithPlaceholders="$action/Contents/document.wflow"
  actionName=$(basename "$action")

  # Pipe the parsed output into a temp location - document.wflow would otherwise 
  # just be an empty file - not sure why
  sed "s|@@FFMPEGLOCATION@@|$(which 'ffmpeg')|g" "$fileWithPlaceholders" > parsed.txt
  sed "s|@@VSCODELOCATION@@|$(which 'code')|g" "$fileWithPlaceholders" > parsed.txt
  rm "$fileWithPlaceholders"
  mv parsed.txt "$fileWithPlaceholders"

  # echo "Removed previous versions of actions"
  rm -fr "$targetLocation/$actionName" || true

  echo "Placing new actions in their locations"
  cp -R "$action" "$targetLocation/$actionName"
done

# Clear up the workspace
rm -fr workspace || true

echo "All done! If the actions don't appear in the Quick Actions menu, please follow the instructions in the Readme."
