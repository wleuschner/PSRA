.arm
.section .text
  mov r13, #0x4000000
  mov r11, #0x6000000
  mov r14,#0x00
  orr r12, r13, #4

  add r10,r13,#0x84
  mov r1,#0x80
  strh r1,[r10]

  add r10,r13,#0x82
  mov r1,#0x0002
  strh r1,[r10]

  add r10,r13,#0x80
  mov r1,#0x2200
  orr r1,r1,#0x0077
  strh r1,[r10]

  add r10,r13,#0x68
  mov r1,#0xF700
  orr r1,r1,#0x0087
  strh r1,[r10]

  mov r1, #0x1400
  orr r1, r1, #0x44
  strh r1, [r13]

#INIT OAM VRAM
  orr r0,r11,#0x00014000
  adr r1,char_table
  mov r2,#8*10
load_ctable:
  subs r2,#1
  ldrb r3,[r1,r2]
  mov r4,#4
load_char:
  tst r3,#1
  moveq r5,#0x00
  movne r5,#0x01
  lsr r3,#1
  tst r3,#1
  orreq r5,#0x0000
  orrne r5,#0x0100
  lsr r3,#1
  
  strh r5,[r0]
  add r0,#2
  subs r4,#1
  bne load_char
  cmp r2,#0
  bne load_ctable

#CREATE PALETTE
  mov r1,#0x05000000
  mov r0,#31
pal_loop:
  rsb r2,r0,#31
  mov r6,#31
  lsl r5,r2,#1

  lsl r3,r2,#5
  orr r3,r0,lsl #11
  strh r3,[r1,r5]

  add r5,#0x40
  orr r3,r2,r0,lsl #5
  strh r3,[r1,r5]

  add r5,#0x40
  orr r3,r0,r2,lsl #11
  strh r3,[r1,r5]

  add r5,#0x40
  orr r3,r2,r2,lsl #5
  orr r3,r0,lsl #11
  strh r3,[r1,r5]

  add r5,#0x40
  orr r3,r0,r6,lsl #5
  orr r3,r2,lsl #11
  strh r3,[r1,r5]

  add r5,#0x40
  lsl r3,r0,#5
  orr r3,r6,lsl #11
  strh r3,[r1,r5]

  add r5,#0x40
  lsl r3,r0,#11
  orr r3,r2,lsl #5
  strh r3,[r1,r5]

  add r5,#0x40
  lsl r3,r0,#5
  orr r3,r2,lsl #11
  strh r3,[r1,r5]

  subs r0,r0,#1
  bge pal_loop

  add r1,#256*2
  mov r3,#0xFF
  strh r3,[r1]
  add r1,#2
  mov r3,#0x0000
  strh r3,[r1]

#CREATE SINUS LUT
  mov r2,#256
  adr r6,lut_start
  ldr r3,[r6]
  adr r6,lut_inc
  ldr r4,[r6]
  mov r10, #0x3000000
  orr r10,#0x0600000
s_lut:
  mov r0,r3
  teq r0,r0, lsl #1
  rsbmi r0,r0,#1<<31
  mov r0,r0,asr #(30-13)
  mul r1,r0,r0
  mov r1,r1,asr #11
  rsb r1,r1, #3<<15
  mul r0,r1,r0
  mov r0,r0, asr #17

  add r0,r13,asr #9
  mov r0,r0, asr #6
  strb r0,[r10,r2]
  subs r3,r4
  subs r2,#1
  bne s_lut


  mov r1, #0
  mov r6, #32
  mov r4, #64
  mov r3, #128
outerl:
  mov r2, #0x9600
  eor r11,#0xA000
  mov r8, #160
y_loop:

  add r0, r8,r1
  and r0, r0,#0xFF
  ldrb r9, [r10,r0]
  sub r0, r8,r3
  and r0, r0,#0xFF
  ldrb r0, [r10,r0]
  add r0,r0,r9


  mov r9, #240
x_loop:
  sub r2, r2, #2
  mov r7,#160
  sub r7,r14,lsl #2
  cmp r8,r7
  subgt r7,r8,r7
  bgt draw_bar
upper_bar:
  cmp r8,r14,lsl #2
  bgt plasma
  rsb r7,r8,r14,lsl #2
draw_bar:
  lsl r7,r7,#3
  orr r7,r7,lsl #8
  subs r9,#1
  b store_pixel
plasma:
  sub r5, r9,r6
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r0,r5
  add r5, r9,r4
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r13,r5
  add r5, r9,r8
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r13,r5
  lsl r7,r13,#8

  sub r9,r9,#1
  sub r5, r9,r6
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r0,r5
  add r5, r9,r4
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r13,r5
  add r5, r9,r8
  and r5, r5,#0xFF
  ldrb r5, [r10,r5]
  add r13,r13,r5
  orr r7,r7,r13

store_pixel:
  strh r7, [r11,r2]
  subs r9,#1
  bne x_loop
  subs r8,#1
  bne y_loop
  add r6,r6,#2
  add r4,r4,#3
  add r1,r1,#1
  add r3,r3,#4
  
#PLAY SOUND
  mov r0, #0x4000000

  tst r1,#0x3
  addeq r13,r0,#0x6C
  adreq r9,music
  ldreqb r8,[r9,r14]
  lsl r8,#8
  streqh r8,[r13]
  addeq r14,#1
  andeq r14,#7

v_sync:
  ldr r8,[r12]
  tst r8,#0x01
  bne v_sync
  ldrh r8, [r0]
  eor r8, r8, #0x10
  strh r8, [r0]
#Palette Rotation
  mov r8,#0x05000000
  mov r13,#508
  ldr r9,[r8,r13]
pal_rot:
  subs r13,#4
  ldr r5,[r8,r13]
  str r9,[r8,r13]
  mov r9,r5
  bne pal_rot
  mov r13,#508
  str r9,[r8,r13]
#UPDATE TEXT
  mov r9,#0x07000000
  adr r5,scrl_txt
  mov r13,#17
update_text:
  ldrsb r0,[r5,r13]
  and r8,r3,#0xFF
  ldrb r8,[r10,r8]
  add r8,#0x50
  and r8,#0xFF
  orr r8,#0x2000
  strplh r8,[r9]
  add r9,#2
  
  add r8,r1,r13,lsl #3
  and r8,#0xFF
  orr r8,#0x3000
  strplh r8,[r9]
  add r9,#2
  mov r8,#0x0200
  orr r8,r8,r0,lsl #1
  strplh r8,[r9]
  add r9,#4
  subs r13,#1
  bpl update_text
  b outerl

lut_start:
.word 0xFFFD9E4A
lut_inc: 
.word 0xFEA5D8

music:
.byte 0x81,0x83,0x82,0x84,0x86,0x82,0x85,0x80

sine: 
#.byte 32,33,34,34,35,36,37,37,38,39,40,41,41,42,43,44
#.byte 44,45,46,46,47,48,48,49,50,50,51,52,52,53,53,54
#.byte 55,55,56,56,57,57,58,58,59,59,59,60,60,61,61,61
#.byte 62,62,62,62,63,63,63,63,63,64,64,64,64,64,64,64
#.byte 64,64,64,64,64,64,64,64,63,63,63,63,63,62,62,62
#.byte 62,61,61,61,60,60,59,59,59,58,58,57,57,56,56,55
#.byte 55,54,53,53,52,52,51,50,50,49,48,48,47,46,46,45
#.byte 44,44,43,42,41,41,40,39,38,37,37,36,35,34,34,33
#.byte 32,31,30,30,29,28,27,27,26,25,24,23,23,22,21,20
#.byte 20,19,18,18,17,16,16,15,14,14,13,12,12,11,11,10
#.byte 9,9,8,8,7,7,6,6,5,5,5,4,4,3,3,3
#.byte 2,2,2,2,1,1,1,1,1,0,0,0,0,0,0,0
#.byte 0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,2
#.byte 2,3,3,3,4,4,5,5,5,6,6,7,7,8,8,9
#.byte 9,10,11,11,12,12,13,14,14,15,16,16,17,18,18,19
#.byte 20,20,21,22,23,23,24,25,26,27,27,28,29,30,30,31

char_table:
#Character A
#.byte 0b00000000
#.byte 0b00011000
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100

#Character B
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100

#Character C
.byte 0b01111100
.byte 0b01111100
.byte 0b01100000
.byte 0b01100000
.byte 0b01100000
.byte 0b01100000
.byte 0b01111100
.byte 0b01111100

#Character D
.byte 0b01111000
.byte 0b01111100
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01111100
.byte 0b01111000

#Character E
.byte 0b01111100
.byte 0b01111100
.byte 0b01100000
.byte 0b01111100
.byte 0b01111100
.byte 0b01100000
.byte 0b01111100
.byte 0b01111100

#Character F
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00111100
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000

#Character G
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00101100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100

#Character H
#.byte 0b00000000
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100

#Character I
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000
.byte 0b00110000

#Character J
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00000100
#.byte 0b00000100
#.byte 0b00000100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100

#Character K
#.byte 0b00000000
#.byte 0b00100100
#.byte 0b00101000
#.byte 0b00110000
#.byte 0b00110000
#.byte 0b00101000
#.byte 0b00100100
#.byte 0b00100100

#Character L
#.byte 0b00000000
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00111100

#Character M
#.byte 0b00000000
#.byte 0b01000100
#.byte 0b01101100
#.byte 0b01010100
#.byte 0b01000100
#.byte 0b01000100
#.byte 0b01000100
#.byte 0b01000100

#Character N
.byte 0b11000110
.byte 0b11000110
.byte 0b11100110
.byte 0b11100110
.byte 0b11010110
.byte 0b11001110
.byte 0b11001110
.byte 0b11000110

#Character O
.byte 0b01111110
.byte 0b01111110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01111110
.byte 0b01111110

#Character P
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111100
#.byte 0b00100000
#.byte 0b00100000
#.byte 0b00100000

#Character Q
#.byte 0b00000000
#.byte 0b00111100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00100100
#.byte 0b00111111

#Character R
.byte 0b01111100
.byte 0b01111110
.byte 0b01100110
.byte 0b01100110
.byte 0b01111100
.byte 0b01111000
.byte 0b01101100
.byte 0b01100110

#Character S
.byte 0b01111100
.byte 0b01111100
.byte 0b01100000
.byte 0b01111100
.byte 0b01111100
.byte 0b00001100
.byte 0b01111100
.byte 0b01111100

#Character T
.byte 0b01111110
.byte 0b01111110
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000

#Character U
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01100110
.byte 0b01111110
.byte 0b01111110

#Character V
#.byte 0b00000000
#.byte 0b01000010
#.byte 0b01000010
#.byte 0b01100110
#.byte 0b01100110
#.byte 0b00111100
#.byte 0b00011000
#.byte 0b00011000

#Character W
#.byte 0b00000000
#.byte 0b01000010
#.byte 0b01000010
#.byte 0b01000010
#.byte 0b01011010
#.byte 0b01011010
#.byte 0b01011010
#.byte 0b01111110

#Character X
#.byte 0b00000000
#.byte 0b01000010
#.byte 0b01101110
#.byte 0b00111100
#.byte 0b00011000
#.byte 0b00111100
#.byte 0b01100110
#.byte 0b01000010

#Character Y
#.byte 0b00000000
#.byte 0b01000010
#.byte 0b01000010
#.byte 0b01100110
#.byte 0b01100110
#.byte 0b00111100
#.byte 0b00011000
#.byte 0b00011000

#Character Z
#.byte 0b00000000
#.byte 0b01111110
#.byte 0b00000110
#.byte 0b00000110
#.byte 0b00001100
#.byte 0b00011000
#.byte 0b00110000
#.byte 0b01111110

scrl_txt:
.byte 0,5,8,7,3,-1,9,4,5,2,1,3,0,9,1,6,4,5
