{
  laptop-work = {
    name = "Laptop";
    config = ''
      monitor=eDP-1,3072x1920@60.0,0x0,1.5
    '';
    workspaces = ''
      workspace=1,monitor:eDP-1,default:true
      workspace=2,monitor:eDP-1
      workspace=3,monitor:eDP-1
      workspace=4,monitor:eDP-1
      workspace=5,monitor:eDP-1
      workspace=6,monitor:eDP-1
      workspace=7,monitor:eDP-1
      workspace=8,monitor:eDP-1
      workspace=9,monitor:eDP-1
      workspace=10,monitor:eDP-1
    '';
  };

  laptop-home = {
    name = "Laptop";
    config = ''
      monitor=eDP-1,2880x1800@90.0,0x0,1.8
    '';
    workspaces = ''
      workspace=1,monitor:eDP-1,default:true
      workspace=2,monitor:eDP-1
      workspace=3,monitor:eDP-1
      workspace=4,monitor:eDP-1
      workspace=5,monitor:eDP-1
      workspace=6,monitor:eDP-1
      workspace=7,monitor:eDP-1
      workspace=8,monitor:eDP-1
      workspace=9,monitor:eDP-1
      workspace=10,monitor:eDP-1
    '';
  };

  office = {
    name = "Office";
    config = ''
      monitor=eDP-1,1920x1200@120.0,2132x1440,1.6
      monitor=eDP-1,disable
      monitor=HDMI-A-1,3440x1440@59.97,1365x0,1.0
    '';
    workspaces = ''
      workspace=1,monitor:DP-1,default:true
      workspace=2,monitor:DP-1
      workspace=3,monitor:DP-1
      workspace=4,monitor:DP-1
      workspace=5,monitor:DP-1
      workspace=6,monitor:DP-1
      workspace=7,monitor:DP-1
      workspace=8,monitor:DP-1
      workspace=9,monitor:DP-1
      workspace=10,monitor:DP-1
    '';
  };

  shed = {
    name = "Shed";
    config = ''
      monitor=eDP-1,3072x1920@120.0,0x1440,1.0
      monitor=eDP-1,disable
      monitor=DP-1,5120x1440@120.0,0x0,1.0
    '';
    workspaces = ''
      workspace=1,monitor:DP-1,default:true
      workspace=2,monitor:DP-1
      workspace=3,monitor:DP-1
      workspace=4,monitor:DP-1
      workspace=5,monitor:DP-1
      workspace=6,monitor:DP-1
      workspace=7,monitor:DP-1
      workspace=8,monitor:DP-1
      workspace=9,monitor:DP-1
      workspace=10,monitor:DP-1

    '';
  };
}
