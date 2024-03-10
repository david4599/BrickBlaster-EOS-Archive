;// MXM player, (c) '95/96 Niklas Beisert / pascal
.386

GETSETINTMODE=2 ;// 1:dpmi, 2:dos, 4:eos
DPMIPSPCODE=1
DOS32CODE=1

;//this is the right place to include the effects include file!
include mxmallfx.inc

;// *************************************************************************
;// no need to touch anything beyond this point...

MXMPLAY_TEXT segment dword public use32 'CODE'
assume cs:MXMPLAY_TEXT

copyright db "cubic tiny gus xm player v1.6 (c) '95/96 Niklas Beisert / pascal"

include mxmplay.inc

USEVOLCOL=(USEVVOL or USEVVOLSLIDE or USEVFVOLSLIDE or USEVVIBRATE or USEVVIBRATO or USEVPAN or USEVPANSLIDE or USEVPORTANOTE)
USEAMIGAFREQ=((USEFREQTAB eq 1) eq 0)
USELINEARFREQ=((USEFREQTAB eq 0) eq 0)
USEBOTHFREQ=(USEAMIGAFREQ and USELINEARFREQ)
GETSETINTMODEMULTI=(GETSETINTMODE ne 1) and (GETSETINTMODE ne 2) and (GETSETINTMODE ne 4)

headersize = 750h
mxmheader struc
  hdMXMSig dd ?
  hdNOrders dd ?
  hdOrdLoopStart dd ?
  hdNChannels dd ?
  hdNPatterns dd ?
  hdNInstruments dd ?
  hdIniTempo db ?
  hdIniBPM db ?
  hdOptions dw ?
  hdSampStart dd ?
  hdSampMem8 dd ?
  hdSampMem16 dd ?
  hdPitchMin dd ?
  hdPitchMax dd ?
  hdPanPos db 32 dup (?)
  hdOrderTable db 256 dup (?)
  hdInstrTable dd 128 dup (?)
  hdPatternTable dd 256 dup (?)
mxmheader ends

instrument struc
  insNSamples dd ?
  insSamples db 96 dup (?)
  insVolFade dw ?
  insVibType db ?
  insVibSweep db ?
  insVibDepth db ?
  insVibRate db ?
  insVNum db ?
  insVSustain db ?
  insVLoopS db ?
  insVLoopE db ?
  insVEnv dw 24 dup (?)
  insPNum db ?
  insPSustain db ?
  insPLoopS db ?
  insPLoopE db ?
  insPEnv dw 24 dup (?)
  db 46 dup (?)
instrument ends

sample struc
  smpGUSStartPos db ?,?,?
  smpGUSLoopPos db ?,?,?
  smpGUSEndPos db ?,?,?
  smpGUSMode db ?
  smpDefVol db ?
  smpDefPan db ?
  smpNormNote dw ?
  db ?,?
sample ends




channelsize = 256
channel struc
  chGUSInited db ?
  chGUSStartPos dd ?
  chGUSEndPos dd ?
  chGUSLoopPos dd ?
  chGUSMode db ?
  chGUSStopIt db ?
  chGUSChangeSamp db ?
  chGUSNextPos dd ?
  chGUSFrq dw ?
  chGUSVol dw ?
  chGUSPan db ?

  chVol db ?
  chFinalVol db ?
  chPan db ?
  chFinalPan db ?
  chPitch dd ?
  chFinalPitch dd ?

  chCurIns db ?
  chEnvIns dd ?
  chCurNormNote dw ?
  chSustain db ?
  chFadeVol dw ?
  chAVibPos db ?
  chAVibSwpPos db ?
  chVolEnvPos dd ?
  chVolEnvSegPos dw ?
  chPanEnvPos dd ?
  chPanEnvSegPos dw ?

  chDefVol db ?
  chDefPan db ?
  chCommand db ?
  chVCommand db ?
  chPortaToPitch dd ?
  chPortaToVal dd ?
  chVolSlideVal db ?
  chGVolSlideVal db ?
  chVVolPanSlideVal db ?
  chPanSlideVal db ?
  chFineVolSlideUVal db ?
  chFineVolSlideDVal db ?
  chPortaUVal dd ?
  chPortaDVal dd ?
  chFinePortaUVal db ?
  chFinePortaDVal db ?
  chXFinePortaUVal db ?
  chXFinePortaDVal db ?
  chVibRate db ?
  chVibPos db ?
  chVibType db ?
  chVibDep db ?
  chTremRate db ?
  chTremPos db ?
  chTremType db ?
  chTremDep db ?
  chPatLoopCount db ?
  chPatLoopStart db ?
  chArpPos db ?
  chArpNotes db ?,?,?
  chActionTick db ?
  chMRetrigPos db ?
  chMRetrigLen db ?
  chMRetrigAct db ?
  chDelayNote db ?
  chOffset db ?
  chGlissando db ?
  chTremorPos db ?
  chTremorLen db ?
  chTremorOff db ?
channel ends

globaldatastruct struc
  globalvol db ?
  uservol db ?
  syncval db ?

  curtick db ?
  curtempo db ?
  tick0 db ?

  currow dd ?
  patptr dd ?
  patlen dd ?

  curord dd ?

  jumptoord dd ?
  jumptorow dd ?
  patdelay db ?

  procnot db ?
  procins db ?
  procvol db ?
  proccmd db ?
  procdat db ?
  notedelayed db ?

  tmGetSetIntMode db ?
  tmOldTimer df ?
  tmOldSSESP df ?
  tmIntCount dd ?
  tmTimerRate dd ?
  tmTicker dd ?
  tmInRoutine dd ?
  stimerlen dd ?
  stimerpos dd ?
  datasegsel dw ?
  maxtimerrate dd ?

  gusport dd ?
  guschannels dd ?

  portatmp db ?
  keyofftmp db ?

  head db headersize dup (?)

  guslinvol dw 257 dup (?)

  chandata db (channelsize*32) dup (?)

  tmStack db 1024 dup (?)

  vibtabs db 1024 dup (?)
globaldatastruct ends

globdatptr dd 0

;//*************************************************************************
;// XM player

loadebp proc
  call @@loadebp_getadr
@@loadebp_getadr:
  pop ebp
  mov ebp,cs:[ebp+(globdatptr-@@loadebp_getadr)]
  ret
loadebp endp

inittables proc
if USEVIBRATO or USEVVIBRATO or USEAUTOVIBRATO
  call @@inittables_getadr
@@inittables_getadr:
  pop esi
  add esi,sintab-@@inittables_getadr
  lea edi,[ebp].vibtabs
  mov ecx,16
  rep movsd
  mov al,64
  stosb
  mov cl,63
@@inittables_sintabloop1:
    dec esi
    mov al,[esi]
    stosb
  dec cl
  jnz @@inittables_sintabloop1
  lea esi,[ebp].vibtabs
  mov cl,128
@@inittables_sintabloop2:
    lodsb
    neg al
    stosb
  dec cl
  jnz @@inittables_sintabloop2

if USEVIBTYPE or USETREMTYPE or USEAUTOVIBRATOTYPE
@@inittables_dwntabloop:
    mov al,cl
    sar al,1
    neg al
    stosb
  dec cl
  jnz @@inittables_dwntabloop

@@inittables_rectabloop:
    mov al,cl
    and al,80h
    sub al,40h
    stosb
  dec cl
  jnz @@inittables_rectabloop

@@inittables_uptabloop:
    mov al,cl
    sar al,1
    stosb
  dec cl
  jnz @@inittables_uptabloop
endif
endif

  mov [ebp].guslinvol[0],0
  mov [ebp].guslinvol[512],0EFFFh

  mov edi,1
@@inittables_lintabloop:
    mov ebx,edi
    mov edx,7
  @@inittables_logloop:
    cmp ebx,0
    je @@inittables_logfound
      shr ebx,1
      inc edx
    jmp @@inittables_logloop
  @@inittables_logfound:
    mov eax,edi
    mov cl,20
    sub cl,dl
    shl eax,cl
    and eax,0fffh
    shl edx,12
    or eax,edx
    sub eax,1000h
    mov [ebp].guslinvol[2*edi],ax
  inc edi
  cmp edi,256
  jne @@inittables_lintabloop

  ret
inittables endp


public xmpInit_
xmpInit_ proc ;// esi:mxmdata, ecx:maxtimerrate, eax:gusport, ebx:globdat, edx:getsetintmode
  push ebp

  call @@xmpInit_getadr
@@xmpInit_getadr:
  pop ebp
  mov [ebp+(globdatptr-@@xmpInit_getadr)],ebx
  mov ebp,ebx
  mov ebx,4000h
@@xmpInit_inilp:
    dec ebx
    mov byte ptr [ebp+ebx],0
  jnz @@xmpInit_inilp

if GETSETINTMODEMULTI
  mov [ebp].tmGetSetIntMode,dl
endif
  mov [ebp].maxtimerrate,ecx
  mov [ebp].uservol,40h

  mov [ebp].gusport,eax

  cmp [esi].hdMXMSig,004D584Dh
  jne @@xmpInit_fail

  lea edi,[ebp].head.hdMXMSig
  mov ecx,headersize/4
  rep movsd

  sub esi,headersize
  sub edi,600h
  mov ecx,600h/4
@@xmpInit_relloop:
    add [edi],esi
    add edi,4
  dec ecx
  jnz @@xmpInit_relloop

if USEDELTASAMP
  test byte ptr [esi].hdOptions,4
  jz @@xmpInit_nodelta
    and byte ptr [esi].hdOptions,not 4

    mov ecx,[esi].hdSampMem8
    mov ebx,[esi].hdSampStart
    add ebx,esi
    xor eax,eax
    cmp ecx,0
    je @@xmpInit_8bitfini
  @@xmpInit_8bitdelta:
      add al,[ebx]
      mov [ebx],al
      inc ebx
    dec ecx
    jnz @@xmpInit_8bitdelta
  @@xmpInit_8bitfini:
if USE16BIT
    mov ecx,[esi].hdSampMem16
    xor eax,eax
    cmp ecx,0
    je @@xmpInit_16bitfini
  @@xmpInit_16bitdelta:
      add ax,[ebx]
      mov [ebx],ax
      add ebx,2
    dec ecx
    jnz @@xmpInit_16bitdelta
  @@xmpInit_16bitfini:
endif
@@xmpInit_nodelta:
endif

  mov ecx,[esi].hdSampMem16
  shl ecx,1
  add ecx,[esi].hdSampMem8
  mov eax,[esi].hdSampStart
  add esi,eax

  call gusUploadSamples
  call inittables

  mov eax,1
  jmp @@xmpInit_done

@@xmpInit_fail:
  xor eax,eax
@@xmpInit_done:

  pop ebp
  ret
xmpInit_ endp






getfreq6848 proc
  push edx
  push ebx
  push ecx
  push esi
  add eax,8000h
  mov edx,eax
  mov ebx,eax
  mov ecx,eax
  shr eax,12
  shr edx,8
  shr ebx,4
  and eax,15
  and ebx,15
  and ecx,15
  and edx,15
  call @@getfreq6848_getadr
@@getfreq6848_getadr:
  pop esi
  add esi,logfreqtab-@@getfreq6848_getadr
  mov eax,[esi+6*16+eax*4]
  movzx edx,word ptr [esi+4*16+edx*2]
  movzx ebx,word ptr [esi+2*16+ebx*2]
  movzx ecx,word ptr [esi+0*16+ecx*2]
  mul edx
  shrd eax,edx,15
  mul ebx
  shrd eax,edx,15
  mul ecx
  shrd eax,edx,15
  pop esi
  pop ecx
  pop ebx
  pop edx
  ret
getfreq6848 endp




PlayNote proc
  mov [ebp].portatmp,0
  mov [ebp].keyofftmp,0

  cmp [ebp].proccmd,3
  jne @@PlayNote_noportac
    mov [ebp].portatmp,1
@@PlayNote_noportac:
  cmp [ebp].proccmd,5
  jne @@PlayNote_noportacv
    mov [ebp].portatmp,1
@@PlayNote_noportacv:
  cmp [ebp].procvol,0f0h
  jb @@PlayNote_noportav
    mov [ebp].portatmp,1
@@PlayNote_noportav:

  cmp [ebp].proccmd,20
  jne @@PlayNote_nokeycmd
  cmp [ebp].procdat,0
  je @@PlayNote_dokeycmd
@@PlayNote_nokeycmd:

  cmp [ebp].procnot,97
  jne @@PlayNote_nokeyoff
    mov [ebp].procnot,0
  @@PlayNote_dokeycmd:
    mov [ebp].keyofftmp,1
    mov [edi].chSustain,0
    ;// if no instrument and no volenv. kill note
@@PlayNote_nokeyoff:

  movzx eax,[ebp].procins
  cmp al,0
  je @@PlayNote_noins1
  cmp eax,[ebp].head.hdNInstruments
  ja @@PlayNote_noins1
    mov [edi].chCurIns,al
@@PlayNote_noins1:
  cmp [edi].chCurIns,0
  je @@PlayNote_done

  movzx eax,[ebp].procnot
  cmp al,0
  je @@PlayNote_nonote
    cmp [ebp].procins,0
    je @@PlayNote_nohit
      mov [edi].chSustain,1
  @@PlayNote_nohit:

    mov [edi].chDelayNote,al
    cmp [ebp].proccmd,49
    jne @@PlayNote_nodelay
      cmp [ebp].procdat,0
      jne @@PlayNote_done
  @@PlayNote_nodelay:

    dec al
    cmp [ebp].portatmp,1
    je @@PlayNote_portanote
      mov [edi].chGUSStopIt,1

      movzx edx,[edi].chCurIns
      mov edx,[ebp].head.hdInstrTable[4*edx-4]
      movzx ebx,insSamples[edx][eax]
      cmp ebx,insNSamples[edx]
      jae @@PlayNote_done
      shl ebx,4
      lea ebx,[ebx+edx+256]

      mov [edi].chGUSInited,1
      mov [edi].chGUSChangeSamp,1

      push eax
      mov eax,dword ptr [ebx].smpGUSStartPos
      and eax,0ffffffh
      mov [edi].chGUSStartPos,eax
      mov eax,dword ptr [ebx].smpGUSLoopPos
      and eax,0ffffffh
      mov [edi].chGUSLoopPos,eax
      mov eax,dword ptr [ebx].smpGUSEndPos
      and eax,0ffffffh
      mov [edi].chGUSEndPos,eax
      mov al,[ebx].smpGUSMode
      mov [edi].chGUSMode,al
      pop eax

      cmp [ebp].procins,0
      je @@PlayNote_noins2
        mov [edi].chEnvIns,edx
        mov dl,[ebx].smpDefVol
        mov [edi].chDefVol,dl
        mov dl,[ebx].smpDefPan
        mov [edi].chDefPan,dl
    @@PlayNote_noins2:

      mov dx,[ebx].smpNormNote
      mov [edi].chCurNormNote,dx

;// process finetune here (proccmd==41)
;// overwrite top 4 bits of instrument finetune value
;// cannot do this correctly, since conversion reduced information... :(
;// this command sucks anyway!!!

      shl eax,8
      add ax,dx
      neg ax
      add ah,48
      movsx eax,ax
if USEBOTHFREQ
      test byte ptr [ebp].head.hdOptions,1
      jnz @@PlayNote_noamiga1
endif
if USEAMIGAFREQ
        neg eax
        call getfreq6848
    @@PlayNote_noamiga1:
endif
      mov [edi].chPitch,eax
      mov [edi].chFinalPitch,eax
      mov [edi].chPortaToPitch,eax

      xor eax,eax
if USEOFFSET
      cmp [ebp].proccmd,9
      jne @@PlayNote_nooffset
        mov al,[ebp].procdat
        cmp al,0
        je @@PlayNote_reuseoffset
          mov [edi].chOffset,al
      @@PlayNote_reuseoffset:
        movzx eax,[edi].chOffset
        shl eax,8
    @@PlayNote_nooffset:
endif

      mov [edi].chGUSNextPos,eax
      mov [edi].chVibPos,0
      mov [edi].chTremPos,0
      mov [edi].chArpPos,0
      mov [edi].chMRetrigPos,0
      mov [edi].chTremorPos,0
      jmp @@PlayNote_nonote

  @@PlayNote_portanote:
      shl eax,8
      add ax,[edi].chCurNormNote
      neg ax
      add ah,48
      movsx eax,ax
if USEBOTHFREQ
      test byte ptr [ebp].head.hdOptions,1
      jnz @@PlayNote_noamiga2
endif
if USEAMIGAFREQ
        neg eax
        call getfreq6848
    @@PlayNote_noamiga2:
endif
      mov [edi].chPortaToPitch,eax
@@PlayNote_nonote:

  cmp [edi].chSustain,0
  je @@PlayNote_killbug
  cmp [ebp].procins,0
  je @@PlayNote_killbug
    cmp [ebp].notedelayed,1
    je @@PlayNote_noinsvolpan
      mov al,[edi].chDefVol
      mov [edi].chVol,al
      mov [edi].chFinalVol,al
      test byte ptr [ebp].head.hdOptions,2
      jnz @@PlayNote_noinsvolpan
      mov al,[edi].chDefPan
      mov [edi].chPan,al
      mov [edi].chFinalPan,al
  @@PlayNote_noinsvolpan:
    xor eax,eax
    mov [edi].chFadeVol,8000h
    mov [edi].chAVibPos,al
    mov [edi].chAVibSwpPos,al
    mov [edi].chVolEnvPos,eax
    mov [edi].chVolEnvSegPos,ax
    mov [edi].chPanEnvPos,eax
    mov [edi].chPanEnvSegPos,ax

@@PlayNote_killbug:
  cmp [ebp].keyofftmp,0
  je @@PlayNote_done
  cmp [ebp].procins,0
  jne @@PlayNote_done
  mov ebx,[edi].chEnvIns
  cmp [ebx].insVNum,0
  jne @@PlayNote_done
    mov [edi].chFadeVol,0

@@PlayNote_done:
  ret
PlayNote endp

public xmpSetVolume_
xmpSetVolume_ proc
  push ebp
  call loadebp
  mov [ebp].uservol,al
  pop ebp
  ret
xmpSetVolume_ endp

public xmpGetSync_
xmpGetSync_ proc
  push ebp
  call loadebp
  mov al,[ebp].syncval
  pop ebp
  ret
xmpGetSync_ endp

public xmpGetPos_
xmpGetPos_ proc
  push ebp
  call loadebp
  mov al,byte ptr [ebp].currow
  mov ah,byte ptr [ebp].curord
  pop ebp
  ret
xmpGetPos_ endp




freqrange proc
  cmp eax,[ebp].head.hdPitchMin
  jg @@freqrange_lowlimok
    mov eax,[ebp].head.hdPitchMin
@@freqrange_lowlimok:
  cmp eax,[ebp].head.hdPitchMax
  jl @@freqrange_highlimok
    mov eax,[ebp].head.hdPitchMax
@@freqrange_highlimok:
  ret
freqrange endp


;//***************************************************************************
;//effects

procnothing proc
  ret
procnothing endp

if USEJUMP
procjump proc
  movzx eax,[ebp].procdat
  mov [ebp].jumptoord,eax
  mov [ebp].jumptorow,0
  ret
procjump endp
else
  procjump=procnothing
endif

if USEBREAK
procbreak proc
  cmp [ebp].jumptoord,-1
  jne @@procbreak_onlyrow
    mov eax,[ebp].curord
    inc eax
    mov [ebp].jumptoord,eax
@@procbreak_onlyrow:
  movzx eax,[ebp].procdat
  mov ebx,eax
  shr al,4
  imul eax,10
  and bl,0fh
  add eax,ebx
  mov [ebp].jumptorow,eax
  ret
procbreak endp
else
  procbreak=procnothing
endif

if USEPATLOOP
procpatloop proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procpatloop_set
    inc [edi].chPatLoopCount
    cmp [edi].chPatLoopCount,al
    ja @@procpatloop_nextrow
      movzx eax,[edi].chPatLoopStart
      mov [ebp].jumptorow,eax
      mov eax,[ebp].curord
      mov [ebp].jumptoord,eax
    jmp @@procpatloop_done
  @@procpatloop_nextrow:
      mov [edi].chPatLoopCount,0
      mov al,byte ptr [ebp].currow
      inc al
      mov [edi].chPatLoopStart,al
    jmp @@procpatloop_done
@@procpatloop_set:
  mov al,byte ptr [ebp].currow
  mov [edi].chPatLoopStart,al
@@procpatloop_done:
  ret
procpatloop endp
else
  procpatloop=procnothing
endif

if USEPATDELAY
procpatdelay proc
  mov al,[ebp].procdat
  mov [ebp].patdelay,al
  ret
procpatdelay endp
else
  procpatdelay=procnothing
endif

if USESPEED
proctempo proc
  movzx ebx,[ebp].procdat
  cmp bl,20h
  jb @@proctempo_speed
    mov eax,2983615
    xor edx,edx
    div ebx
    mov [ebp].stimerlen,eax
    ret
@@proctempo_speed:
    cmp bl,0
    je @@proctempo_ignore
    mov [ebp].curtempo,bl
@@proctempo_ignore:
  ret
proctempo endp
else
  proctempo=procnothing
endif

if USEVOL
procnvol proc
  mov al,[ebp].procdat
  cmp al,40h
  jbe @@procnvol_vok
    mov al,40h
@@procnvol_vok:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procnvol endp
else
  procnvol=procnothing
endif

if USEGVOL
procgvol proc
  mov al,[ebp].procdat
  cmp al,40h
  jbe @@procgvol_vok
    mov al,40h
@@procgvol_vok:
  mov [ebp].globalvol,al
  ret
procgvol endp
else
  procgvol=procnothing
endif

if USEPAN
procpan proc
  mov al,[ebp].procdat
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
procpan endp
else
  procpan=procnothing
endif

if USESPAN
procspan proc
  mov al,[ebp].procdat
  shl al,4
  or al,[ebp].procdat
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
procspan endp
else
  procspan=procnothing
endif

if USEVPAN
procvpan proc
  mov al,[ebp].procvol
  shl al,4
  or al,[ebp].procvol
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
procvpan endp
else
  procvpan=procnothing
endif

if USEARPEGGIO
procarpeggio proc
  movzx eax,[ebp].procdat
  cmp al,0
  jne @@procarpeggio_doit
    mov [edi].chCommand,0ffh
@@procarpeggio_doit:
  shl eax,4
  shr al,4
  mov [edi].chArpNotes[0],0
  mov [edi].chArpNotes[1],ah
  mov [edi].chArpNotes[2],al
  ret
procarpeggio endp

doarpeggio proc
  movzx eax,[edi].chArpPos
  mov al,[edi].chArpNotes[eax]
if USEBOTHFREQ
  test byte ptr [ebp].head.hdOptions,1
  jz @@doarpeggio_amiga
endif
if USELINEARFREQ
    shl eax,8
    neg eax
    add eax,[edi].chFinalPitch
    call freqrange
    mov [edi].chFinalPitch,eax
endif
if USEBOTHFREQ
  jmp @@doarpeggio_noamiga
endif
if USEAMIGAFREQ
@@doarpeggio_amiga:
    call @@doarpeggio_getadr
  @@doarpeggio_getadr:
    pop edx
    mov ax,[edx+eax*2+16*4+(logfreqtab-@@doarpeggio_getadr)]
    mul [edi].chFinalPitch
    shrd eax,edx,15
    call freqrange
    mov [edi].chFinalPitch,eax
endif

@@doarpeggio_noamiga:
  inc [edi].chArpPos
  cmp [edi].chArpPos,3
  jne @@doarpeggio_done
    mov [edi].chArpPos,0
@@doarpeggio_done:
  ret
doarpeggio endp
else
  procarpeggio=procnothing
  doarpeggio=procnothing
endif



if USETREMTYPE and USETREMOLO
proctremtype proc
  mov al,[ebp].procdat
  and al,3
  mov [edi].chTremType,al
  ret
proctremtype endp
else
  proctremtype=procnothing
endif

if USETREMOLO
proctremolo proc
  mov al,[ebp].procdat
  and al,0Fh
  jz @@proctremolo_reusel
    shl al,2
    mov [edi].chTremDep,al
@@proctremolo_reusel:
  mov al,[ebp].procdat
  and al,0F0h
  jz @@proctremolo_reuseh
    shr al,2
    mov [edi].chTremRate,al
@@proctremolo_reuseh:
  ret
proctremolo endp

dotremolo proc
  movzx eax,word ptr [edi].chTremPos
  movsx eax,[ebp].vibtabs[eax]
  imul [edi].chTremDep
  sar eax,6
  add al,[edi].chFinalVol
  jns @@dotremolo_lok
    mov al,0
@@dotremolo_lok:
  cmp al,40h
  jbe @@dotremolo_tok
    mov al,40h
@@dotremolo_tok:
  mov [edi].chFinalVol,al

  cmp [ebp].tick0,0
  jne @@dotremolo_done
  mov al,[edi].chTremRate
  add [edi].chTremPos,al
@@dotremolo_done:
  ret
dotremolo endp
else
  proctremolo=procnothing
  dotremolo=procnothing
endif





if USEFPORTA
procfportau proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procfportau_reuse
    mov [edi].chFinePortaUVal,al
@@procfportau_reuse:
  movzx eax,[edi].chFinePortaUVal
  shl eax,4
  neg eax
  add eax,[edi].chPitch
  call freqrange
  mov [edi].chPitch,eax
  mov [edi].chFinalPitch,eax
  ret
procfportau endp

procfportad proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procfportad_reuse
    mov [edi].chFinePortaDVal,al
@@procfportad_reuse:
  movzx eax,[edi].chFinePortaDVal
  shl eax,4
  add eax,[edi].chPitch
  call freqrange
  mov [edi].chPitch,eax
  mov [edi].chFinalPitch,eax
  ret
procfportad endp
else
  procfportau=procnothing
  procfportad=procnothing
endif


if USEXFPORTA
procxfporta proc
  movzx eax,[ebp].procdat
  shl eax,4
  shr al,4
  cmp ah,2
  je @@procxfporta_down
  cmp ah,1
  jne @@procxfporta_done

    cmp al,0
    je @@procxfporta_reuseu
      mov [edi].chXFinePortaUVal,al
  @@procxfporta_reuseu:
    movzx eax,[edi].chXFinePortaUVal
    shl eax,2
    neg eax
    add eax,[edi].chPitch
    call freqrange
    mov [edi].chPitch,eax
    mov [edi].chFinalPitch,eax
  jmp @@procxfporta_done

@@procxfporta_down:
    cmp al,0
    je @@procxfporta_reused
      mov [edi].chXFinePortaDVal,al
  @@procxfporta_reused:
    movzx eax,[edi].chXFinePortaDVal
    shl eax,2
    add eax,[edi].chPitch
    call freqrange
    mov [edi].chPitch,eax
    mov [edi].chFinalPitch,eax

@@procxfporta_done:
  ret
procxfporta endp
else
  procxfporta=procnothing
endif


if USEFVOLSLIDE
procfvolup proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procfvolup_reuse
    mov [edi].chFineVolSlideUVal,al
@@procfvolup_reuse:
  mov al,[edi].chVol
  add al,[edi].chFineVolSlideUVal
  cmp al,40h
  jbe @@procfvolup_vok
    mov al,40h
@@procfvolup_vok:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procfvolup endp

procfvoldn proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procfvoldn_reuse
    mov [edi].chFineVolSlideDVal,al
@@procfvoldn_reuse:
  mov al,[edi].chVol
  sub al,[edi].chFineVolSlideDVal
  jnc @@procfvoldn_vok
    mov al,0
@@procfvoldn_vok:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procfvoldn endp
else
  procfvolup=procnothing
  procfvoldn=procnothing
endif

if USEVVOL
procvvol proc
procvvol4:
  mov [ebp].procvol,10h
procvvol3:
  add [ebp].procvol,10h
procvvol2:
  add [ebp].procvol,10h
procvvol1:
  add [ebp].procvol,10h
procvvol0:
  mov al,[ebp].procvol
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procvvol endp
else
  procvvol0=procnothing
  procvvol1=procnothing
  procvvol2=procnothing
  procvvol3=procnothing
  procvvol4=procnothing
endif

if USEVPANSLIDE or USEVVOLSLIDE
procvvpsl proc
  mov al,[ebp].procvol
  mov [edi].chVVolPanSlideVal,al
  ret
procvvpsl endp
else
  procvvpsl=procnothing
endif

if USEVVOLSLIDE
dovvolsld proc
  mov al,[edi].chVol
  cmp [ebp].tick0,0
  jne @@dovvolsld_done
  sub al,[edi].chVVolPanSlideVal
  jnc @@dovvolsld_done
    mov al,0
@@dovvolsld_done:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
dovvolsld endp

dovvolslu proc
  mov al,[edi].chVol
  cmp [ebp].tick0,0
  jne @@dovvolslu_done
  add al,[edi].chVVolPanSlideVal
  cmp al,40h
  jbe @@dovvolslu_done
    mov al,40h
@@dovvolslu_done:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
dovvolslu endp
else
  dovvolsld=procnothing
  dovvolslu=procnothing
endif

if USEVPANSLIDE
dovpansll proc
  mov al,[edi].chPan
  cmp [ebp].tick0,0
  jne @@dovpansll_done
  sub al,[edi].chVVolPanSlideVal
  jnc @@dovpansll_done
    mov al,0
@@dovpansll_done:
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
dovpansll endp

dovpanslr proc
  mov al,[edi].chVol
  cmp [ebp].tick0,0
  jne @@dovpanslr_done
  add al,[edi].chVVolPanSlideVal
  jnc @@dovpanslr_done
    mov al,0ffh
@@dovpanslr_done:
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
dovpanslr endp
else
  dovpansll=procnothing
  dovpanslr=procnothing
endif

if USEVFVOLSLIDE
procvfvolup proc
  mov al,[edi].chVol
  add al,[ebp].procvol
  cmp al,40h
  jbe @@procvfvolup_vok
    mov al,40h
@@procvfvolup_vok:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procvfvolup endp

procvfvoldn proc
  mov al,[edi].chVol
  sub al,[ebp].procvol
  jnc @@procvfvoldn_vok
    mov al,0
@@procvfvoldn_vok:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
procvfvoldn endp
else
  procvfvolup=procnothing
  procvfvoldn=procnothing
endif

if USESYNC
procsync proc
  mov al,[ebp].procdat
  mov [ebp].syncval,al
  ret
procsync endp
else
  procsync=procnothing
endif


if USETREMOR
proctremor proc
  movzx eax,[ebp].procdat
  cmp al,0
  je @@proctremor_reuse
    shl eax,4
    shr al,4
    inc al
    inc ah
    add al,ah
    mov [edi].chTremorLen,al
    mov [edi].chTremorOff,ah
    mov [edi].chTremorPos,0
@@proctremor_reuse:
  ret
proctremor endp

dotremor proc
  mov al,[edi].chTremorPos
  cmp al,[edi].chTremorOff
  jb @@dotremor_on
    mov [edi].chFinalVol,0
@@dotremor_on:
  cmp [ebp].tick0,0
  jne @@dotremor_done
  mov al,[edi].chTremorPos
  inc al
  cmp al,[edi].chTremorLen
  jb @@dotremor_noloop
    xor al,al
@@dotremor_noloop:
  mov [edi].chTremorPos,al
@@dotremor_done:
  ret
dotremor endp
else
  proctremor=procnothing
  dotremor=procnothing
endif



if USEENVPOS
procenvpos proc
  cmp [edi].chEnvIns,0
  je @@procenvpos_noenvins
  mov ebx,[edi].chEnvIns

  xor eax,eax
  movzx edx,[ebp].procdat
  jmp @@procenvpos_venvloops
@@procenvpos_venvloop:
    sub dx,[ebx].insVEnv[4*eax]
    jb @@procenvpos_venvok
    inc eax
@@procenvpos_venvloops:
  cmp al,[ebx].insVNum
  jne @@procenvpos_venvloop
  xor edx,edx
  sub dx,[ebx].insVEnv[4*eax]
@@procenvpos_venvok:
  add dx,[ebx].insVEnv[4*eax]
  mov [edi].chVolEnvPos,eax
  mov [edi].chVolEnvSegPos,dx

  xor eax,eax
  movzx edx,[ebp].procdat
  jmp @@procenvpos_penvloops
@@procenvpos_penvloop:
    sub dx,[ebx].insPEnv[4*eax]
    jb @@procenvpos_penvok
    inc eax
@@procenvpos_penvloops:
  cmp al,[ebx].insPNum
  jne @@procenvpos_venvloop
  xor edx,edx
  sub dx,[ebx].insPEnv[4*eax]
@@procenvpos_penvok:
  add dx,[ebx].insPEnv[4*eax]
  mov [edi].chPanEnvPos,eax
  mov [edi].chPanEnvSegPos,dx

@@procenvpos_noenvins:
  ret
procenvpos endp
else
  procenvpos=procnothing
endif




if USEPORTA
procportau proc
  movzx eax,[ebp].procdat
  cmp al,0
  je @@procportau_reuse
    shl eax,4
    mov [edi].chPortaUVal,eax
@@procportau_reuse:
  ret
procportau endp

procportad proc
  movzx eax,[ebp].procdat
  cmp al,0
  je @@procportad_reuse
    shl eax,4
    mov [edi].chPortaDVal,eax
@@procportad_reuse:
  ret
procportad endp

doportau proc
  cmp [ebp].tick0,0
  jne @@doportau_done
  mov eax,[edi].chPitch
  sub eax,[edi].chPortaUVal
  call freqrange
  mov [edi].chPitch,eax
  mov [edi].chFinalPitch,eax
@@doportau_done:
  ret
doportau endp

doportad proc
  cmp [ebp].tick0,0
  jne @@doportad_done
  mov eax,[edi].chPitch
  add eax,[edi].chPortaDVal
  call freqrange
  mov [edi].chPitch,eax
  mov [edi].chFinalPitch,eax
@@doportad_done:
  ret
doportad endp
else
  procportau=procnothing
  procportad=procnothing
  doportau=procnothing
  doportad=procnothing
endif

if USEPORTANOTE
procportanote proc
  movzx eax,[ebp].procdat
  cmp al,0
  je @@procportanote_reuse
    shl eax,4
    mov [edi].chPortaToVal,eax
@@procportanote_reuse:
  ret
procportanote endp
else
  procportanote=procnothing
endif

if USEVPORTANOTE
procvportanote proc
  movzx eax,[ebp].procvol
  cmp al,0
  je @@procvportanote_reuse
    shl eax,8
    mov [edi].chPortaToVal,eax
@@procvportanote_reuse:
  ret
procvportanote endp
else
  procvportanote=procnothing
endif


if USEGLISSANDO and (USEPORTANOTE or USEVPORTANOTE)
procgliss proc
  mov al,[ebp].procdat
  mov [edi].chGlissando,al
  ret
procgliss endp
else
  procgliss=procnothing
endif

if USEPORTANOTE or USEVPORTANOTE
doportanote proc
  mov eax,[edi].chPitch
  cmp [ebp].tick0,0
  jne @@doportanote_set
  cmp eax,[edi].chPortaToPitch
  je @@doportanote_set
  jg @@doportanote_down
    add eax,[edi].chPortaToVal
    cmp eax,[edi].chPortaToPitch
    jle @@doportanote_set
    mov eax,[edi].chPortaToPitch
    jmp @@doportanote_set
@@doportanote_down:
    sub eax,[edi].chPortaToVal
    cmp eax,[edi].chPortaToPitch
    jge @@doportanote_set
    mov eax,[edi].chPortaToPitch
@@doportanote_set:
  mov [edi].chPitch,eax

if USEGLISSANDO
  cmp [edi].chGlissando,0
  je @@doportanote_setfinpitch
if USEBOTHFREQ
    test byte ptr [ebp].head.hdOptions,1
    jz @@doportanote_amiga
endif
if USELINEARFREQ
      movzx ebx,[edi].chCurNormNote
      add eax,ebx
      add eax,80h
      xor al,al
      sub eax,ebx
endif
if USEBOTHFREQ
      jmp @@doportanote_setfinpitch
endif
if USEAMIGAFREQ
  @@doportanote_amiga:
      mov edx,eax ;// search for closest note
      mov ebx,eax ;// how should i do it??
      push ecx
      mov ecx,-1
      mov eax,-48*256
    @@doportanote_aloop:
        push eax
        add ax,[edi].chCurNormNote
        movsx eax,ax
        call getfreq6848
        sub eax,edx
        jae @@doportanote_apos
          neg eax
      @@doportanote_apos:
        cmp eax,ecx
        jae @@doportanote_aold
          mov ecx,eax
          mov eax,[esp]
          add ax,[edi].chCurNormNote
          movsx eax,ax
          call getfreq6848
          mov ebx,eax
      @@doportanote_aold:
        pop eax
      inc ah
      cmp ah,48
      jne @@doportanote_aloop
      pop ecx
      mov eax,ebx
endif
endif

@@doportanote_setfinpitch:
  mov [edi].chFinalPitch,eax
@@doportanote_done:
  ret
doportanote endp
else
  doportanote=procnothing
endif


if USEVIBTYPE and (USEVIBRATO or USEVVIBRATO)
procvibtype proc
  mov al,[ebp].procdat
  and al,3
  mov [edi].chVibType,al
  ret
procvibtype endp
else
  procvibtype=procnothing
endif

if USEVIBRATO
procvibrato proc
  mov al,[ebp].procdat
  and al,0Fh
  jz @@procvibrato_reusel
    shl al,2
    mov [edi].chVibDep,al
@@procvibrato_reusel:
  mov al,[ebp].procdat
  and al,0F0h
  jz @@procvibrato_reuseh
    shr al,2
    mov [edi].chVibRate,al
@@procvibrato_reuseh:
  ret
procvibrato endp
else
  procvibrato=procnothing
endif

if USEVVIBRATE
procvvibrat proc
  mov al,[ebp].procvol
  shl al,2
  je @@procvvibrat_reuse
    mov [edi].chVibRate,al
@@procvvibrat_reuse:
  ret
procvvibrat endp
else
  procvvibrat=procnothing
endif

if USEVVIBRATO
procvvib proc
  mov al,[ebp].procvol
  shl al,2
  je @@procvvib_reuse
    mov [edi].chVibDep,al
@@procvvib_reuse:
  ret
procvvib endp
else
  procvvib=procnothing
endif

if USEVIBRATO or USEVVIBRATO
dovibrato proc
  movzx eax,word ptr [edi].chVibPos
  movsx eax,[ebp].vibtabs[eax]
  imul [edi].chVibDep
  sar eax,3
  add eax,[edi].chFinalPitch
  call freqrange
  mov [edi].chFinalPitch,eax

  cmp [ebp].tick0,0
  jne @@dovibrato_done
  mov al,[edi].chVibRate
  add [edi].chVibPos,al
@@dovibrato_done:
  ret
dovibrato endp
else
  dovibrato=procnothing
endif

if USEVOLSLIDE or USEVIBRATOVOL or USEPORTAVOL
procvolsl proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procvolsl_reuse
    mov [edi].chVolSlideVal,al
@@procvolsl_reuse:
  ret
procvolsl endp

dovolsl proc
  mov bl,[edi].chVolSlideVal
  mov al,[edi].chVol
  cmp [ebp].tick0,0
  jne @@dovolsl_done
  test bl,0f0h
  jnz @@dovolsl_up
    sub al,bl
    jnc @@dovolsl_done
      mov al,0
    jmp @@dovolsl_done
@@dovolsl_up:
    shr bl,4
    add al,bl
    cmp al,40h
    jbe @@dovolsl_done
      mov al,40h
@@dovolsl_done:
  mov [edi].chVol,al
  mov [edi].chFinalVol,al
  ret
dovolsl endp
else
  procvolsl=procnothing
  dovolsl=procnothing
endif


if USEVIBRATOVOL and USEVIBRATO
dovibvol proc
  call dovibrato
  jmp dovolsl
dovibvol endp
else
  dovibvol=procnothing
endif

if USEPORTAVOL and USEPORTANOTE
doportavol proc
  call doportanote
  jmp dovolsl
doportavol endp
else
  doportavol=procnothing
endif

if USEGVOLSLIDE
procgvolsl proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procgvolsl_reuse
    mov [edi].chGVolSlideVal,al
@@procgvolsl_reuse:
  ret
procgvolsl endp

dogvolsl proc
  mov bl,[edi].chGVolSlideVal
  mov al,[ebp].globalvol
  cmp [ebp].tick0,0
  jne @@dogvolsl_done
  test bl,0f0h
  jnz @@dogvolsl_up
    sub al,bl
    jnc @@dogvolsl_done
      mov al,0
    jmp @@dogvolsl_done
@@dogvolsl_up:
    shr bl,4
    add al,bl
    cmp al,40h
    jbe @@dogvolsl_done
      mov al,40h
@@dogvolsl_done:
  mov [ebp].globalvol,al
  ret
dogvolsl endp
else
  procgvolsl=procnothing
  dogvolsl=procnothing
endif

if USEPANSLIDE
procpansl proc
  mov al,[ebp].procdat
  cmp al,0
  je @@procpansl_reuse
    mov [edi].chPanSlideVal,al
@@procpansl_reuse:
  ret
procpansl endp

dopansl proc
  mov bl,[edi].chPanSlideVal
  mov al,[edi].chPan
  cmp [ebp].tick0,0
  jne @@dopansl_done
  test bl,0f0h
  jnz @@dopansl_left
    add al,bl
    jnc @@dopansl_done
      mov al,0ffh
    jmp @@dopansl_done
@@dopansl_left:
    shr bl,4
    sub al,bl
    jnc @@dopansl_done
      mov al,0
@@dopansl_done:
  mov [edi].chPan,al
  mov [edi].chFinalPan,al
  ret
dopansl endp
else
  procpansl=procnothing
  dopansl=procnothing
endif

if USEDELAY or USEKEYOFFCMD or USENOTECUT
proctick proc
  mov al,[ebp].procdat
  mov [edi].chActionTick,al
  ret
proctick endp
else
  proctick=procnothing
endif

if USEDELAY
dodelay proc
  cmp [ebp].tick0,0
  jne @@dodelay_done
  mov al,[ebp].curtick
  cmp al,[edi].chActionTick
  jne @@dodelay_done
    mov [ebp].notedelayed,1
    mov al,[edi].chDelayNote
    mov [ebp].procnot,al
    mov al,[edi].chCurIns
    mov [ebp].procins,al
    mov [ebp].proccmd,0ffh
    mov [ebp].procvol,0
    call PlayNote
@@dodelay_done:
  ret
dodelay endp
else
  dodelay=procnothing
endif

if USEKEYOFFCMD
dokeyoff proc
  cmp [ebp].tick0,0
  jne @@dokeyoff_done
  mov al,[ebp].curtick
  cmp al,[edi].chActionTick
  jne @@dokeyoff_done
    mov [edi].chSustain,0

    mov eax,[edi].chEnvIns
    cmp eax,0
    je @@dokeyoff_done
    cmp [eax].insVNum,0
    jne @@dokeyoff_done
      mov [edi].chFadeVol,0

@@dokeyoff_done:
  ret
dokeyoff endp
else
  dokeyoff=procnothing
endif

if USENOTECUT
donotecut proc
  cmp [ebp].tick0,0
  jne @@donotecut_done
  mov al,[ebp].curtick
  cmp al,[edi].chActionTick
  jne @@donotecut_done
    mov [edi].chVol,0
    mov [edi].chFinalVol,0
@@donotecut_done:
  ret
donotecut endp
else
  donotecut=procnothing
endif

if USERETRIG
doretrig proc
  cmp [edi].chActionTick,0
  je @@doretrig_done
    movzx eax,[ebp].curtick
    div [edi].chActionTick
    cmp ah,0
    jne @@doretrig_done
      mov [edi].chGUSNextPos,0
@@doretrig_done:
  ret
doretrig endp
else
  doretrig=procnothing
endif

if USEMRETRIG
procmretrig proc
  movzx eax,[ebp].procdat
  cmp al,0
  je @@procmretrig_reuse
    shl eax,4
    shr al,4
    mov [edi].chMRetrigLen,al
    mov [edi].chMRetrigAct,ah
    mov [edi].chMRetrigPos,0
@@procmretrig_reuse:
  ret
procmretrig endp

domretrig proc
  mov al,[edi].chMRetrigPos
  inc [edi].chMRetrigPos
  cmp al,[edi].chMRetrigLen
  jne @@domretrig_done
    mov [edi].chMRetrigPos,0
    mov [edi].chGUSNextPos,0

    mov al,[edi].chVol
    mov bl,[edi].chMRetrigAct
    mov ah,128
    xchg bl,cl
    rol ah,cl
    xchg bl,cl
    test bl,7
    jz @@domretrig_done
    test bl,8
    jnz @@domretrig_up
    cmp bl,5
    ja @@domretrig_nosub
      sub al,ah
  @@domretrig_nosub:
    cmp bl,6
    jne @@domretrig_not6
      mov ah,al
      shr al,2
      add al,ah
      shr al,1
  @@domretrig_not6:
    cmp bl,7
    jne @@domretrig_setvol
      shr al,1
    jmp @@domretrig_setvol

  @@domretrig_up:
    cmp bl,13
    ja @@domretrig_noadd
      add al,ah
  @@domretrig_noadd:
    cmp bl,14
    jne @@domretrig_not14
      mov ah,al
      shr al,1
      add al,ah
  @@domretrig_not14:
    cmp bl,15
    jne @@domretrig_setvol
      shl al,1
      jns @@domretrig_setvol
        dec al

  @@domretrig_setvol:
    cmp al,0
    jge @@domretrig_lok
      mov al,0
  @@domretrig_lok:
    cmp al,40h
    jbe @@domretrig_tok
      mov al,40h
  @@domretrig_tok:

    mov [edi].chVol,al
    mov [edi].chFinalVol,al
@@domretrig_done:
  ret
domretrig endp
else
  procmretrig=procnothing
  domretrig=procnothing
endif





;//***************************************************************************
;//effects end

callproccmdtab proc
  call @@callproccmdtab_getadr
@@callproccmdtab_getadr:
  pop ebx
  mov eax,[ebx+4*eax+(proccmdtab-@@callproccmdtab_getadr)]
  lea eax,[eax+ebx+(procnothing-@@callproccmdtab_getadr)]
  jmp eax
callproccmdtab endp



PlayTick proc
  mov [ebp].tick0,0
  lea edi,[ebp].chandata
  xor ecx,ecx
@@PlayTick_resetvalloop:
    mov al,[edi].chVol
    mov [edi].chFinalVol,al
    mov al,[edi].chPan
    mov [edi].chFinalPan,al
    mov eax,[edi].chPitch
    mov [edi].chFinalPitch,eax
  add edi,channelsize
  inc ecx
  cmp ecx,[ebp].head.hdNChannels
  jne @@PlayTick_resetvalloop

  inc [ebp].curtick
  mov al,[ebp].curtick
  cmp al,[ebp].curtempo
  jne @@PlayTick_notnextrow

    mov [ebp].curtick,0
    cmp [ebp].patdelay,0
    jz @@PlayTick_nextrow
      dec [ebp].patdelay
      jmp @@PlayTick_notnextrow
  @@PlayTick_nextrow:
    mov [ebp].tick0,1

    inc [ebp].currow
    cmp [ebp].jumptoord,-1
    jne @@PlayTick_dojump
    mov eax,[ebp].currow
    cmp eax,[ebp].patlen
    jb @@PlayTick_donotjump
      mov eax,[ebp].curord
      inc eax
      mov [ebp].jumptoord,eax
      mov [ebp].jumptorow,0
  @@PlayTick_dojump:

      mov eax,[ebp].jumptoord
      cmp [ebp].curord,eax
      je @@PlayTick_noresetploop
        lea edi,[ebp].chandata
        xor ecx,ecx
      @@PlayTick_resetplloop:
          mov [edi].chPatLoopCount,0
          mov [edi].chPatLoopStart,0
          add edi,channelsize
        inc ecx
        cmp ecx,[ebp].head.hdNChannels
        jne @@PlayTick_resetplloop
    @@PlayTick_noresetploop:

      mov eax,[ebp].jumptoord
      cmp eax,[ebp].head.hdNOrders
      jb @@PlayTick_dontloop
        mov eax,[ebp].head.hdOrdLoopStart
    @@PlayTick_dontloop:
      mov [ebp].curord,eax
      mov eax,[ebp].jumptorow
      mov [ebp].currow,eax
      mov [ebp].jumptoord,-1
      mov eax,[ebp].curord
      movzx eax,[ebp].head.hdOrderTable[eax]
      mov esi,[ebp].head.hdPatternTable[4*eax]
      lodsd
      mov [ebp].patlen,eax
      cmp [ebp].jumptorow,0
      je @@PlayTick_rowfound
    @@PlayTick_rowfind:
      @@PlayTick_chanskip:
          lodsb
          cmp al,0
          je @@PlayTick_rowend

          test al,20h
          jz @@PlayTick_not20
            add esi,2
        @@PlayTick_not20:
          test al,40h
          jz @@PlayTick_not40
            inc esi
        @@PlayTick_not40:
          test al,80h
          jz @@PlayTick_chanskip
            add esi,2
          jmp @@PlayTick_chanskip
      @@PlayTick_rowend:

      dec [ebp].jumptorow
      jnz @@PlayTick_rowfind
    @@PlayTick_rowfound:
      mov [ebp].patptr,esi
  @@PlayTick_donotjump:

    mov esi,[ebp].patptr
    lea edi,[ebp].chandata
    xor ecx,ecx
  @@PlayTick_processrow:
      mov [ebp].procnot,0
      mov dword ptr [ebp].procins,0
      mov [edi].chCommand,0ffh

      mov al,[esi]
      cmp al,0
      je @@PlayTick_procnextchan

      and al,1fh
      cmp al,cl
      jne @@PlayTick_procnextchan

      lodsb
      mov ah,al
      test ah,20h
      jz @@PlayTick_nonot
        lodsb
        mov [ebp].procnot,al
        lodsb
        mov [ebp].procins,al
    @@PlayTick_nonot:
      test ah,40h
      jz @@PlayTick_novol
        lodsb
        mov [ebp].procvol,al
    @@PlayTick_novol:
      test ah,80h
      jz @@PlayTick_nocmd
        lodsb
        mov [ebp].proccmd,al
        lodsb
        mov [ebp].procdat,al
    @@PlayTick_nocmd:
    @@PlayTick_procnote:
      mov [ebp].notedelayed,0
      call PlayNote

if USEVOLCOL
      movzx eax,[ebp].procvol
      and [ebp].procvol,0fh
      shr eax,4
      mov [edi].chVCommand,al
      add eax,(procvoltab-proccmdtab)/4
      call callproccmdtab
endif

      movzx eax,[ebp].proccmd
      cmp al,52
      jae @@PlayTick_procnextchan
        mov [edi].chCommand,al
        call callproccmdtab

    @@PlayTick_procnextchan:
      add edi,channelsize
    inc ecx
    cmp ecx,[ebp].head.hdNChannels
    jne @@PlayTick_processrow
    inc esi
    mov [ebp].patptr,esi

@@PlayTick_notnextrow:

  lea edi,[ebp].chandata
  xor ecx,ecx
@@PlayTick_dotickloop:
if USEVOLCOL
;//process volume column
    movzx eax,[edi].chVCommand
    add eax,(dovoltab-proccmdtab)/4
    call callproccmdtab
endif

;//process command
    movzx eax,[edi].chCommand
    cmp al,52
    jae @@PlayTick_donocmd
      add eax,(docmdtab-proccmdtab)/4
      call callproccmdtab
  @@PlayTick_donocmd:

    mov ebx,[edi].chEnvIns
    cmp ebx,0
    je @@PlayTick_noenvins

;//process fadeout
    movzx eax,[edi].chFinalVol
    mul [ebp].uservol
    shr eax,6
    mul [ebp].globalvol
    mul [edi].chFadeVol
    shr edx,4
    mov [edi].chFinalVol,dl

    cmp [edi].chSustain,0
    jne @@PlayTick_sustain
      mov ax,[ebx].insVolFade
      sub [edi].chFadeVol,ax
      jnb @@PlayTick_sustain
        mov [edi].chFadeVol,0
  @@PlayTick_sustain:

if USEVOLENV
;//process volume envelope
    mov eax,[edi].chVolEnvPos
    cmp [edi].chVolEnvSegPos,0
    je @@PlayTick_vnoloop
    cmp al,[ebx].insVLoopE
    jne @@PlayTick_vnoloop
      mov al,[ebx].insVLoopS
      mov [edi].chVolEnvPos,eax
  @@PlayTick_vnoloop:
    lea esi,[ebx].insVEnv[4*eax]
    cmp al,[ebx].insVNum
    je @@PlayTick_venvlast
      mov ax,[esi][4][2]
      mov dx,[esi][0][2]
      sub eax,edx
      imul [edi].chVolEnvSegPos
      idiv word ptr [esi][0][0]
      add al,byte ptr [esi][0][2]
      mul [edi].chFinalVol
      shr eax,6
      mov [edi].chFinalVol,al

      mov ax,[edi].chVolEnvSegPos
      cmp ax,0
      jne @@PlayTick_vnosustain
      cmp [edi].chSustain,0
      je @@PlayTick_vnosustain
        mov edx,[edi].chVolEnvPos
        cmp dl,[ebx].insVSustain
        je @@PlayTick_venvnostep
    @@PlayTick_vnosustain:
      inc eax
      cmp ax,[esi][0][0]
      jb @@PlayTick_venvnostep
        xor eax,eax
        inc [edi].chVolEnvPos
    @@PlayTick_venvnostep:
      mov [edi].chVolEnvSegPos,ax
      jmp @@PlayTick_venvend

  @@PlayTick_venvlast:
      mov al,byte ptr [esi][0][2]
      mul [edi].chFinalVol
      shr eax,6
      mov [edi].chFinalVol,al
  @@PlayTick_venvend:
endif

if USEPANENV
;//process panning envelope
    mov eax,[edi].chPanEnvPos
    cmp [edi].chPanEnvSegPos,0
    je @@PlayTick_pnoloop
    cmp al,[ebx].insPLoopE
    jne @@PlayTick_pnoloop
      mov al,[ebx].insPLoopS
      mov [edi].chPanEnvPos,eax
  @@PlayTick_pnoloop:
    lea esi,[ebx].insPEnv[4*eax]
    cmp al,[ebx].insPNum
    je @@PlayTick_penvlast
      mov ax,[esi][4][2]
      mov dx,[esi][0][2]
      sub eax,edx
      imul [edi].chPanEnvSegPos
      idiv byte ptr [esi][0][0]
      add al,byte ptr [esi][0][2]
      sub al,32
      movsx edx,[edi].chFinalPan
      xor dl,dh
      imul dl
      shr eax,5
      add [edi].chFinalPan,al

      mov ax,[edi].chPanEnvSegPos
      cmp ax,0
      jne @@PlayTick_pnosustain
      cmp [edi].chSustain,0
      je @@PlayTick_pnosustain
        mov edx,[edi].chPanEnvPos
        cmp dl,[ebx].insPSustain
        je @@PlayTick_penvnostep
    @@PlayTick_pnosustain:
      inc eax
      cmp ax,[esi][0][0]
      jb @@PlayTick_penvnostep
        xor eax,eax
        inc [edi].chPanEnvPos
    @@PlayTick_penvnostep:
      mov [edi].chPanEnvSegPos,ax
      jmp @@PlayTick_penvend

  @@PlayTick_penvlast:
      mov al,byte ptr [esi][0][2]
      sub al,32
      movsx edx,[edi].chFinalPan
      xor dl,dh
      imul dl
      shr eax,5
      add [edi].chFinalPan,al
  @@PlayTick_penvend:
endif

if USEAUTOVIBRATO
;//process auto vibrato
    movzx eax,[edi].chAVibPos
    mov ah,[ebx].insVibType
    mov al,[ebp].vibtabs[eax]
    imul [ebx].insVibDepth
    shr eax,4

    mov dl,[edi].chAVibSwpPos
    cmp dl,[ebx].insVibSweep
    jae @@PlayTick_nosweep
      imul dl
      idiv [ebx].insVibSweep
      inc [edi].chAVibSwpPos
  @@PlayTick_nosweep:

    neg eax
    movsx eax,al
    add eax,[edi].chFinalPitch
    call freqrange
    mov [edi].chFinalPitch,eax

    mov al,[ebx].insVibRate
    add [edi].chAVibPos,al
endif

  @@PlayTick_noenvins:

;//conv vals for gus
    movzx eax,[edi].chFinalVol
    shl eax,1
    mov ax,[ebp].guslinvol[2*eax]
    mov [edi].chGUSVol,ax

    mov al,[edi].chFinalPan
    shr al,4
    mov [edi].chGUSPan,al

    mov eax,[edi].chFinalPitch
if USEBOTHFREQ
    test byte ptr [ebp].head.hdOptions,1
    jz @@PlayTick_amiga
endif
if USELINEARFREQ
      call getfreq6848
      mul [ebp].guschannels
      mov ebx,494
      div ebx
endif
if USEBOTHFREQ
      jmp @@PlayTick_noamiga
endif
if USEAMIGAFREQ
  @@PlayTick_amiga:
      cmp eax,100
      jb @@PlayTick_noamiga
      mov ebx,eax
      mov eax,94929
      mul [ebp].guschannels
      div ebx
  @@PlayTick_noamiga:
endif

    and al,not 1
    mov [edi].chGUSFrq,ax

  add edi,channelsize
  inc ecx
  cmp ecx,[ebp].head.hdNChannels
  jne @@PlayTick_dotickloop

  ret
PlayTick endp





public xmpPlay_
xmpPlay_ proc
  push ebp
  call loadebp

  mov [ebp].jumptoord,eax
  mov [ebp].curord,eax
  xor eax,eax
  mov [ebp].currow,eax

  call gusOpen

  lea edi,[ebp].chandata
  mov ecx,channelsize*8
  xor eax,eax
  rep stosd

  lea edi,[ebp].chandata
  xor ecx,ecx
@@xmpPlay_panloop:
    mov al,[ebp].head.hdPanPos[ecx]
    mov [edi].chPan,al
    add edi,channelsize
  inc ecx
  cmp cl,32
  jne @@xmpPlay_panloop

  xor eax,eax
  mov [ebp].globalvol,40h
  mov [ebp].jumptorow,eax
  mov [ebp].syncval,al

  mov al,[ebp].head.hdIniTempo
  mov [ebp].curtempo,al
  dec al
  mov [ebp].curtick,al

  mov eax,2983615
  xor edx,edx
  movzx ebx,[ebp].head.hdIniBPM
  div ebx
  mov [ebp].stimerlen,eax
  call tmInit
  pop ebp
  ret
xmpPlay_ endp

public xmpStop_
xmpStop_ proc
  push ebp
  call loadebp
  call tmClose
  call gusClose
  pop ebp
  ret
  ja $+1Bh
  or [edi],edx
xmpStop_ endp


;//*************************************************************************
;// system timer



tmTimerHandler proc
  pushad
  push ds
  push es
  push fs
  push gs

  call loadebp
  mov esi,ebp

  cld
  mov ds,cs:[esi].datasegsel
  mov es,[esi].datasegsel

  mov eax,[esi].tmTimerRate
  add [esi].tmTicker,eax

  add [esi].tmIntCount,eax
  cmp byte ptr [esi].tmIntCount+2,0
  je @@tmTimerHandler_noorgcall
    mov byte ptr [esi].tmIntCount+2,0
    pushfd
    call [esi].tmOldTimer
@@tmTimerHandler_noorgcall:

  mov al,20h
  out 20h,al

  mov ebx,[esi].maxtimerrate
  mov ecx,[esi].stimerlen
  mov edx,[esi].stimerpos

  sub edx,ebx
  ja @@tmTimerHandler_another
    mov edx,ecx
@@tmTimerHandler_another:

  mov [esi].stimerpos,edx

  cmp edx,ebx
  jb @@tmTimerHandler_intervalok
    mov edx,ebx
@@tmTimerHandler_intervalok:
  mov [esi].tmTimerRate,edx
  mov al,34h
  out 43h,al
  mov al,dl
  out 40h,al
  mov al,dh
  out 40h,al

  cmp [esi].stimerpos,ecx
  jne @@tmTimerHandler_notick
  cmp [esi].tmInRoutine,0
  jnz @@tmTimerHandler_notick
    mov [esi].tmInRoutine,1
    mov dword ptr [esi].tmOldSSESP,esp
    mov word ptr [esi].tmOldSSESP+4,ss
    push ds
    pop ss
    lea esp,[esi].tmStack+1024
    sti
    call gusPlayTick
    call PlayTick
    cli
    lss esp,[ebp].tmOldSSESP
    mov ds:[ebp].tmInRoutine,0
@@tmTimerHandler_notick:

  pop gs
  pop fs
  pop es
  pop ds
  popad
  iretd
tmTimerHandler endp




tmInit proc
  mov [ebp].datasegsel,ds

  xor eax,eax
  mov [ebp].stimerpos,eax
  mov [ebp].tmIntCount,eax
  mov [ebp].tmInRoutine,0
  mov [ebp].tmTimerRate,65536
  mov eax,-65536
  sub eax,[ebp].stimerlen
  mov [ebp].tmTicker,eax

if GETSETINTMODEMULTI
if GETSETINTMODE and 1
  cmp [ebp].tmGetSetIntMode,MXMINTMODEDPMI
  je @@tmInit_dpmi
endif
if GETSETINTMODE and 2
  cmp [ebp].tmGetSetIntMode,MXMINTMODEDOS
  je @@tmInit_dos
endif
  jmp @@tmInit_setdone
endif

if GETSETINTMODE and 1
@@tmInit_dpmi:
    mov ax,0204h
    mov bl,8
    int 31h
    mov dword ptr [ebp].tmOldTimer+0,edx
    mov word ptr [ebp].tmOldTimer+4,cx
    mov ax,0205h
    mov bl,8
    call @@tmInit_getadrdpmi
  @@tmInit_getadrdpmi:
    pop edx
    add edx,tmTimerHandler-@@tmInit_getadrdpmi
    mov cx,cs
    int 31h
endif
if GETSETINTMODEMULTI
  jmp @@tmInit_setdone
endif

if GETSETINTMODE and 2
@@tmInit_dos:
    push es
    mov ax,3508h
    int 21h
    mov dword ptr [ebp].tmOldTimer+0,ebx
    mov word ptr [ebp].tmOldTimer+4,es
    pop es
    push ds
    mov ax,2508h
    push cs
    pop ds
    call @@tmInit_getadrdos
  @@tmInit_getadrdos:
    pop edx
    add edx,tmTimerHandler-@@tmInit_getadrdos
    int 21h
    pop ds
endif
if GETSETINTMODEMULTI
  jmp @@tmInit_setdone
endif

@@tmInit_setdone:

  mov al,34h
  out 43h,al
  mov eax,[ebp].tmTimerRate
  out 40h,al
  mov al,ah
  out 40h,al
  ret
tmInit endp


tmClose proc
if GETSETINTMODEMULTI
if GETSETINTMODE and 1
  cmp [ebp].tmGetSetIntMode,MXMINTMODEDPMI
  je @@tmClose_dpmi
endif
if GETSETINTMODE and 2
  cmp [ebp].tmGetSetIntMode,MXMINTMODEDOS
  je @@tmClose_dos
endif
  jmp @@tmClose_resetdone
endif

if GETSETINTMODE and 1
@@tmClose_dpmi:
    mov ax,0205h
    mov bl,8
    mov edx,dword ptr [ebp].tmOldTimer
    mov cx,word ptr [ebp].tmOldTimer+4
    int 31h
if GETSETINTMODEMULTI
  jmp @@tmClose_resetdone
endif
endif

if GETSETINTMODE and 2
@@tmClose_dos:
    push ds
    mov ax,2508h
    lds edx,[ebp].tmOldTimer
    int 21h
    pop ds
if GETSETINTMODEMULTI
  jmp @@tmClose_resetdone
endif
endif

@@tmClose_resetdone:

  mov al,34h
  out 43h,al
  xor al,al
  out 40h,al
  out 40h,al
  ret
tmClose endp

public xmpGetTimer_
xmpGetTimer_ proc
  pushf
  xor eax,eax
  cli
  out 43h,al
  in al,40h
  mov ah,al
  in al,40h
  popf
  xchg ah,al
  neg eax
  push ebp
  call loadebp
  add eax,[ebp].tmTimerRate
  add eax,[ebp].tmTicker
  pop ebp
  ret
xmpGetTimer_ endp





;//*************************************************************************
;// GUS

gusoutp proc
  add edx,[ebp].gusport
  out dx,al
  sub edx,[ebp].gusport
  ret
gusoutp endp

gusout proc
  push edx
  mov dx,103h
  xchg al,bl
  call gusoutp
  add dl,2
  xchg al,bl
  call gusoutp
  pop edx
  ret
gusout endp

gusoutd proc
  push edx
  mov dx,103h
  xchg al,bl
  call gusoutp
  add dl,2
  xchg al,bl
  call gusoutp
  call gusdelay
  call gusoutp
  pop edx
  ret
gusoutd endp

gusoutw proc
  push edx
  mov dx,103h
  xchg al,bl
  call gusoutp
  inc edx
  xchg al,bl
  add edx,[ebp].gusport
  out dx,ax
  pop edx
  ret
gusoutw endp

gusin proc
  push edx
  mov dx,103h
  xchg al,bl
  call gusoutp
  add dl,2
  xchg al,bl
  add edx,[ebp].gusport
  in al,dx
  pop edx
  ret
gusin endp

gusinw proc
  push edx
  mov dx,103h
  xchg al,bl
  call gusoutp
  inc edx
  xchg al,bl
  add edx,[ebp].gusport
  in ax,dx
  pop edx
  ret
gusinw endp

gusdelay proc
  push edx
  push eax
  mov dx,107h
  add edx,[ebp].gusport
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  in al,dx
  pop eax
  pop edx
  ret
gusdelay endp

gusselchn proc
  push edx
  mov dx,102h
  xchg al,cl
  call gusoutp
  xchg al,cl
  pop edx
  ret
gusselchn endp


gussetpoint proc
  push eax
  shr eax,7
  and eax,1FFFh
  call gusoutw
  mov eax,[esp]
  inc bl
  shl eax,9
  call gusoutw
  dec bl
  pop eax
  ret
gussetpoint endp

gusopenchan proc
  cmp al,14
  jae @@gusopenchan_chanok
    mov al,14
@@gusopenchan_chanok:
  mov [ebp].guschannels,eax

  mov bl,04ch
  mov al,0
  call gusout
  call gusdelay
  call gusdelay
  inc al
  call gusout
  call gusdelay
  call gusdelay

  mov bl,0eh
  mov al,byte ptr [ebp].guschannels
  dec al
  or al,0c0h
  call gusout

  xor ecx,ecx
@@gusopenchan_initloop:
    call gusselchn
    xor ax,ax
    mov bl,9
    call gusoutw
    mov al,3
    mov bl,0
    call gusoutd
    mov al,3
    mov bl,0dh
    call gusoutd
    mov al,3fh
    mov bl,6
    call gusout
    call gusdelay
  inc ecx
  cmp ecx,32
  jne @@gusopenchan_initloop

  mov bl,4ch
  mov al,7
  call gusout

  mov cl,0
  call gusselchn
  xor edx,edx
  mov al,8
  call gusoutp
  ret
gusopenchan endp






gusfadevol proc
  mov bl,89h
  call gusinw
  movzx eax,ax
  mov bl,0
  cmp eax,edx
  jbe @@gusfadevol_up
    xchg eax,edx
    mov bl,40h
@@gusfadevol_up:

  sub edx,eax
  jz @@gusfadevol_done
  cmp edx,4096
  jae @@gusfadevol_normfade
    cmp bl,40h
    je @@gusfadevol_swapped
      add eax,edx
  @@gusfadevol_swapped:
    mov bl,9
    call gusoutw
    jmp @@gusfadevol_done

@@gusfadevol_normfade:
  add edx,eax

  cmp eax,4096
  jae @@gusfadevol_stok
    mov eax,4096
@@gusfadevol_stok:
  cmp edx,64512
  jbe @@gusfadevol_eok
    mov edx,64512
@@gusfadevol_eok:

  push ebx
  mov al,ah
  mov bl,7
  call gusout
  mov al,dh
  mov bl,8
  call gusout
  pop eax
  mov bl,0dh
  call gusoutd

@@gusfadevol_done:
  ret
gusfadevol endp

gusfadevoldown proc
  push ebx
  push eax
  mov bl,07h
  mov al,04h
  call gusout
  mov bl,08h
  mov al,0fch
  call gusout
  mov bl,0dh
  mov al,40h
  call gusoutd
  pop eax
  pop ebx
  ret
gusfadevoldown endp


gusPlayTick proc
  cmp [ebp].gusport,0
  je @@gusPlayTick_nogus

  lea edi,[ebp].chandata
  xor ecx,ecx
@@gusPlayTick_clearloop:
    cmp [edi].chGUSInited,0
    je @@gusPlayTick_nostop
    cmp [edi].chGUSStopIt,0
    je @@gusPlayTick_nostop
      call gusselchn
      mov bl,0
      mov al,[edi].chGUSMode
      or al,3
      call gusoutd
      call gusfadevoldown
      mov [edi].chGUSStopIt,0
  @@gusPlayTick_nostop:
  add edi,channelsize
  inc ecx
  cmp ecx,[ebp].head.hdNChannels
  jne @@gusPlayTick_clearloop

  xor ecx,ecx
@@gusPlayTick_waitloop:
    call gusselchn
    mov bl,8dh
  @@gusPlayTick_dowait:
      call gusin
      test al,1
    jz @@gusPlayTick_dowait
  inc ecx
  cmp ecx,[ebp].head.hdNChannels
  jne @@gusPlayTick_waitloop

  lea edi,[ebp].chandata
  xor ecx,ecx
@@gusPlayTick_playloop:
    call gusselchn
    cmp [edi].chGUSInited,0
    je @@gusPlayTick_quiet
      cmp [edi].chGUSChangeSamp,0
      je @@gusPlayTick_samesample
        mov bl,2
        mov eax,[edi].chGUSLoopPos
        call gussetpoint
        mov bl,4
        mov eax,[edi].chGUSEndPos
        call gussetpoint
    @@gusPlayTick_samesample:

      cmp [edi].chGUSNextPos,-1
      je @@gusPlayTick_noposchange
        mov eax,[edi].chGUSNextPos
        add eax,[edi].chGUSStartPos

        cmp eax,[edi].chGUSEndPos
        jb @@gusPlayTick_posok
          mov eax,[edi].chGUSEndPos
          dec eax
      @@gusPlayTick_posok:
        mov bl,10
        call gussetpoint
        mov bl,80h
        call gusin
        mov bl,0
        and al,40h
        or al,[edi].chGUSMode
        call gusout

    @@gusPlayTick_noposchange:
      mov bl,80h
      call gusin
      test bl,1
      jnz @@gusPlayTick_quiet
        mov bl,0ch
        mov al,[edi].chGUSPan
        call gusout
        mov bl,1
        mov ax,[edi].chGUSFrq
        call gusoutw
        movzx edx,[edi].chGUSVol
        call gusfadevol
      jmp @@gusPlayTick_nextchan

  @@gusPlayTick_quiet:
      call gusfadevoldown

  @@gusPlayTick_nextchan:
    mov [edi].chGUSChangeSamp,0
    mov [edi].chGUSNextPos,-1
  add edi,channelsize
  inc ecx
  cmp ecx,[ebp].head.hdNChannels
  jne @@gusPlayTick_playloop

@@gusPlayTick_nogus:
  ret
gusPlayTick endp


gusOpen proc
  cmp [ebp].gusport,0
  je @@gusOpen_nogus
  mov eax,[ebp].head.hdNChannels
  call gusopenchan
  mov cl,0
  call gusselchn
  xor edx,edx
  mov al,9
  call gusoutp
@@gusOpen_nogus:
  ret
gusOpen endp

gusClose proc
  cmp [ebp].gusport,0
  je @@gusClose_nogus
  mov eax,14
  call gusopenchan
@@gusClose_nogus:
  ret
gusClose endp


gusUploadSamples proc
  cmp [ebp].gusport,0
  je @@gusUploadSamples_done
  mov edx,[ebp].gusport
  add edx,103h
  in al,dx
  cmp al,45h
  jne @@gusUploadSamples_doit
  dec edx
  in al,dx
  cmp al,30
  jne @@gusUploadSamples_doit
  add edx,5
  in al,dx
  cmp al,42
  je @@gusUploadSamples_done
@@gusUploadSamples_doit:
  shr ecx,4
  jz @@gusUploadSamples_done
  xor ebx,ebx

@@gusUploadSamples_bigloop:
    pushf
    cli
    mov edx,[ebp].gusport
    add dx,103h
    mov al,44h
    out dx,al
    add dl,2
    mov eax,ebx
    shr eax,16
    out dx,al
    sub dl,2
    mov al,43h
    out dx,al
    inc dl
  @@gusUploadSamples_loop:
      mov eax,ebx
      out dx,ax
      lodsb
      add dl,3
      out dx,al
      sub dl,3
      inc ebx
    test bl,0fh
    jnz @@gusUploadSamples_loop
    popf
  dec ecx
  jnz @@gusUploadSamples_bigloop
@@gusUploadSamples_done:
  ret
gusUploadSamples endp

public xmpGetGUSPort_
xmpGetGUSPort_ proc
  xor eax,eax
  cmp edi,0
  je @@xmpGetGUSPort_done
  xor ecx,ecx
  dec ecx
  jmp @@xmpGetGUSPort_scanentry
@@xmpGetGUSPort_envscan:
    repne scasb
  @@xmpGetGUSPort_scanentry:
    cmp byte ptr ds:[edi],0
    je @@xmpGetGUSPort_done
    cmp dword ptr ds:[edi],52544C55h
    jne @@xmpGetGUSPort_envscan
    cmp dword ptr ds:[edi+4],444E5341h
    jne @@xmpGetGUSPort_envscan
    cmp byte ptr ds:[edi+13],40h
    je @@xmpGetGUSPort_envscan
    cmp word ptr ds:[edi+8],323Dh
    jne @@xmpGetGUSPort_envscan
    cmp word ptr ds:[edi+11],2C30h
    jne @@xmpGetGUSPort_envscan
    mov al,byte ptr ds:[edi+10]
    shl al,4
    mov ah,2
@@xmpGetGUSPort_done:
  ret
xmpGetGUSPort_ endp


if DPMIPSPCODE
public xmpGetEnvPtrDPMI_
xmpGetEnvPtrDPMI_ proc
  push ds
  mov ds,ax
  mov bx,ds:[2Ch]
  pop ds
  mov ax,6
  xor edx,edx
  int 31h
  jc @@xmpGetEnvPtrDPMI_done
  shl edx,16
  shrd edx,ecx,16
@@xmpGetEnvPtrDPMI_done:
  mov edi,edx
  ret
xmpGetEnvPtrDPMI_ endp
endif

if DOS32CODE
public xmpGetEnvPtrDOS32_
xmpGetEnvPtrDOS32_ proc
  mov ax,0EE02h
  int 31h
  ret
xmpGetEnvPtrDOS32_ endp
endif


sintab db 0,2,3,5,6,8,9,11,12,14,16,17,19,20,22,23,24,26,27,29,30,32,33
       db 34,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56
       db 56,57,58,59,59,60,60,61,61,62,62,62,63,63,63,64,64,64,64,64
logfreqtab dw 32768,32761,32753,32746,32738,32731,32724,32716,32709,32702,32694,32687,32679,32672,32665,32657
           dw 32768,32650,32532,32415,32298,32182,32066,31950,31835,31720,31606,31492,31379,31266,31153,31041
           dw 32768,30929,29193,27554,26008,24548,23170,21870,20643,19484,18390,17358,16384,15464,14596,13777
           dd 11131415,4417505,1753088,695713,276094,109568,43482,17256,6848,2718,1078,428,170,67,27,11

proccmdtab label dword
  dd procarpeggio-procnothing
  dd procportau-procnothing
  dd procportad-procnothing
  dd procportanote-procnothing
  dd procvibrato-procnothing
  dd procvolsl-procnothing
  dd procvolsl-procnothing
  dd proctremolo-procnothing
  dd procpan-procnothing
  dd 0
  dd procvolsl-procnothing
  dd procjump-procnothing
  dd procnvol-procnothing
  dd procbreak-procnothing
  dd 0
  dd proctempo-procnothing
  dd procgvol-procnothing
  dd procgvolsl-procnothing
  dd 0
  dd 0
  dd proctick-procnothing
  dd procenvpos-procnothing
  dd 0
  dd 0
  dd 0
  dd procpansl-procnothing
  dd 0
  dd procmretrig-procnothing
  dd procsync-procnothing
  dd proctremor-procnothing
  dd 0
  dd 0
  dd procsync-procnothing
  dd procxfporta-procnothing
  dd 0
  dd 0

  dd 0
  dd procfportau-procnothing
  dd procfportad-procnothing
  dd procgliss-procnothing
  dd procvibtype-procnothing
  dd 0
  dd procpatloop-procnothing
  dd proctremtype-procnothing
  dd procspan-procnothing
  dd proctick-procnothing
  dd procfvolup-procnothing
  dd procfvoldn-procnothing
  dd proctick-procnothing
  dd proctick-procnothing
  dd procpatdelay-procnothing
  dd procsync-procnothing

docmdtab label dword
  dd doarpeggio-procnothing
  dd doportau-procnothing
  dd doportad-procnothing
  dd doportanote-procnothing
  dd dovibrato-procnothing
  dd doportavol-procnothing
  dd dovibvol-procnothing
  dd dotremolo-procnothing
  dd 0
  dd 0
  dd dovolsl-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd dogvolsl-procnothing
  dd 0
  dd 0
  dd dokeyoff-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd dopansl-procnothing
  dd 0
  dd domretrig-procnothing
  dd 0
  dd dotremor-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0

  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd doretrig-procnothing
  dd 0
  dd 0
  dd donotecut-procnothing
  dd dodelay-procnothing
  dd 0
  dd 0

if USEVOLCOL
procvoltab label dword
  dd 0
  dd procvvol0-procnothing
  dd procvvol1-procnothing
  dd procvvol2-procnothing
  dd procvvol3-procnothing
  dd procvvol4-procnothing
  dd procvvpsl-procnothing
  dd procvvpsl-procnothing
  dd procvfvoldn-procnothing
  dd procvfvolup-procnothing
  dd procvvibrat-procnothing
  dd procvvib-procnothing
  dd procvpan-procnothing
  dd procvvpsl-procnothing
  dd procvvpsl-procnothing
  dd procvportanote-procnothing

dovoltab label dword
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd dovvolsld-procnothing
  dd dovvolslu-procnothing
  dd 0
  dd 0
  dd 0
  dd dovibrato-procnothing
  dd 0
  dd dovpansll-procnothing
  dd dovpanslr-procnothing
  dd doportanote-procnothing
endif

MXMPLAY_TEXT ends

end