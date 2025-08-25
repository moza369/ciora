#!/bin/bash

mkdir -p ~/tools

echo "Installing latest Go"

go_last_version=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

wget https://go.dev/dl/${go_last_version}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf ${go_last_version}.linux-amd64.tar.gz
rm ${go_last_version}.linux-amd64.tar.gz

# Add Go to PATH permanently if not already
if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  export PATH=$PATH:/usr/local/go/bin
fi

echo "Go ${go_last_version} installed successfully!"

echo "Installing tools..."

export CGO_ENABLED=0
# Amass
go install -v github.com/owasp-amass/amass/v5/cmd/amass@main

# Sublist3r
if [ ! -d ~/tools/Sublist3r ]; then
  git clone https://github.com/aboul3la/Sublist3r.git ~/tools/Sublist3r
  pip3 install -r ~/tools/Sublist3r/requirements.txt --break-system-packages
fi

# Assetfinder
go install github.com/tomnomnom/assetfinder@latest

# Subfinder
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Gau
go install github.com/lc/gau/v2/cmd/gau@latest

# Shuffledns
go install github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest

# Shortscan
go install github.com/bitquark/shortscan/cmd/shortscan@latest

# GoLinkFinder
go install github.com/0xsha/GoLinkFinder@latest

#Nulcei
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

#Http probe
go install github.com/tomnomnom/httprobe@latest



#Add GO to the path
if ! grep -q 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' ~/.bashrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.bashrc
fi

if ! grep -q 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' ~/.zshrc; then
    echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> ~/.zshrc

fi

# Reload shell configs
if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
else
    source ~/.bashrc
fi

echo "✅ All tools installed in ~/go/bin (make sure it's in your PATH)"
