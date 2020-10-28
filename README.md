# CBC-MACconcatenationAttack_DPROT
CBC-MAC is insecure if used with variable length messages.

Recreate the attack, with the following steps:

Create a random AES-128 key (which is just a random string of 16 bytes), and choose two arbitrary messages. For instance, message1 is:

“What about joining me tomorrow for dinner?”,

and message2 is:

“Oops, Sorry, I just remember that I have a meeting very soon in the morning.“.

Probably, the two messages came from completely different contexts (perhaps with different recipients).

For simplicity, assume that the system adds a header to the messages consisting of 16 zero bytes. Then, create two files mess1.dat and mess2.dat with the previous text messages, and a file head.dat with 16 zero bytes.

Generate the corresponding AES-128-CBC-MACs for the two messages with headers and store them in the files tag1.dat and tag2.dat.

Investigate the padding that AES-128-CBC introduces in the last incomplete block. To do that, you can encrypt a message with AES-128-CBC, and then decrypt the result with the option -nopad . You will recover the padded version of the message (do it with the first message).

The encryption/decryption lines to investigate the padding would be something like

$ openssl enc -aes-128-cbc -K $key -iv 0 -in message.dat -out cipher.dat
$ openssl enc -d -aes-128-cbc -K $key -iv 0 -nopad -in cipher.dat -out padded.dat
$ xxd padded.dat
In the second line, the -d switch means decryption, and -nopad assumes no padding was used and does not discard any byte of the resulting plaintext.

The padding scheme used here is not the one I've explained in class. Namely, if there are n missing bytes in the block, then the padding is n bytes all with the value n. If the last block is complete, then add an entire block with all its bytes equal to the block length in bytes (16 or 0x10 in the case of AES-128).

Create the forgery by appending the files head.dat, mess1.dat, the necessary padding for the first message, the tag tag1.dat and the second message mess2.dat. Store it into forgery.dat. Compute the CBC-MAC of the resulting file and check whether it is exactly the same as tag2.dat.

You have got a forged message/tag pair.

The file forgery.dat contains some non-printable characters, but if you print it, it probably gives the impression that the forged message is the concatenation of the two original messages, which substantially changes the content of the first one.

In a sort of practical attack you, as the adversary, will be given the plaintexts (including the header) and the two tags, but not the key. Then, the padding for the first message can be easily inferred from the length of the missing part in the last incomplete message block, and the first 16 bytes of the second message must be XORed with tag1. To avoid computing this XOR operation, in this recreation the all-zero header is prepended to the messages (and therefore, XORing is just replacing the header by the tag itself).