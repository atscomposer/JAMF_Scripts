#!/usr/bin/expect
# Hacked together by Urban Reininger for removing multiple firmware passwords 2015-11-23
# @UrbanAtWork; adjusted by burenik December 09 2015

set pwd1 ""
set pwd2 ""

spawn firmwarepasswd -check
expect {
"Password Enabled: Yes" { #if password is set - check whether this is a known password
spawn firmwarepasswd -verify
expect "Enter password:"
send "$pwd1\r"
expect {
"Correct" {
#puts "Correct password identified"
#######
#  use this part to change a known password
spawn firmwarepasswd -setpasswd
expect "Enter password:"
send "$pwd1\r";
expect "Enter new password:"
send "$pwd2\r";
expect "Re-enter new password:"
send "$pwd2\r";
########
expect eof
}
"Incorrect" {
# puts "Password incorrect"
exit 1
}      
}   
}
}
exit 0
