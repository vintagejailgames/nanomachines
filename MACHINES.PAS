
program machines;

uses crt,dmon3b,keyboard;

type
 car = record
  x,y,xv,yv: single;
  Angle,Accel,resA,resV : integer;
  m,q,c,rebot : boolean;
  pixel,turbo : byte;
  maxAcc,maxAc2,MaxAng : integer;
  paQpoints : longint;
  amunt,avall,esquerra,dreta,turbot: byte;
 end;

 tipo_item = record
  x,y,valor,tipo : word;
  activa : boolean;
 end;

 tipo_points = record
  x,y,contador,valor : integer;
 end;

const
  meta = 71;

label PASAR;

var
  jugador : array[0..4] of car;
  numJugadors,dificultat,pista : byte;
  sinus,cosinus : array[0..360] of single;
  i,j,k : word;
  mapa,mapc : array[0..9, 0..5] of char;
  temp : byte;
  salida : boolean;
  item : tipo_item;
  points,fum : tipo_points;
  state : byte;
  logox : integer;
  pal : AuxPalette;
  rrr : string;

Procedure LoadMap;
var
  f: file of char;
  temp : char;
  fn : string;
begin
fn := 'map1.map';
inc(fn[4],pista);
Assign(f,fn);
Reset(f);
For j := 0 to 5 do
  begin
  For i := 0 to 9 do
    Read(f,mapa[i,j]);
  Read(f,temp); Read(f,temp);
  end;
Read(f,temp); Read(f,temp);
For j := 0 to 5 do
  begin
  For i := 0 to 9 do
    Read(f,mapc[i,j]);
  Read(f,temp); Read(f,temp);
  end;
Close(f);
end;


Procedure Computer(k:integer);
label EIXIR;
var
  AcCurva, AcRecta, RndAng: byte;
begin
with jugador[k] do
  begin
AcCurva := Random(2)+maxAc2-1; { Per a que la acceleraci¢ no siga constant }
AcRecta := Random(2)+maxAcc-1; { i hi haja un factor aleatori }
RndAng  := Random(3)+maxAng-1; { tamb‚ per al angle de gir }

  if mapc[trunc(x/32),trunc(y/32)] = '0' then
    begin
    If x-(trunc(x/32)*32) < 6 then x := x + 1;
    If x-(trunc(x/32)*32) > 25 then x := x - 1;
    If Angle <> 0 then
      begin
      If (Angle < 10) or (Angle > 350) then begin Angle := 0; goto EIXIR; end;
      If Accel < acCurva then Inc(Accel);
      If Accel > acCurva then Dec(Accel);
      If sinus[Angle] < 0 then
        Angle := Angle + RndAng
      else
        Angle := Angle - RndAng;
      end else If Accel < acRecta then Inc(Accel);
    goto EIXIR;
    end;
  if mapc[trunc(x/32),trunc(y/32)] = '1' then
    begin
    If y-(trunc(y/32)*32) < 6 then y := y + 1;
    If y-(trunc(y/32)*32) > 25 then y := y - 1;
    If Angle <> 90 then
      begin
      If (Angle < 100) and (Angle > 80) then begin Angle := 90; goto EIXIR; end;
      If Accel < acCurva then Inc(Accel);
      If Accel > acCurva then Dec(Accel);
      If cosinus[Angle] > 0 then
        Angle := Angle + RndAng
      else
        Angle := Angle - RndAng;
      end else If Accel < acRecta then Inc(Accel);
    goto EIXIR;
    end;
  if mapc[trunc(x/32),trunc(y/32)] = '2' then
    begin
    If x-(trunc(x/32)*32) < 6 then x := x + 1;
    If x-(trunc(x/32)*32) > 25 then x := x - 1;
    If Angle <> 180 then
      begin
      If (Angle < 190) and (Angle > 170) then begin Angle := 180; goto EIXIR; end;
      If Accel < acCurva then Inc(Accel);
      If Accel > acCurva then Dec(Accel);
      If sinus[Angle] > 0 then
        Angle := Angle + RndAng
      else
        Angle := Angle - RndAng;
      end else If Accel < acRecta then Inc(Accel);
    goto EIXIR;
    end;
  if mapc[trunc(x/32),trunc(y/32)] = '3' then
    begin
    If y-(trunc(y/32)*32) < 6 then y := y + 1;
    If y-(trunc(y/32)*32) > 25 then y := y - 1;
    If Angle <> 270 then
      begin
      If (Angle < 280) and (Angle > 260) then begin Angle := 270; goto EIXIR; end;
      If Accel < acCurva then Inc(Accel);
      If Accel > acCurva then Dec(Accel);
      If cosinus[Angle] < 0 then
        Angle := Angle + RndAng
      else
        Angle := Angle - RndAng;
      end else If Accel < acRecta then Inc(Accel);
    goto EIXIR;
    end;
  if mapc[trunc(x/32),trunc(y/32)] = '4' then
    begin
    If y-(trunc(y/32)*32) < 10 then y := y + 1;
    If y-(trunc(y/32)*32) > 21 then y := y - 1;
    If Angle <> 270 then
      begin
      If (Angle < 280) and (Angle > 260) then begin Angle := 270; goto EIXIR; end;
      If Accel < acCurva then Inc(Accel);
      If Accel > acCurva then Dec(Accel);
      If cosinus[Angle] < 0 then
        Angle := Angle + RndAng
      else
        Angle := Angle - RndAng;
      end else If Accel < acRecta then Inc(Accel);
    end;

EIXIR:

  If Angle > 359 then Angle := Angle - 360;
  If Angle < 0 then Angle := 360 + Angle;
  end;
end;


Procedure Teclat(k:integer);
begin
with jugador[k] do
begin
 If Accel > maxAcc then Accel := Accel - 1;

 If keypress(esquerra) then
   begin
   Angle := Angle + maxAng;
   end;
 If keypress(dreta) then
   begin
   Angle := Angle - maxAng;
   end;
 If keypress(amunt) then
   begin
   If Accel < maxAcc then Accel := Accel + 1;
   end
 else
   begin
   If keypress(avall) then
     begin
     If Accel > -2 then Accel := Accel - 1;
     end
   else
     If Accel > 0 then
       Accel := Accel - 1
     else
       If Accel < 0 then
         Accel := Accel + 1
       else
         begin yv := 0; xv := 0; end;
   end;
 If (keypress(turbot)) and (fum.contador=0) then
   begin
   fum.contador := 3;
   fum.x := round(x)-6;
   fum.y := round(y)+1;
   Accel := 10;
   end;
  If Angle > 359 then Angle := Angle - 360;
  If Angle < 0 then Angle := 360 + Angle;
end;
end;


Procedure Menu;
var
  x1,x2,y1,y2,x11 : integer;
  select : byte;
begin
LoadPcx('menu.pcx',IP);
LoadPcx('spr.pcx',SP);
Savepalette(pal);
blackout;
flip(IP,VGA);
fadein(pal);
{For x1 := 249 downto 1 do
  begin
  flip(IP,WP);
  PutSpriteS(SP,0,87,73,16,WP,(123-(x1 div 2)),60,73+x1,16+((x1*16) div 73));
  flip(WP,VGA);
  end;
For x1 := 223 downto 1 do
  begin
  flip(IP,WP);
  PutSprite(SP,0,87,WP,123,60,73,16);
  PutSpriteS(SP,73,87,100,16,WP,(110-(x1 div 2)),90,100+x1,16+((x1*16) div 100));
  flip(WP,VGA);
  end;
For x1 := 259 downto 1 do
  begin
  flip(IP,WP);
  PutSprite(SP,0,87,WP,123,60,73,16);
  PutSprite(SP,73,87,WP,110,90,100,16);
  PutSpriteS(SP,173,87,63,16,WP,(128-(x1 div 2)),120,63+x1,16+((x1*16) div 63));
  flip(WP,VGA);
  end;
PutSprite(SP,173,87,VGA,128,120,63,16);
}
For x11 := 52 downto 0 do
  begin
  x1 := x11*4;
  flip(IP,WP);
  If 123+x1 < 320 then
    If 196+x1 < 319 then PutSprite(SP,0  ,87,WP,123+x1,60 ,73 ,16)
                    else PutSprite(SP,0  ,87,WP,123+x1,60 ,73-((196+x1)-320) ,16);
  If 210-x1 >= 0 then
    If 110-x1 >= 0 then PutSprite(SP,73 ,87,WP,110-x1,90 ,100,16)
                   else PutSprite(SP,73-(110-x1),87,WP,0,90 ,100+(110-x1),16);
  If 128+x1 < 320 then
    If 191+x1 < 319 then PutSprite(SP,173,87,WP,128+x1,120,63 ,16)
                    else PutSprite(SP,173,87,WP,128+x1,120,63-((191+x1)-320),16);
  flip(WP,VGA);
  end;

select:=0; x1 := 0;

repeat
If keypress(keyArrowDown) then If select=2 then select:=0 else inc(select);
If keypress(keyArrowUp)   then If select=0 then select:=2 else dec(select);
flip(IP,WP);
PutSprite(SP,0,87,WP,123,60,73,16);
PutSprite(SP,73,87,WP,110,90,100,16);
PutSprite(SP,173,87,WP,128,120,63,16);
If x1=15 then x1:=0 else inc(x1);
If select = 0 then
  begin
  PutSprite(SP,x1*7,0,WP,100,65,7,7);
  PutSprite(SP,x1*7,0,WP,213,65,7,7);
  end;
If select = 1 then
  begin
  PutSprite(SP,x1*7,0,WP,100,95,7,7);
  PutSprite(SP,x1*7,0,WP,213,95,7,7);
  end;
If select = 2 then
  begin
  PutSprite(SP,x1*7,0,WP,100,125,7,7);
  PutSprite(SP,x1*7,0,WP,213,125,7,7);
  end;
flip(WP,VGA);delay(100);
until keypress(keyEnter);
For x11 := 0 to 52 do
  begin
  x1 := x11 * 4;
  flip(IP,WP);
  If 123+x1 < 320 then
    If 196+x1 < 319 then PutSprite(SP,0  ,87,WP,123+x1,60 ,73 ,16)
                    else PutSprite(SP,0  ,87,WP,123+x1,60 ,73-((196+x1)-320) ,16);
  If 210-x1 >= 0 then
    If 110-x1 >= 0 then PutSprite(SP,73 ,87,WP,110-x1,90 ,100,16)
                   else PutSprite(SP,73-(110-x1),87,WP,0,90 ,100+(110-x1),16);
  If 128+x1 < 320 then
    If 191+x1 < 319 then PutSprite(SP,173,87,WP,128+x1,120,63 ,16)
                    else PutSprite(SP,173,87,WP,128+x1,120,63-((191+x1)-320),16);
  flip(WP,VGA);
  end;
select := 0;
repeat
If keypress(keyArrowRight) then If select=3 then select:=0 else inc(select);
If keypress(keyArrowLeft)   then If select=0 then select:=3 else dec(select);
flip(IP,WP);
PutSprite(SP,18,56,WP,95,80,133,11);
PutSprite(SP,0,56,WP,95,100,9,7);
PutSprite(SP,9,56,WP,219,100,9,7);
PutSprite(SP,242+(select*8),45,WP,160,97,8,11);
flip(WP,VGA);delay(100);
until keypress(keyEnter);
numJugadors := select+1;
select := 0;
delay(200);
repeat
If keypress(keyArrowRight) then If select=2 then select:=0 else inc(select);
If keypress(keyArrowLeft)   then If select=0 then select:=2 else dec(select);
flip(IP,WP);
PutSprite(SP,151,56,WP,95,80,75,11);
PutSprite(SP,0,56,WP,95,100,9,7);
PutSprite(SP,9,56,WP,219,100,9,7);
PutSprite(SP,242+(select*8),45,WP,160,97,8,11);
flip(WP,VGA);delay(100);
until keypress(keyEnter);
dificultat := select;
select := 0;
delay(200);
repeat
If keypress(keyArrowRight) then If select=6 then select:=0 else inc(select);
If keypress(keyArrowLeft)  then If select=0 then select:=6 else dec(select);
flip(IP,WP);
PutSprite(SP,226,56,WP,95,80,39,11);
PutSprite(SP,0,56,WP,95,100,9,7);
PutSprite(SP,9,56,WP,219,100,9,7);
PutSprite(SP,242+(select*8),45,WP,160,97,8,11);
flip(WP,VGA);delay(100);
until keypress(keyEnter);
pista := select;
repeat until Qkeypress;
end;



begin
Randomize;
InitDM;
hookKb;

state := 0;
logox := 139{320};

numJugadors := 4;

Menu;

Cls(8,IP);

LoadPcx('pistes.pcx',SP);

loadmap;
For j := 0 to 5 do
  For i := 0 to 9 do
    If (ord(mapa[i,j]) > 47) and (ord(mapa[i,j]) < 58) then
      begin
      temp := ord(mapa[i,j])-48;
      PutBloc(SP,temp*32,IP,32,32,i*32,j*32);
      If temp = 9 then
        begin
        Jugador[0].x := 24+(i*32);
        Jugador[0].y := 10+(j*32);
        Jugador[1].x := 21+(i*32);
        Jugador[1].y := 21+(j*32);
        Jugador[2].x := 11+(i*32);
        Jugador[2].y := 10+(j*32);
        Jugador[3].x :=  9+(i*32);
        Jugador[3].y := 21+(j*32);
        end;
      end;


LoadPcx('spr.pcx',SP);

For i := 0 to 360 do
  begin
  sinus[i]   := sin((Pi/180)*i);
  cosinus[i] := cos((Pi/180)*i);
  end;

with jugador[0] do
begin
amunt:=keyArrowUp;
avall:=keyArrowDown;
esquerra:=keyArrowLeft;
dreta:=keyArrowRight;
turbot:=keyRightCtrl;
end;

with jugador[1] do
begin
m := True;
Accel := 0;
Angle := 90;
c := True;
If dificultat=0 then maxAcc:=5 else maxAcc:=6; {  5=facil  6=dificil }
If dificultat=0 then maxAc2:=4 else maxAc2:=5; {  4=facil  5=dificil }
maxAng := 11;                                  {        igual        }
amunt:=keyW;
avall:=keyS;
esquerra:=keyA;
dreta:=keyD;
turbot:=keyLeftCtrl;
end;

with jugador[2] do
begin
m := True;
Accel := 0;
Angle := 90;
c := True;
If dificultat=0 then maxAcc:=5 else maxAcc:=6;  {  5=facil  6=dificil }
maxAc2 := 3;                                    { igual               }
If dificultat=0 then maxAng:=12 else maxAng:=15;{ 12=facil 15=dificil }
amunt:=keyT;
avall:=keyG;
esquerra:=keyF;
dreta:=keyH;
turbot:=keyLeftAlt;
end;

with jugador[3] do
begin
m := True;
Accel := 0;
Angle := 90;
c := True;
If dificultat=0 then maxAcc:=5 else maxAcc:=6;  {  5=facil  6=dificil }
maxAc2 := 4;                                    { igual               }
If dificultat=0 then maxAng:=10 else maxAng:=12;{ 10=facil 12 dificil }
amunt:=keyI;
avall:=keyK;
esquerra:=keyJ;
dreta:=keyL;
turbot:=keySpace;
end;


For i := 0 to numJugadors-1 do
begin
with jugador[i] do
  begin
  m := True;
  Accel := 0;
  Angle := 90;
  c := False;
  maxAcc := 6;
  maxAc2 := 4;
  maxAng := 12;
  end;
end;

repeat

If not salida then goto PASAR;

If (not item.activa) and (Random(100) = 1) then
  begin
  sound(400);delay(100); nosound;
  repeat
   i:=Random(10); j:=Random(6);
  until mapa[i,j] <> '.';
  item.activa := True;
  item.x := (i*32)+(Random(20)+6);
  item.y := (j*32)+(Random(20)+6);
  item.valor := Random(2);
  item.tipo := Random(2);
  end;

For k := 0 to 3 do
begin
with Jugador[k] do
begin

If (pixel = 66) or (pixel = 45) then If c then Computer(k) else Teclat(k);

   xv := (sinus[Angle]*Accel) + (sinus[resA]*resV);
   yv := (cosinus[Angle]*Accel) + (cosinus[resA]*resV);

 If x < 4 then x := 4;
 If x > 312 then x := 312;
 If y < 4 then y := 4;
 If y > 196 then y := 196;
 pixel := getpixel(IP,round(x+xv),round(y+yv));
 If (resV > 0) and ((pixel = 66) or (pixel = 45)) then resV := resV - 1;

{For i := 0 to numJugadors-1 do
  If numJugadors <> k then
    begin
    If
    end;} { INTENTO DE FER QUE ELS COCHES CHOQUEN }

 If (pixel <> 66) and (pixel <> 45) then
   begin
{   If pixel = 4 then Accel := 0 else
     begin}
     resA := (Angle+180) mod 360;
     resV := Accel;
     Accel := 0;
     xv := (sinus[Angle]*Accel) - (sinus[resA]*resV);
     yv := (cosinus[Angle]*Accel) - (cosinus[resA]*resV);
{     end;}
   end;
   x := x + xv;
   y := y + yv;
 If y < 100 then m := False else m := True;
 if (x > meta) and (m) and not(q) then begin q := true; end;
 if (x < meta) and not(m) and (q) then q := false;

 If (item.activa) and (x>=item.x) and (x<=item.x+5) and (y>=item.y) and (y<=item.y+5) then
   begin
   item.activa := False;
   If item.tipo = 0 then
     begin
     paQpoints := paQpoints + ((item.valor*400)+100);
     sound(800); delay(100); nosound;
     points.contador := 20;
     points.valor := (item.valor*12)+117;
     points.x := item.x-4;
     points.y := item.y;
     end;
   If item.tipo = 1 then
     begin
     sound(800); delay(100); nosound;
     turbo := turbo + item.valor;
     end;
   end;
end;

end;

PASAR:

Flip(IP,WP);


For k := 0 to 3 do
begin
  with Jugador[k] do
    begin
    PutSprite(SP,trunc(Angle/22.5)*7,k*7,WP,round(x)-3,round(y)-3,7,7);
    end;
end;

If item.activa then
  begin
  If item.tipo = 0 then PutSprite(SP,112,0,WP,item.x,item.y,5,5);
  If item.tipo = 1 then PutSprite(SP,112,5,WP,item.x,item.y,5,5);
  end;

If points.contador > 0 then
  begin
  PutSprite(SP,points.valor,0,WP,points.x,(points.y-20)+points.contador,13,7);
  dec(points.contador);
  end;

If fum.contador > 0 then
  begin
  PutSprite(SP,143+((3-fum.contador)*6),0,WP,fum.x,fum.y,6,5);
  dec(fum.contador);
  end;

{If menu = 0 then
  begin
  dec(logox,10);
  If logox > 0 Then PutSpriteS(SP,0,69,185,18,WP,(68-(logox div 2)),0,185+logox,18+((logox*18) div 185));
{  If logox > 70 then logox := logox - 10;
  If logox > 134 then PutSprite(SP,0,69,WP,logox,40,320-logox,18)
                 else PutSprite(SP,0,69,WP,logox,40,185,18);}
{  end;}



 WAITRETRACE;
 flip(WP,VGA);
 If dificultat = 0 then delay(50); {50=facil 40=mig 30=dificil}
 IF dificultat = 1 then delay(40);
 IF dificultat = 2 then delay(30);

If keypress(keyEnter) then salida := True;


until keypress(keyEsc);
FreeKb;
EndDM;
end.
