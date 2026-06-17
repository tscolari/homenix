{
  laptop-work = {
    name = "Laptop";
    config = ''
      hl.monitor({ output = "eDP-1", mode = "3072x1920@60.0", position = "0x0", scale = 1.5 })
      hl.config({ general = { layout = "dwindle" } })
    '';
    workspaces = ''
      hl.workspace_rule({ workspace = "1",  monitor = "eDP-1", default = true })
      hl.workspace_rule({ workspace = "2",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "3",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "4",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "5",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "6",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "7",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "8",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "9",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })
    '';
  };

  laptop-home = {
    name = "Laptop";
    config = ''
      hl.monitor({ output = "eDP-1", mode = "2880x1800@90.0", position = "0x0", scale = 1.5 })
      hl.config({ general = { layout = "dwindle" } })
    '';
    workspaces = ''
      hl.workspace_rule({ workspace = "1",  monitor = "eDP-1", default = true })
      hl.workspace_rule({ workspace = "2",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "3",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "4",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "5",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "6",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "7",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "8",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "9",  monitor = "eDP-1" })
      hl.workspace_rule({ workspace = "10", monitor = "eDP-1" })
    '';
  };

  office = {
    name = "Office";
    config = ''
      hl.monitor({ output = "desc:Samsung Electric Company LC34G55T", mode = "3440x1440@59.97", position = "1365x0", scale = 1.0 })
      hl.monitor({ output = "eDP-1", disabled = true })
    '';
    workspaces = ''
      hl.workspace_rule({ workspace = "1",  monitor = "DP-1", default = true })
      hl.workspace_rule({ workspace = "2",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "3",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "4",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "5",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "6",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "7",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "8",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "9",  monitor = "DP-1" })
      hl.workspace_rule({ workspace = "10", monitor = "DP-1" })
    '';
  };

  shed = {
    name = "Shed";
    config = ''
      hl.monitor({ output = "desc:Samsung Electric Company LC49G95T", mode = "5120x1440@120", position = "0x0", scale = 1 })
      hl.monitor({ output = "eDP-1", mode = "preferred", position = "10000x10000", scale = 1 })
    '';
    workspaces = ''
      hl.workspace_rule({ workspace = "1",    monitor = "desc:Samsung Electric Company LC49G95T", default = true })
      hl.workspace_rule({ workspace = "2",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "3",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "4",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "5",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "6",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "7",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "8",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "9",    monitor = "desc:Samsung Electric Company LC49G95T" })
      hl.workspace_rule({ workspace = "10",   monitor = "desc:Samsung Electric Company LC49G95T" })
    '';
  };
}
