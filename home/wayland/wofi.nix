{theme, ...}: {
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0px;
        border: 1px solid ${theme.colors.color7};
        background-color: ${theme.colors.color3};
      }

      #input {
        margin: 5px;
        border: none;
        color: ${theme.colors.color4};
        background-color: ${theme.colors.color0};
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: ${theme.colors.color1};
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: ${theme.colors.color2};
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: ${theme.colors.color6};
      }

      #entry:selected {
        color: ${theme.colors.color10};
        background-color: ${theme.colors.color9};
      }
    '';
  };
}
