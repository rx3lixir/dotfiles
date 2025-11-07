#!/bin/bash
# Running kitty with executed weather 
kitty --class floating_term_big -e bash -c "curl wttr.in/Barnaul?2; read -p 'Press enter to close...'"
