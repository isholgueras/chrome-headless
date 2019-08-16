# Run Chrome Headless in a container
#
# What was once a container using the experimental build of headless_shell from
# tip, this container now runs and exposes stable Chrome headless via
# google-chome --headless.
#
# What's New
#
# 1. Pulls from Chrome Stable
# 2. You can now use the ever-awesome Jessie Frazelle seccomp profile for Chrome.
#     wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json
#
#
# To run (without seccomp):
# docker run -d -p 9222:9222 --cap-add=SYS_ADMIN justinribeiro/chrome-headless
#
# To run a better way (with seccomp):
# docker run -d -p 9222:9222 --security-opt seccomp=$HOME/chrome.json justinribeiro/chrome-headless
#
# Basic use: open Chrome, navigate to http://localhost:9222/
#

# Base docker image
FROM justinribeiro/chrome-headless

ENTRYPOINT [ "google-chrome" ]
CMD [ \
# Disable various background network services, including extension updating,
#   safe browsing service, upgrade detector, translate, UMA
"--disable-background-networking", \
# Disable installation of default apps on first run
"--disable-default-apps", \
# Disable all chrome extensions entirely
"--disable-extensions", \
# Disable the GPU hardware acceleration
"--disable-gpu", \
# Disable syncing to a Google account
"--disable-sync", \
# Disable built-in Google Translate service
"--disable-translate", \
# Disable cross-origin safeguards
"--disable-web-security", \
# Run in headless mode
"--headless", \
# Hide scrollbars on generated images/PDFs
"--hide-scrollbars", \
# Disable reporting to UMA, but allows for collection
"--metrics-recording-only", \
# Mute audio
"--mute-audio", \
# Skip first run wizards
"--no-first-run", \
# Disable sandbox mode
"--no-sandbox", \
# Expose port 9222 for remote debugging
"--remote-debugging-port=9222", \
# Set remote debugging address — important, otherwise 'localhost' would be used which breaks
#   container linking and port expose.
"--remote-debugging-address=0.0.0.0", \
# Disable fetching safebrowsing lists, likely redundant due to disable-background-networking
"--safebrowsing-disable-auto-update", \
# Make use of user data directory
"--user-data-dir" \
]
