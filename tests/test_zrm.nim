import std/[os, unittest]
import ../src/zrm

suite "zrm tests":
  # Test case for the isCriticalPath procedure
  test "isCriticalPath should correctly identify critical paths":
    check isCriticalPath(getHomeDir()) == true
    check isCriticalPath("/") == true
    check isCriticalPath("/tmp") == false
    # Use a non-critical, existing directory for a negative test
    let nonCriticalDir: string = getCurrentDir()
    if nonCriticalDir != getHomeDir() and nonCriticalDir != "/":
      check isCriticalPath(nonCriticalDir) == false

  # Test suite for file operations in a temporary directory
  suite "File operations in a controlled environment":
    let testDir: string = "/tmp" / "zrm_test_suite"

    setup:
      # Create a temporary directory with files and subdirectories for testing
      createDir(testDir)
      writeFile(testDir / "file1.txt", "content1")
      writeFile(testDir / "file2.txt", "content2")
      createDir(testDir / "subdir1")
      writeFile(testDir / "subdir1" / "file3.txt", "content3")

    teardown:
      # Clean up the temporary directory after tests are complete
      removeDir(testDir)

    # Test case for the getFilePaths procedure
    test "getFilePaths should list all items in a directory":
      # The paths are collected from the test directory
      let paths: seq[string] = getFilePaths(testDir)
      # walkDir returns the directory itself plus its immediate children.
      # So, we expect to see "file1.txt", "file2.txt", and "subdir1".
      check paths.len == 3

    # Test case for the deletePath procedure
    test "deletePath should remove a file or directory":
      # Test file deletion
      let fileToDelete: string = testDir / "file_to_delete.txt"
      writeFile(fileToDelete, "temporary content")
      check fileExists(fileToDelete)
      check deletePath(fileToDelete) == true
      check not fileExists(fileToDelete)

      # Test directory deletion
      let dirToDelete: string = testDir / "dir_to_delete"
      createDir(dirToDelete)
      check dirExists(dirToDelete)
      check deletePath(dirToDelete) == true
      check not dirExists(dirToDelete)

    # Test case for the deleteItems procedure
    test "deleteItems should handle successful, failed, and critical path deletions":
      # Prepare paths for deletion, including a critical one
      let itemToDelete1: string = testDir / "item1.txt"
      let itemToDelete2: string = testDir / "subdir_to_delete"
      let nonExistentItem: string = testDir / "non_existent_file.txt"
      let criticalPath: string = getHomeDir()

      writeFile(itemToDelete1, "content")
      createDir(itemToDelete2)

      let pathsToDelete: seq[string] = @[itemToDelete1, itemToDelete2, nonExistentItem, criticalPath]
      let (successCount, failureCount) = deleteItems(pathsToDelete)

      # Expect 2 successful deletions (item1, itemToDelete2)
      # Expect 2 failures (non-existent file, critical path)
      check successCount == 2
      check failureCount == 2

      # Verify that the correct items were deleted or preserved
      check not fileExists(itemToDelete1)
      check not dirExists(itemToDelete2)
      check dirExists(criticalPath) # Critical path should not be deleted
