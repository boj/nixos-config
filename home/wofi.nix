{ pkgs, config, theme, ... }:

{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0px;
        border: 1px solid ${theme.colors.nord7};
        background-color: ${theme.colors.nord3};
      }
      
      #input {
        margin: 5px;
        border: none;
        color: ${theme.colors.nord4};
        background-color: ${theme.colors.nord0};
      }
      
      #inner-box {
        margin: 5px;
        border: none;
        background-color: ${theme.colors.nord1};
      }
      
      #outer-box {
        margin: 5px;
        border: none;
        background-color: ${theme.colors.nord2};
      }
      
      #scroll {
        margin: 0px;
        border: none;
      }
      
      #text {
        margin: 5px;
        border: none;
        color: ${theme.colors.nord6};
      } 
      
      #entry:selected {
        color: ${theme.colors.nord10};
        background-color: ${theme.colors.nord9};
      }
    '';
  };
}
