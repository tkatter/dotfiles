import QtQuick
import qs.Commons

Item {
  id: root

  // Required properties
  property var pluginApi: null
  property var launcher: null
  property string name: "Repos"

  // Check if this provider handles the command
  function handleCommand(searchText) {
    return searchText.startsWith(">repo")
  }

  // Return available commands when user types ">"
  function commands() {
    return [{
      "name": ">repo",
      "description": "Search for repos",
      "icon": "search",
      "isTablerIcon": true,
      "onActivate": function() {
        launcher.setSearchText(">repo ")
      }
    }]
  }

  // Get search results
  function getResults(searchText) {
    if (!searchText.startsWith(">repo")) {
      return []
    }

    var query = searchText.slice(6).trim() // Remove ">repo "
    // Return results based on query
    return [{
      "name": "Result 1",
      "description": "A sample result",
      "icon": "star",
      "isTablerIcon": true,
      "onActivate": function() {
        // Do something when activated
        launcher.close()
      }
    }]
  }
}
