{ ... }:

{
  home.file.".config/opencode/opencode.jsonc".text = ''
    {
      "plugin": ["oh-my-openagent@latest"],
      "$schema": "https://opencode.ai/config.json"
    }
  '';

  home.file.".config/opencode/tui.json".text = ''
    {
      "plugin": [
        "oh-my-openagent@latest"
      ]
    }
  '';

  home.file.".omo/omo.jsonc".source = ./omo.jsonc;
}
