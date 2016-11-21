#!/usr/bin/expect
# Hacked together by Urban Reininger for removing multiple firmware passwords 2015-11-23
# @UrbanAtWork

spawn firmwarepasswd -check
expect {
"Password Enabled: No" {
puts "No Firmware Password Set!!!"
exp_continue
}
"Password Enabled: Yes" {
spawn firmwarepasswd -delete
expect "Enter password:"
send "$4\r"
expect {
"Password removed" {
puts "Firmware pw1 removed. Restart!!!"
exp_continue
}
"Password incorrect" {
spawn firmwarepasswd -delete
expect "Enter password:"
send "4$\r"
expect {
"Password removed"
puts "Firmware pw2 removed. Restart!!!" 
exp_continue
}
}
}      
}   
}
exit 0
