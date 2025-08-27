#!/bin/bash

# =============================
# HackerOne Scope Downloader + Subdomain Enumeration
# =============================

# Dependency check



banner(){
cat << "EOF"
  _|_|_|  _|_|_|    _|_|    _|_|_|      _|_|    
_|          _|    _|    _|  _|    _|  _|    _|  
_|          _|    _|    _|  _|_|_|    _|_|_|_|  
_|          _|    _|    _|  _|    _|  _|    _|  
  _|_|_|  _|_|_|    _|_|    _|    _|  _|    _|

EOF
}

banner

for tool in curl amass python3 assetfinder subfinder gau shuffledns; do
    if ! command -v "$tool" &>/dev/null; then
        echo "❌ Missing: $tool"
        exit 1
    fi
done

while true; do
    echo "====== Enter the HackerOne program name: ======"
    read scope

    echo ""
    echo "====== Enter __Host-session cookie (leave blank for public programs): ======"
    read -s COOKIE

    echo ""
    echo "==== GETTING THE SCOPE FILE ===="

    url="https://hackerone.com/teams/$scope/assets/download_csv.csv"

    if [[ -z "$COOKIE" ]]; then
        # No cookie = public program
        http_status=$(curl -s -k -w "%{http_code}" -o temp.csv "$url")
    else
        # Cookie provided = private program
        http_status=$(curl -s -k -w "%{http_code}" \
            -H "User-Agent: Mozilla/5.0" \
            -b "__Host-session=$COOKIE" \
            -o temp.csv "$url")
    fi

    if [[ "$http_status" == "200" ]]; then
        mv temp.csv "$scope.csv"
        echo "✅ File downloaded successfully."
        break
    else
        rm -f temp.csv
        echo "❌ Program '$scope' not found or unauthorized. Try again or check your cookie."
    fi
done

input_file="$scope.csv"
output_file="$scope-webscope.txt"
wildcard_file="$scope-wildcards.txt"
wildscope_file="$scope-wildscope.txt"

> "$output_file"
> "$wildcard_file"
> "$wildscope_file"

# Extract eligible assets
tail -n +2 "$input_file" | while IFS=',' read -r identifier asset_type _ _ eligible_for_submission _; do
    identifier=$(echo "$identifier" | tr -d '"')
    asset_type=$(echo "$asset_type" | tr -d '"')
    eligible_for_submission=$(echo "$eligible_for_submission" | tr -d '"')

    if [[ "$eligible_for_submission" == "true" ]]; then
        if [[ "$asset_type" == "WILDCARD" || "$identifier" == *"*"* ]]; then
            echo "$identifier" >> "$wildcard_file"
        elif [[ "$asset_type" == "URL" ]]; then
            echo "$identifier" >> "$output_file"
        fi
    fi
done

# Clean wildcard domains
while IFS= read -r line; do
    domain=$(echo "$line" | sed -E 's#^\*\.*##; s#/$##' | cut -d/ -f1)
    echo "$domain" >> "$wildscope_file"
done < "$wildcard_file"

echo "✅ Extracted:"
echo "  - Regular web assets → $output_file"
echo "  - Wildcard assets    → $wildcard_file"
echo "  - Wildcard domains   → $wildscope_file (Only wildcards domains without *)"

echo ""
echo "Do you want to get subdomains of the wildcards? (Y/N)"
read choose

if [[ "$choose" == "Y" || "$choose" == "y" ]]; then
    mkdir -p subdomains trash

    echo "==== GETTING THE Subdomains ===="

    # 1. Amass
    echo "Running Amass..."
    amass enum -active -alts -brute -nocolor -min-for-recursive 2 -timeout 60 \
        -df "$wildscope_file" \
        -r 8.8.8.8 -r 1.1.1.1 -r 9.9.9.9 -r 64.6.64.6 -r 208.67.222.222 \
        -r 208.67.220.220 -r 8.26.56.26 -r 8.20.247.20 -r 185.228.168.9 \
        -r 185.228.169.9 -r 76.76.19.19 -r 76.223.122.150 -r 198.101.242.72 \
        -r 176.103.130.130 -r 176.103.130.131 -r 94.140.14.14 -r 94.140.15.15 \
        -r 1.0.0.1 -r 77.88.8.8 -r 77.88.8.1 \
        -rqps 10 \
        -o subdomains/amassresult.txt

    # 2. Sublist3r
    echo "Running Sublist3r..."
    while IFS= read -r domain; do
        python3 ~/tools/Sublist3r/sublist3r.py -d "$domain" -v -t 50 -o subdomains/${domain}-sublister.txt
    done < "$wildscope_file"

    # 3. Assetfinder
    echo "Running Assetfinder..."
    while IFS= read -r domain; do
        assetfinder --subs-only "$domain" | tee subdomains/${domain}-assetfinder.txt
    done < "$wildscope_file"

    # 4. Subfinder
    echo "Running Subfinder..."
    subfinder -dL "$wildscope_file" -silent -o subdomains/subfinderresult.txt

    # 5. ShuffleDNS
    echo "Running ShuffleDNS..."
    while IFS= read -r domain; do
	shuffledns -d "$domain" -r ~/tools/resolvers.txt  -t 10000 -mode bruteforce  -w ~/wordlists/SecLists/Discovery/DNS/bitquark-subdomains-top100000.txt -silent -o subdomains/${domain}-shufflednsresult.txt
    done < "$wildscope_file"

    # Merge all results
    echo "Merging all subdomains..."
    cat subdomains/*.txt | sort -u > all_subdomains.txt
    echo "✅ All subdomains saved to all_subdomains.txt"
fi
