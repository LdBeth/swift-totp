NB. Well Since I like array programming I would implement
NB. the Algorithm in J

DA =: '0123456789ABCDEF'
to_bytes =: 16 16#.(2,~2%~#)$ DA i. ]
upper =: 1&(3!:12)
xor =: 22 b.
and =: 17 b.

hmac_sha1 =: {{
sha1 =. _1&(128!:6)

b_size =. 512 % 8

pad_key =. b_size {.]

block_sized_key  =. pad_key a.&i. x
o_key_pad =. block_sized_key xor b_size $ 16b5c
i_key_pad =. block_sized_key xor b_size $ 16b36

hashed =. sha1 (i_key_pad { a.), y
a. i. sha1 (o_key_pad { a.), hashed }}

NB. Test
key =: 'key'
message =: 'The quick brown fox jumps over the lazy dog'

result1 =: key hmac_sha1 message
result2 =: to_bytes upper 'de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9'

result1 -: result2 NB. should give 1

secs_to_key =: (8$2^8) #: 30<.@%~]

time =: '0000000000000001'
secrete =: 'AB54A98CEB1F0AD2'

totp =: {{
h =. x hmac_sha1&:(a. {~ to_bytes&]) y
offset =. 16bf and {: h
1000000|(4$256)#. 16b7f 16bff 16bff 16bff and 4 {. offset |. h }}

time totp secrete