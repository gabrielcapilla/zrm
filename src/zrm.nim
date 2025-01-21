import std/[os, osproc, strutils, strformat]

proc fzfSelection(currentDir: string): seq[string] =
  ## Selects items in the current directory using fzf.
  const FuzzyFinderCmd: string =
    "fzf --multi --layout=reverse --header='Use <TAB> to select more than one item'"

  # Traverse the directory and add items to the list.
  var items: seq[string] = @[]
  for _, path in walkDir(currentDir):
    items.add(path)

  # Run fzf with the list of items.
  let (output, exitCode) = execCmdEx(FuzzyFinderCmd, input = items.join("\n"))

  # Return the selected items if fzf was successful.
  if exitCode == 0:
    result = output.strip().splitLines()
  else:
    result = @[]

proc deleteItems(items: seq[string]): (uint8, uint8) =
  ## Deletes the selected items and returns the number of successes and failures.
  var successCount, failureCount: uint8 = 0

  for item in items:
    try:
      if dirExists(item):
        removeDir(item)
        stdout.writeLine "Directory deleted: ", item
      else:
        removeFile(item)
        stdout.writeLine "File deleted: ", item
      successCount += 1
    except OSError:
      stderr.writeLine "Error deleting item: ", item
      failureCount += 1

  result = (successCount, failureCount)

proc main() =
  ## Main function of the zrm program.
  let
    currentDir: string = getCurrentDir()
    selectedItems: seq[string] = fzfSelection(currentDir)

  if selectedItems.len > 0:
    stdout.writeLine "Selected items:"
    for item in selectedItems:
      stdout.writeLine "→ ", item

    stdout.write "\nDo you want to delete these items? (y/n) "
    let response: string = readLine(stdin)

    if response.toLowerAscii() == "y":
      let (successCount, failureCount) = deleteItems(selectedItems)
      stdout.writeLine fmt"Deletion completed: {successCount} successful, {failureCount} failed."
    else:
      stdout.writeLine "Items not deleted."
  else:
    stdout.writeLine "No items selected."

when isMainModule:
  main()
