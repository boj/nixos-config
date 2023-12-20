{ pkgs, config, ... }:

{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        margin: 0px;
        border: 1px solid #000000;
        background-color: #FFFFFF;
      }
      
      #input {
        margin: 5px;
        border: none;
        color: #C8C093;
        background-color: #FFFFFF;
      }
      
      #inner-box {
        margin: 5px;
        border: none;
        background-color: #FFFFFF;
      }
      
      #outer-box {
        margin: 5px;
        border: none;
        background-color: #EEEEEE;
      }
      
      #scroll {
        margin: 0px;
        border: none;
      }
      
      #text {
        margin: 5px;
        border: none;
        color: #000000;
      } 
      
      #entry:selected {
        color: #000000;
        background-color: #DDDDDD;
      }
    '';
  };
}
