#!/bin/sh

# Check if ffmpeg is installed
if ! which 'ffmpeg' > /dev/null; then
  echo "ffmpeg is not installed. Installing through Homebrew. This might take a while if you've not run 'brew update' recently."
  brew install ffmpeg
else
  echo "ffmpeg is alread installed"
fi

actionsLocation="~/Library/Services"

# Clear up the workspace
rm -fr workspace ||  true
mkdir workspace
for action in quick-actions/* ; do
  cp -R "$action" workspace
done

# Replace all placeholders with their proper values
for action in workspace/* ; do
  workflowFile="$action/Contents/document.wflow"
  actionName=$(basename "$action")

  # Pipe the parsed output into a temp location - document.wflow would otherwise 
  # just be an empty file - not sure why
  sed "s|@@FFMPEGLOCATION@@|$(which 'ffmpeg')|g" "$workflowFile" > parsed.txt
  sed "s|@@VSCODELOCATION@@|$(which 'code')|g" "$workflowFile" > parsed.txt
  rm "$workflowFile"
  mv parsed.txt "$workflowFile"

  echo "Removed previous versions of actions"
  rm -fr "$actionsLocation/$action" || true

  echo "Placing new actions in their locations"
  cp -r "$action" "$actionsLocation/$actionName"
done

# Clear up the workspace
rm -fr workspace || true

echo "All done! If the actions don't appear in the Quick Actions menu, please follow the instructions in the Readme."
