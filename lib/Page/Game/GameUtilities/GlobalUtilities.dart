class GlobalUtilities {
  List<String> getSeekers(Map<String, bool> playerList) {
    List<String> seekersIds = [];

    playerList.forEach((player, value) {
      if (value == true) {
        seekersIds.add(player);
      }
    });

    return seekersIds;
  }
}