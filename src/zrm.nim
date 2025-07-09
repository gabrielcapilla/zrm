import std/[os, osproc, strutils, strformat]

const FzfCommand: string = "fzf --multi --layout=reverse --header='Use <TAB> to select more than one item'"

proc isFzfInstalled(): bool =
  ## Checks if fzf is installed.
  ## Returns:
  ##   - True if fzf is installed, false otherwise.
  return findExe("fzf") != ""

proc getFilePaths*(currentDir: string): seq[string] =
  ## Collects absolute paths of files and directories in the current directory.
  ## Parameters:
  ##   - currentDir: The directory to list items from.
  ## Returns:
  ##   - A sequence of absolute file or directory paths.
  var filePaths: seq[string] = newSeq[string]()
  for kind, path in walkDir(currentDir):
    filePaths.add(path.absolutePath)
  return filePaths

proc runFzf(filePaths: seq[string]): seq[string] =
  ## Runs fzf with the list of paths.
  ## Parameters:
  ##   - filePaths: A sequence of file or directory paths.
  ## Returns:
  ##   - A sequence of selected file or directory paths, or an empty sequence if selection fails.
  let (output, exitCode) = execCmdEx(FzfCommand, input = filePaths.join("\n"))

  if exitCode == 0:
    return output.strip().splitLines()
  else:
    return @[]

proc fzfSelection(currentDir: string): seq[string] =
  ## Selects files or directories in the current directory using fzf.
  ## Parameters:
  ##   - currentDir: The directory to list items from.
  ## Returns:
  ##   - A sequence of selected file or directory paths, or an empty sequence if selection fails.
  if not isFzfInstalled():
    stderr.writeLine("Error: fzf is not installed or not found in PATH.")
    return @[]
  let filePaths: seq[string] = getFilePaths(currentDir)
  return runFzf(filePaths)

proc isCriticalPath*(path: string): bool =
  ## Checks if the path is critical.
  ## Parameters:
  ##   - path: The path to check.
  ## Returns:
  ##   - True if the path is critical, false otherwise.
  return path == getHomeDir() or path == "/"

proc deletePath*(absPath: string): bool =
  ## Deletes the provided path.
  ## Parameters:
  ##   - absPath: The path to delete.
  ## Returns:
  ##   - True if the deletion was successful, false otherwise.
  if not fileExists(absPath) and not dirExists(absPath):
    return false
  try:
    if dirExists(absPath):
      removeDir(absPath)
    else:
      removeFile(absPath)
    return true
  except OSError:
    return false

proc deleteItems*(selectedPaths: seq[string]): (Natural, Natural) =
  ## Deletes the provided items and returns a tuple with the count of successful and failed deletions.
  ## Parameters:
  ##   - selectedPaths: A sequence of file or directory paths to delete.
  ## Returns:
  ##   - A tuple (successCount, failureCount) indicating the number of successful and failed deletions.
  var successCount: Natural = 0
  var failureCount: Natural = 0

  for path in selectedPaths:
    if isCriticalPath(path):
      stderr.writeLine(fmt"Error: Attempt to delete critical path: {path}")
      inc(failureCount)
      continue
    if deletePath(path):
      stdout.writeLine(fmt"Deleted: {path}")
      inc(successCount)
    else:
      stderr.writeLine(fmt"Error deleting item: {path}")
      inc(failureCount)

  return (successCount, failureCount)

proc confirmDeletion(): bool =
  ## Asks the user for confirmation before deletion.
  ## Returns:
  ##   - True if the user confirms, false otherwise.
  stdout.write("\nDo you want to delete these items? (y/n) ")
  let response: string = readLine(stdin).toLowerAscii()
  return response == "y"

proc displaySelectedItems(selectedPaths: seq[string]) =
  ## Displays the selected items to the user.
  ## Parameters:
  ##   - selectedPaths: A sequence of file or directory paths to display.
  stdout.writeLine("Selected items:")
  for path in selectedPaths:
    stdout.writeLine(fmt"→ {path}")

proc main() =
  ## Main function of the zrm program. Lists items in the current directory,
  ## allows selection via fzf, and deletes selected items after user confirmation.
  let currentDir: string = getCurrentDir()
  let selectedPaths: seq[string] = fzfSelection(currentDir)

  if selectedPaths.len > 0:
    displaySelectedItems(selectedPaths)
    if confirmDeletion():
      let (successCount, failureCount) = deleteItems(selectedPaths)
      stdout.writeLine(fmt"Deletion completed: {successCount} successful, {failureCount} failed.")
    else:
      stdout.writeLine("Items not deleted.")
  else:
    stdout.writeLine("No items selected.")

when isMainModule:
  main()
