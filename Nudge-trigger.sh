#!/bin/zsh

# URL to raw file on GitHub
baseURL="https://raw.githubusercontent.com/mrbernardmah/macOS/main/LaunchAgents/Nudge/"
# Name of plist in the repository
fileName="Default.plist"
# If you change your agent file name, update the following line
launch_agent_plist_name='com.github.macadmins.Nudge.plist'
# Base paths
launch_agent_base_path='Library/LaunchAgents/'

curl -LJ ${baseURL}/${fileName} -o "$3/${launch_agent_base_path}${launch_agent_plist_name}"

# Copyright 2021-Present Erik Gomez.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Fail the install if the admin forgets to change their paths and they don't exist.
if [ ! -e "$3/${launch_agent_base_path}${launch_agent_plist_name}" ]; then
  echo "LaunchAgent missing, exiting"
  exit 1
fi

  # Current console user information
  console_user=$(/usr/bin/stat -f "%Su" /dev/console)
  console_user_uid=$(/usr/bin/id -u "$console_user")

  # Only enable the LaunchAgent if there is a user logged in, otherwise rely on built in LaunchAgent behavior
  if [[ -z "$console_user" ]]; then
    echo "Did not detect user"
  elif [[ "$console_user" == "loginwindow" ]]; then
    echo "Detected Loginwindow Environment"
  elif [[ "$console_user" == "_mbsetupuser" ]]; then
    echo "Detect SetupAssistant Environment"
  elif [[ "$console_user" == "root" ]]; then
    echo "Detect root as currently logged-in user"
  else
    # Unload the agent so it can be triggered on re-install
    /bin/launchctl asuser "${console_user_uid}" /bin/launchctl unload -w "$3/${launch_agent_base_path}${launch_agent_plist_name}"
    # Kill Nudge just in case (say someone manually opens it and not launched via launchagent
    /usr/bin/killall Nudge
    # Load the launch agent
    /bin/launchctl asuser "${console_user_uid}" /bin/launchctl load -w "$3/${launch_agent_base_path}${launch_agent_plist_name}"
  fi
Default LaunchAgent that will be downloaded:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.macadmins.Nudge</string>
	<key>LimitLoadToSessionType</key>
	<array>
		<string>Aqua</string>
	</array>
	<key>ProgramArguments</key>
	<array>
		<string>/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge</string>
		<!-- <string>-json-url</string> -->
		<!-- <string>https://raw.githubusercontent.com/macadmins/nudge/main/Nudge/example.json</string> -->
		<!-- <string>-demo-mode</string> -->
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartCalendarInterval</key>
	<array>
		<dict>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>Minute</key>
			<integer>30</integer>
		</dict>
	</array>
</dict>
</plist>