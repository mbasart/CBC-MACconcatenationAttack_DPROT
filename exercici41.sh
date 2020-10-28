#!/bin/bash

#Generate random hexadecimal key of 16 bytes
openssl rand -hex 16 > key2.dat

mykey=00112233445566778899aabbccddeeff #This key is to do some comprovations

#Write the two messages in a file 
echo -n "What about joining me tomorrow for dinner?" > mess1.dat

cat mess1.dat

echo -n "Oops, Sorry, I just remember that I have a meeting very soon in the morning." > mess2.dat

cat mess2.dat

#write the head of 16 zero bytes in a file 
echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00' > head.dat

cat head.dat | xxd

#First add the head in the message files and then generate the tags
cat head.dat mess1.dat > headMess1.dat

xxd headMess1.dat

cat head.dat mess2.dat > headMess2.dat

xxd headMess2.dat

openssl enc -aes-128-cbc -K `cat key2.dat` -iv 0 -in headMess1.dat | tail -c 16 > tag1.dat
#openssl enc -aes-128-cbc -K $mykey -iv 0 -in headMess1.dat | tail -c 16 > tag1.dat

openssl enc -aes-128-cbc -K `cat key2.dat` -iv 0 -in headMess2.dat | tail -c 16 > tag2.dat

#Obtain the padded version of the message 
openssl enc -aes-128-cbc -K `cat key2.dat` -iv 0 -in mess1.dat -out cipher.dat

openssl enc -d -aes-128-cbc -K `cat key2.dat` -iv 0 -nopad -in cipher.dat -out padded.dat

xxd padded.dat

#Create the forgery
cat head.dat padded.dat tag1.dat mess2.dat > forgery.dat

openssl enc -aes-128-cbc -K `cat key2.dat` -iv 0 -in forgery.dat | tail -c 16 > tagForgery.dat

#Compare the tagForgery with the tag2
xxd tagForgery.dat

xxd tag2.dat