// XM 2 MXM converter, (c) 95/96 Niklas Beisert / pascal

#include <conio.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>
#include <stdlib.h>

unsigned char patbuf1[0x20000];
unsigned long patofs[256];
unsigned long insofs[128];
unsigned char insreloc[256];
struct
{
  unsigned long srcofs;
  unsigned long dstofs;
  unsigned long len;
  unsigned long loopstart;
  unsigned long loopend;
  unsigned char type;
} sampinfo[2048];

void writestrbool(int f, char *s, int b)
{
  write(f, s, strlen(s));
  write(f, b?"=1\r\n":"=0\r\n", 4);
}

void main(int argc, char **argv)
{
  cputs("  XM to MXM converter v1.5     (c) '95/96 Niklas Beisert / pascal\r\n\n");

  int i,j,k;

  char spath[_MAX_PATH];
  char dpath[_MAX_PATH];
  char ipath[_MAX_PATH];
  *spath=0;
  *dpath=0;
  unsigned char pantype=0;
  int dodelta=1;
  int include=0;

  for (i=1; i<argc; i++)
  {
    if ((argv[i][0]=='/')||(argv[i][0]=='-'))
    {
      if ((argv[i][1]&~0x20)=='P')
      {
        pantype=argv[i][2]-'0';
        if (pantype>5)
        {
          cputs("invalid panning type!\r\n");
          return;
        }
      }
      else
      if ((argv[i][1]&~0x20)=='D')
        dodelta=0;
      else
      if ((argv[i][1]&~0x20)=='I')
        include=1;
      else
      {
        cputs("invalid switch!\r\n");
        return;
      }
    }
    else
    {
      if (!*spath)
        strcpy(spath, argv[i]);
      else
      if (!*dpath)
        strcpy(dpath, argv[i]);
      else
      {
        cputs("invalid parameter!\r\n");
        return;
      }
    }
  }

  if (!*spath)
  {
    cputs("xm2mxm [switches] source [dest]\r\n");
    cputs(" switches:\r\n");
    cputs("   -p0:   XM-panning (instruments) (default)\r\n");
    cputs("   -p1:  MOD-panning (LRRLLRRL)\r\n");
    cputs("   -p2:  MOD-panning (less extreme)\r\n");
    cputs("   -p3:  S3M-panning (LRLRLRLR)\r\n");
    cputs("   -p4:  S3M-panning (less extreme)\r\n");
    cputs("   -p5:    0-panning (MMMMMMMM)\r\n");
    cputs("    -d:  do not use delta value samples\r\n");
    cputs("    -i:  generate effects include file\r\n");
    return;
  }

  char name[_MAX_FNAME];
  char ext[_MAX_EXT];
  char dir[_MAX_DIR];
  char drive[_MAX_DRIVE];

  _splitpath(spath, drive, dir, name, ext);
  if (!*ext)
    strcpy(ext, ".xm");
  _makepath(spath, drive, dir, name, ext);

  char name2[_MAX_FNAME];
  _splitpath(dpath, drive, dir, name2, ext);
  if (!*name2)
    strcpy(name2, name);
  if (!*ext)
    strcpy(ext, ".mxm");
  _makepath(dpath, drive, dir, name2, ext);
  _makepath(ipath, drive, dir, name2, ".inc");

  int file=open(spath, O_RDONLY|O_BINARY);
  if (file<0)
  {
    cputs("could not open input file\r\n");
    return;
  }

  struct
  {
    char sig[17];
    char name[20];
    char whythis1a;
    char tracker[20];
    unsigned short ver;
    unsigned long hdrsize;
  } head1;

  struct
  {
    unsigned short ordnum;
    unsigned short restart;
    unsigned short channum;
    unsigned short patnum;
    unsigned short insnum;
    unsigned short freqtab;
    unsigned short tempo;
    unsigned short speed;
    unsigned char ord[256];
  } head2;

  read(file, &head1, sizeof(head1));
  if (memcmp(head1.sig, "Extended Module: ", 17))
    return;
  if (head1.whythis1a!=0x1a)
    return;
  if (head1.ver<0x104)
    return;
  read(file, &head2, sizeof(head2));
  lseek(file, sizeof(head1)+head1.hdrsize-4, SEEK_SET);

  int addcleanpat=0;
  for (i=0; i<head2.ordnum; i++)
    if (head2.ord[i]>=head2.patnum)
    {
      head2.ord[i]=head2.patnum;
      addcleanpat=1;
    }
  memset(head2.ord+head2.ordnum, 0, 256-head2.ordnum);

  int wf=open(dpath, O_WRONLY|O_BINARY|O_TRUNC|O_CREAT, S_IREAD|S_IWRITE);
  if (file<0)
  {
    cputs("could not open output file\r\n");
    return;
  }

  struct
  {
    unsigned long sig;
    unsigned long ordnum;
    unsigned long restart;
    unsigned long channum;
    unsigned long patnum;
    unsigned long insnum;
    unsigned char tempo;
    unsigned char speed;
    unsigned short opt;
    unsigned long sampstart;
    unsigned long samples8;
    unsigned long samples16;
    signed long lowpitch;
    signed long highpitch;
    unsigned char panpos[32];
  } mxmhead;

  if (!head2.channum||!head2.ordnum||!head2.patnum)
  {
    cputs("no channels/orders/patterns\r\n");
    return;
  }
  if (head2.restart>head2.ordnum)
    head2.restart=0;
  memset(&mxmhead, 0, sizeof(mxmhead));
  mxmhead.sig=*(unsigned long*)"MXM\0";
  mxmhead.ordnum=head2.ordnum;
  mxmhead.restart=head2.restart;
  mxmhead.channum=head2.channum;
  mxmhead.insnum=head2.insnum;
  mxmhead.patnum=head2.patnum+addcleanpat;
  mxmhead.tempo=head2.tempo;
  mxmhead.speed=head2.speed;
  mxmhead.opt=(head2.freqtab&1)|(pantype?2:0)|(dodelta?4:0);
  switch (pantype)
  {
  case 0: memcpy(mxmhead.panpos, "\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80", 32); break;
  case 1: memcpy(mxmhead.panpos, "\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00\x00\xFF\xFF\x00", 32); break;
  case 2: memcpy(mxmhead.panpos, "\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40\x40\xC0\xC0\x40", 32); break;
  case 3: memcpy(mxmhead.panpos, "\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF\x00\xFF", 32); break;
  case 4: memcpy(mxmhead.panpos, "\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0\x40\xC0", 32); break;
  case 5: memcpy(mxmhead.panpos, "\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80\x80", 32); break;
  }
  if (head2.freqtab&1)
  {
    mxmhead.lowpitch=-72*256;
    mxmhead.highpitch=96*256;
  }
  else
  {
    mxmhead.lowpitch=107;
    mxmhead.highpitch=438272;
  }


  write(wf, &mxmhead, sizeof(mxmhead));
  write(wf, &head2.ord, 256);
  write(wf, &insofs, 512);
  write(wf, &patofs, 1024);

  unsigned long patstartpos=tell(file);

  for (i=0; i<head2.patnum; i++)
  {
    struct
    {
      unsigned long len;
      unsigned char ptype;
      unsigned short rows;
      unsigned short patdata;
    } pathead;
    read(file, &pathead, sizeof(pathead));
    lseek(file, pathead.patdata+pathead.len-sizeof(pathead), SEEK_CUR);
  }

  memset(insreloc, 0xFF, 256);
  insreloc[0]=0;

  char useifx[5];
  memset(useifx, 0, 5);
  int sampnum=0;
  int curins=0;
  for (i=0; i<head2.insnum; i++)
  {
    struct
    {
      unsigned long size;
      char name[22];
      char type;
      unsigned short samp;
    } ins1;

    read(file, &ins1, sizeof(ins1));
    if (!ins1.samp)
    {
      lseek(file, ins1.size-sizeof(ins1), SEEK_CUR);
      continue;
    }
    struct
    {
      unsigned long shsize;
      unsigned char snum[96];
      unsigned short venv[12][2];
      unsigned short penv[12][2];
      unsigned char vnum, pnum;
      unsigned char vsustain, vloops, vloope, psustain, ploops, ploope;
      unsigned char vtype, ptype;
      unsigned char vibtype, vibsweep, vibdepth, vibrate;
      unsigned short volfade;
      unsigned short res;
    } ins2;
    read(file, &ins2, sizeof(ins2));
    lseek(file, ins1.size-sizeof(ins1)-sizeof(ins2), SEEK_CUR);

    struct
    {
      unsigned long sampnum;
      unsigned char snum[96];
      unsigned short volfade;
      unsigned char vibtype, vibsweep, vibdepth, vibrate;
      unsigned char vnum, vsustain, vloops, vloope;
      unsigned short venv[12][2];
      unsigned char pnum, psustain, ploops, ploope;
      unsigned short penv[12][2];
      unsigned char res[46];
    } mxmins;

    struct
    {
      unsigned short gusstartl;
      unsigned char gusstarth;
      unsigned short gusloopstl;
      unsigned char gusloopsth;
      unsigned short gusloopendl;
      unsigned char gusloopendh;
      unsigned char gusmode;
      unsigned char vol;
      unsigned char pan;
      unsigned short relpitch;
      unsigned char res[2];
    } mxmsamp[16];

    unsigned char sampreloc[16];
    memset(sampreloc, 0xFF, 16);

    int cursmp=0;
    for (j=0; j<ins1.samp; j++)
    {
      struct
      {
        unsigned long samplen;
        unsigned long loopstart;
        unsigned long looplen;
        unsigned char vol;
        signed char finetune;
        unsigned char type;
        unsigned char pan;
        signed char relnote;
        unsigned char res;
        unsigned char name[22];
      } samp;
      read(file, &samp, sizeof(samp));
      lseek(file, ins2.shsize-sizeof(samp), SEEK_CUR);
      if (!samp.samplen)
        continue;

      if (samp.loopstart>samp.samplen)
        samp.type&=~3;

      if ((samp.loopstart+samp.looplen)>samp.samplen)
        samp.looplen=samp.samplen-samp.loopstart;

      if (!samp.looplen)
        samp.type&=~3;

      if ((samp.samplen>262*1024)&&(samp.type&16))
      {
        cputs("16 bit sample too long\r\n");
        return;
      }

      if ((samp.type&16)&&((samp.samplen|samp.loopstart|samp.looplen)&1))
      {
        cputs("16 bit sample point odd\r\n");
        return;
      }

      if (samp.samplen>1024*1024)
      {
        cputs("sample too long\r\n");
        return;
      }

      mxmsamp[cursmp].relpitch=samp.relnote*256+samp.finetune*2;
      mxmsamp[cursmp].vol=samp.vol;
      mxmsamp[cursmp].pan=samp.pan;
      mxmsamp[cursmp].gusmode=((samp.type&16)?0x04:0x00)|((samp.type&3)?(((samp.type&3)==2)?0x18:0x08):0x00);
      mxmsamp[cursmp].gusstartl=samp.samplen;
      mxmsamp[cursmp].gusstarth=samp.samplen>>16;
      mxmsamp[cursmp].gusloopstl=samp.loopstart;
      mxmsamp[cursmp].gusloopsth=samp.loopstart>>16;
      mxmsamp[cursmp].gusloopendl=samp.loopstart+samp.looplen;
      mxmsamp[cursmp].gusloopendh=(samp.loopstart+samp.looplen)>>16;
      memset(mxmsamp[cursmp].res, 0, sizeof(mxmsamp->res));
      sampreloc[j]=cursmp++;
      if (samp.type&16)
        useifx[4]=1;
    }
    if (!cursmp)
      continue;

    insofs[curins]=tell(wf);
    insreloc[i+1]=++curins;

    memset(&mxmins, 0, sizeof(mxmins));
    mxmins.sampnum=cursmp;
    for (j=0; j<96; j++)
      mxmins.snum[j]=sampreloc[ins2.snum[j]];
    mxmins.volfade=0xFFFF;
    mxmins.vnum=0;
    mxmins.vsustain=0xFF;
    mxmins.vloops=0;
    mxmins.vloope=0xFF;
    mxmins.venv[0][0]=0;
    mxmins.venv[0][1]=64;
    mxmins.pnum=0;
    mxmins.psustain=0xFF;
    mxmins.ploops=0;
    mxmins.ploope=0xFF;
    mxmins.penv[0][0]=0;
    mxmins.penv[0][1]=32;
    mxmins.volfade=ins2.volfade; // ??????????????????????????????????????
    if (ins2.vtype&1)
    {
      useifx[0]=1;
      mxmins.vnum=ins2.vnum-1;
      for (j=0; j<mxmins.vnum; j++)
      {
        mxmins.venv[j][0]=ins2.venv[j+1][0]-ins2.venv[j][0];
        mxmins.venv[j][1]=ins2.venv[j][1];
      }
      mxmins.venv[mxmins.vnum][0]=0;
      mxmins.venv[mxmins.vnum][1]=ins2.venv[mxmins.vnum][1];
      if (ins2.vtype&2)
        mxmins.vsustain=ins2.vsustain;
      if (ins2.vtype&4)
      {
        if (ins2.vloops<=ins2.vnum)
          mxmins.vloops=ins2.vloops;
        mxmins.vloope=ins2.vloope;
      }
      mxmins.volfade=ins2.volfade;
    }
    if (ins2.ptype&1)
    {
      useifx[1]=1;
      mxmins.pnum=ins2.pnum-1;
      for (j=0; j<mxmins.pnum; j++)
      {
        mxmins.penv[j][0]=ins2.penv[j+1][0]-ins2.penv[j][0];
        mxmins.penv[j][1]=ins2.penv[j][1];
      }
      mxmins.penv[mxmins.pnum][0]=0;
      mxmins.penv[mxmins.pnum][1]=ins2.penv[mxmins.pnum][1];
      if (ins2.ptype&2)
        mxmins.psustain=ins2.psustain;
      if (ins2.ptype&4)
      {
        if (ins2.ploops<=ins2.pnum)
          mxmins.ploops=ins2.ploops;
        mxmins.ploope=ins2.ploope;
      }
    }
    if (ins2.vibdepth)
    {
      useifx[2]=1;
      if (ins2.vibtype!=0)
        useifx[3]=1;
      mxmins.vibtype=(ins2.vibtype==1)?2:(ins2.vibtype==2)?3:(ins2.vibtype==3)?1:0;
      mxmins.vibsweep=ins2.vibsweep;
      mxmins.vibdepth=ins2.vibdepth;
      mxmins.vibrate=ins2.vibrate;
    }
    write(wf, &mxmins, sizeof(mxmins));

    for (j=0; j<cursmp; j++)
    {
      sampinfo[sampnum].srcofs=tell(file);
      sampinfo[sampnum].dstofs=tell(wf);
      sampinfo[sampnum].len=mxmsamp[j].gusstartl+(mxmsamp[j].gusstarth<<16);
      sampinfo[sampnum].loopstart=mxmsamp[j].gusloopstl+(mxmsamp[j].gusloopsth<<16);
      sampinfo[sampnum].loopend=mxmsamp[j].gusloopendl+(mxmsamp[j].gusloopendh<<16);
      sampinfo[sampnum].type=mxmsamp[j].gusmode;
      write(wf, &mxmsamp[j], sizeof(*mxmsamp));
      lseek(file, sampinfo[sampnum].len, SEEK_CUR);
      sampnum++;
    }
  }

  mxmhead.insnum=curins;
  if (!curins)
  {
    cputs("no instruments\r\n");
    return;
  }

  lseek(file, patstartpos, SEEK_SET);

  char usefx[52];
  char usevfx[52];
  memset(usefx, 0, 52);
  memset(usevfx, 0, 16);
  for (i=0; i<head2.patnum; i++)
  {
    struct
    {
      unsigned long len;
      unsigned char ptype;
      unsigned short rows;
      unsigned short patdata;
    } pathead;
    read(file, &pathead, sizeof(pathead));
    lseek(file, pathead.len-sizeof(pathead), SEEK_CUR);

    read(file, patbuf1, pathead.patdata);
    memset(patbuf1+pathead.patdata, 0x80, 0x10000-pathead.patdata);
    unsigned char *pp1=patbuf1;
    unsigned char *pp2=patbuf1+0x10000;
    *(unsigned long*)pp2=pathead.rows;
    pp2+=4;

    for (j=0; j<pathead.rows; j++)
    {
      for (k=0; k<head2.channum; k++)
      {
        unsigned char note=0;
        unsigned char ins=0;
        unsigned char vol=0;
        unsigned char cmd=0;
        unsigned char data=0;
        unsigned char pack=*pp1++;
        if (pack&0x80)
        {
          if (pack&0x01)
            note=*pp1++;
          if (pack&0x02)
            ins=*pp1++;
          if (pack&0x04)
            vol=*pp1++;
          if (pack&0x08)
            cmd=*pp1++;
          if (pack&0x10)
            data=*pp1++;
        }
        else
        {
          note=pack;
          ins=*pp1++;
          vol=*pp1++;
          cmd=*pp1++;
          data=*pp1++;
        }

        if (cmd>=36)
          cmd=data=0;
        if (cmd==0xE)
        {
          cmd=36+(data>>4);
          data&=0xF;
        }

        pack=0;
        if (note||ins)
          pack|=0x20;
        if (vol)
          pack|=0x40;
        if (cmd||data)
          pack|=0x80;
        if (pack)
        {
          pack|=k;
          *pp2++=pack;
          if (pack&0x20)
          {
            *pp2++=note;
            *pp2++=insreloc[ins];
          }
          if (pack&0x40)
          {
            *pp2++=vol;
            usevfx[vol>>4]=1;
          }
          if (pack&0x80)
          {
            usefx[cmd]=1;
            *pp2++=cmd;
            *pp2++=data;
          }
        }
      }
      *pp2++=0;
    }
    patofs[i]=tell(wf);
    write(wf, patbuf1+0x10000, pp2-patbuf1-0x10000);
  }
  if (addcleanpat)
  {
    patofs[head2.patnum]=tell(wf);
    *patbuf1=64;
    memset(patbuf1+1, 0, 67);
    write(wf, patbuf1, 68);
  }

  long memsize8=0;
  long memsize16=0;

  for (i=0; i<sampnum; i++)
  {
    if (sampinfo[i].type&4)
      memsize16+=(sampinfo[i].len>>1)+1;
    else
      memsize8+=sampinfo[i].len+1;
  }
  memsize8=(memsize8+15)&~15;
  memsize16=(memsize16+7)&~7;
  mxmhead.samples8=memsize8;
  mxmhead.samples16=memsize16;
  mxmhead.sampstart=tell(wf);

  if ((memsize8+2*memsize16)>1024*1024)
  {
    cputs("samples too long\r\n");
    return;
  }

  signed char *mem8=new signed char [memsize8];
  memset(mem8, 0, memsize8);

  unsigned long guspos=0;
  for (i=0; i<sampnum; i++)
  {
    if (sampinfo[i].type&4)
      continue;
    lseek(file, sampinfo[i].srcofs, SEEK_SET);
    read(file, mem8+guspos, sampinfo[i].len);
    signed char d=0;
    for (j=0; j<sampinfo[i].len; j++)
      mem8[guspos+j]=d+=mem8[guspos+j];

    lseek(wf, sampinfo[i].dstofs, SEEK_SET);
    unsigned long b,a=guspos;
    write(wf, &a, 3);
    mem8[guspos+sampinfo[i].len]=mem8[guspos+sampinfo[i].len-1];
    if (sampinfo[i].type&8)
    {
      b=a+sampinfo[i].loopstart;
      write(wf, &b, 3);
      b=a+sampinfo[i].loopend;
      write(wf, &b, 3);
      if (!(sampinfo[i].type&16))
        mem8[guspos+sampinfo[i].loopend]=mem8[guspos+sampinfo[i].loopstart];
    }
    else
    {
      b=0;
      write(wf, &b, 3);
      b=a+sampinfo[i].len;
      write(wf, &b, 3);
    }

    guspos+=sampinfo[i].len+1;
  }

  lseek(wf, 0, SEEK_END);

  if (dodelta)
  {
    signed char l=0;
    for (i=0; i<memsize8; i++)
    {
      signed char delta=mem8[i]-l;
      l=mem8[i];
      mem8[i]=delta;
    }
  }
  write(wf, mem8, memsize8);

  delete mem8;

  signed short *mem16=new signed short [memsize16];
  memset(mem16, 0, memsize16*2);

  guspos=0;
  for (i=0; i<sampnum; i++)
  {
    if (!(sampinfo[i].type&4))
      continue;
    sampinfo[i].loopstart>>=1;
    sampinfo[i].loopend>>=1;
    sampinfo[i].len>>=1;
    lseek(file, sampinfo[i].srcofs, SEEK_SET);
    read(file, mem16+guspos, sampinfo[i].len*2);
    signed short d=0;
    for (j=0; j<sampinfo[i].len; j++)
      mem16[guspos+j]=d+=mem16[guspos+j];

    lseek(wf, sampinfo[i].dstofs, SEEK_SET);
    unsigned long b,a=((guspos+(memsize8>>1))&0x1FFFF)|0x20000|(((guspos+(memsize8>>1))<<1)&0xC0000);
    write(wf, &a, 3);
    mem16[guspos+sampinfo[i].len]=mem16[guspos+sampinfo[i].len-1];
    if (sampinfo[i].type&8)
    {
      b=a+sampinfo[i].loopstart;
      write(wf, &b, 3);
      b=a+sampinfo[i].loopend;
      write(wf, &b, 3);
      if (!(sampinfo[i].type&16))
        mem16[guspos+sampinfo[i].loopend]=mem16[guspos+sampinfo[i].loopstart];
    }
    else
    {
      b=0;
      write(wf, &b, 3);
      b=a+sampinfo[i].len;
      write(wf, &b, 3);
    }

    guspos+=sampinfo[i].len+1;
  }

  lseek(wf, 0, SEEK_END);

  if (dodelta)
  {
    signed short l16=0;
    for (i=0; i<memsize16; i++)
    {
      signed short delta=mem16[i]-l16;
      l16=mem16[i];
      mem16[i]=delta;
    }
  }

  write(wf, mem16, memsize16*2);
  delete mem16;

  lseek(wf, 0, SEEK_SET);
  write(wf, &mxmhead, sizeof(mxmhead));
  write(wf, &head2.ord, 256);
  write(wf, &insofs, 512);
  write(wf, &patofs, 1024);
  lseek(wf, 0, SEEK_END);

  close(wf);
  close(file);

  cputs(dpath);
  cputs(" written\r\n");

  if (include)
  {
    wf=open(ipath, O_WRONLY|O_BINARY|O_CREAT|O_TRUNC, S_IREAD|S_IWRITE);
    writestrbool(wf, "USEARPEGGIO", usefx[0]);
    writestrbool(wf, "USEPORTA", usefx[1]||usefx[2]);
    writestrbool(wf, "USEPORTANOTE", usefx[3]);
    writestrbool(wf, "USEVIBRATO", usefx[4]);
    writestrbool(wf, "USEPORTAVOL", usefx[5]);
    writestrbool(wf, "USEVIBRATOVOL", usefx[6]);
    writestrbool(wf, "USETREMOLO", usefx[7]);
    writestrbool(wf, "USEPAN", usefx[8]);
    writestrbool(wf, "USEOFFSET", usefx[9]);
    writestrbool(wf, "USEVOLSLIDE", usefx[10]);
    writestrbool(wf, "USEJUMP", usefx[11]);
    writestrbool(wf, "USEVOL", usefx[12]);
    writestrbool(wf, "USEBREAK", usefx[13]);
    writestrbool(wf, "USESPEED", usefx[15]);
    writestrbool(wf, "USEGVOL", usefx[16]);
    writestrbool(wf, "USEGVOLSLIDE", usefx[17]);
    writestrbool(wf, "USEKEYOFFCMD", usefx[20]);
    writestrbool(wf, "USEENVPOS", usefx[21]);
    writestrbool(wf, "USEPANSLIDE", usefx[25]);
    writestrbool(wf, "USEMRETRIG", usefx[27]);
    writestrbool(wf, "USESYNC", usefx[28]||usefx[32]||usefx[36+15]);
    writestrbool(wf, "USETREMOR", usefx[29]);
    writestrbool(wf, "USEXFPORTA", usefx[33]);
    writestrbool(wf, "USEFPORTA", usefx[36+1]||usefx[36+2]);
    writestrbool(wf, "USEGLISSANDO", usefx[36+3]);
    writestrbool(wf, "USEVIBTYPE", usefx[36+4]);
//    writestrbool(wf, "USEFINETUNE", usefx[36+5]);
    writestrbool(wf, "USEPATLOOP", usefx[36+6]);
    writestrbool(wf, "USETREMTYPE", usefx[36+7]);
    writestrbool(wf, "USESPAN", usefx[36+8]);
    writestrbool(wf, "USERETRIG", usefx[36+9]);
    writestrbool(wf, "USEFVOLSLIDE", usefx[36+10]||usefx[36+11]);
    writestrbool(wf, "USENOTECUT", usefx[36+12]);
    writestrbool(wf, "USEDELAY", usefx[36+13]);
    writestrbool(wf, "USEPATDELAY", usefx[36+14]);
    write(wf, "\r\n", 2);

    writestrbool(wf, "USEVVOL", usevfx[1]|usevfx[2]|usevfx[3]|usevfx[4]|usevfx[5]);
    writestrbool(wf, "USEVVOLSLIDE", usevfx[6]|usevfx[7]);
    writestrbool(wf, "USEVFVOLSLIDE", usevfx[8]|usevfx[9]);
    writestrbool(wf, "USEVVIBRATE", usevfx[10]);
    writestrbool(wf, "USEVVIBRATO", usevfx[11]);
    writestrbool(wf, "USEVPAN", usevfx[12]);
    writestrbool(wf, "USEVPANSLIDE", usevfx[13]|usevfx[14]);
    writestrbool(wf, "USEVPORTANOTE", usevfx[15]);
    write(wf, "\r\n", 2);

    writestrbool(wf, "USEVOLENV", useifx[0]);
    writestrbool(wf, "USEPANENV", useifx[1]);
    writestrbool(wf, "USEAUTOVIBRATO", useifx[2]);
    writestrbool(wf, "USEAUTOVIBRATOTYPE", useifx[3]);
    writestrbool(wf, "USE16BIT", useifx[4]);
    write(wf, "\r\n", 2);

    writestrbool(wf, "USEDELTASAMP", dodelta);
    writestrbool(wf, "USEFREQTAB", head2.freqtab&1);

    close(wf);
    cputs(ipath);
    cputs(" written\r\n");
  }
}
