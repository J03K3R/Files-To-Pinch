#!/bin/bash
echo "
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░███████╗██╗██╗░░░░░███████╗░██████╗░░████████╗░█████╗░░░██████╗░██╗███╗░░██╗░█████╗░██╗░░██╗░░
░░██╔════╝██║██║░░░░░██╔════╝██╔════╝░░╚══██╔══╝██╔══██╗░░██╔══██╗██║████╗░██║██╔══██╗██║░░██║░░
░░█████╗░░██║██║░░░░░█████╗░░╚█████╗░░░░░░██║░░░██║░░██║░░██████╔╝██║██╔██╗██║██║░░╚═╝███████║░░
░░██╔══╝░░██║██║░░░░░██╔══╝░░░╚═══██╗░░░░░██║░░░██║░░██║░░██╔═══╝░██║██║╚████║██║░░██╗██╔══██║░░
░░██║░░░░░██║███████╗███████╗██████╔╝░░░░░██║░░░╚█████╔╝░░██║░░░░░██║██║░╚███║╚█████╔╝██║░░██║░░
░░╚═╝░░░░░╚═╝╚══════╝╚══════╝╚═════╝░░░░░░╚═╝░░░░╚════╝░░░╚═╝░░░░░╚═╝╚═╝░░╚══╝░╚════╝░╚═╝░░╚═╝░░
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

DISCLAIMER: This tool was created to demonstrate the dangers of having unprotected FTP. 
It is purely for education purposes and should not be used with malicious intent. 
Using this tool against targets that you don’t have permission to test is illegal. 
"
# Define the range of IP addresses to check
start_ip="192.168.1.1"
end_ip="192.168.1.254"

# Define the FTP directory to check
ftp_dir="/"

# Define the output file
output_file="ftp_shares.txt"

# Convert start and end IP addresses to integers
start_int=$(echo $start_ip | tr '.' ' ' | awk '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')
end_int=$(echo $end_ip | tr '.' ' ' | awk '{print ($1 * 256^3) + ($2 * 256^2) + ($3 * 256) + $4}')

# Loop through the IP addresses
while [ $start_int -le $end_int ]; do
  # Convert integer IP address to dotted decimal format
  ip=$(printf "%d.%d.%d.%d\n" $(($start_int >> 24)) $(($start_int >> 16 & 255)) $(($start_int >> 8 & 255)) $(($start_int & 255)))
  
  echo "Checking $ip..."
  
  # Check if anonymous FTP is available
  if timeout 5 ftp -n $ip <<EOF | grep -q "230"
user anonymous anonymous@
ls $ftp_dir
quit
EOF
  then
    echo "$ip has anonymous FTP enabled"
    echo "Listing files in $ftp_dir:"
    timeout 5 ftp -n $ip <<EOF
user anonymous anonymous@
ls $ftp_dir
quit
EOF
    timeout 5 ftp -n $ip <<EOF | awk '{print "'"$ip"'" " " $0}' >> $output_file
user anonymous anonymous@
ls $ftp_dir
quit
EOF
  else
    echo "$ip does not have anonymous FTP enabled"
  fi
  
  # Increment the IP address
  start_int=$((start_int + 1))
done

