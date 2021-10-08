# Run Chrome Headless in a container
#
# What was once a container using the experimental build of headless_shell from
# tip, this container now runs and exposes stable Chrome headless via
# google-chome --headless.
#
#
# To run (without seccomp):
# docker run -d -p 9222:9222 --cap-add=SYS_ADMIN isholgueras/chrome-headless
#
# To run a better way (with seccomp):
# docker run -d -p 9222:9222 --security-opt seccomp=$HOME/chrome.json isholgueras/chrome-headless
#
# Basic use: open Chrome, navigate to http://localhost:9222/
#

FROM debian:bullseye-slim

# Install deps + add Chrome Stable + purge all the things
RUN apt-get -qq update && apt-get -qq install -y --no-install-recommends \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	less \
    lsb-release \
    procps \
    telnet \
    vim \
    wget >/dev/null && \
	apt-get update && apt-get install -y \
	chromium \
	chromium-sandbox \
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	fonts-freefont-ttf \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/*

# Add chromium as a user
RUN groupadd -r chromium && useradd -r -g chromium -G audio,video chromium \
	&& mkdir -p /home/chromium && chown -R chromium:chromium /home/chromium

RUN chown -R chromium:chromium /usr/lib/chromium

# Run chromium non-privileged
USER chromium

# Expose port 9222
EXPOSE 9222

ENTRYPOINT [ "chromium" ]
CMD [ \
# Disable various background network services, including extension updating,
#   safe browsing service, upgrade detector, translate, UMA
"--disable-background-networking", \
# Disable installation of default apps on first run
"--disable-default-apps", \
# Disable all chrome extensions entirely
"--disable-extensions", \
# Disable the GPU hardware acceleration
"--disable-software-rasterizer", \
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
