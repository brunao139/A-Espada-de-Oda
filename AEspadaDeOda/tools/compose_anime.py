"""Original 30s instrumental, sampled instruments + synthesized synchronized effects.
Usage: python compose_anime.py --soundfont GeneralUser-GS.sf2 --output soundtrack.wav
Requires numpy, scipy, tinysoundfont. No downloaded commercial recording.
"""
import argparse, wave
from pathlib import Path
import numpy as np
from scipy.signal import butter, sosfilt
from tinysoundfont import Synth
p=argparse.ArgumentParser()
p.add_argument('--soundfont',required=True)
p.add_argument('--output',required=True)
args=p.parse_args()
SR=44100; N=SR*30
s=Synth(gain=-16,samplerate=SR); sf=s.sfload(args.soundfont)
for ch,program,vol,pan in [(0,48,95,50),(1,30,78,30),(2,33,105,64),(3,60,76,83),(4,46,75,87),(5,89,60,64),(9,0,94,64)]:
    s.program_select(ch,sf,bank=0,preset=program,is_drums=ch==9)
    s.control_change(ch,7,vol); s.control_change(ch,10,pan)
events=[]
def note(t,ch,key,dur,vel=85):
    events.extend([(round(t*SR),1,ch,key,vel),(round((t+dur)*SR),0,ch,key,0)])
beat=.4
# E minor, C, D, B tension: motif and driving eighth-note ostinato.
roots=[40,36,38,35]
for k in range(54):
    t=.6+k*.2
    root=roots[(k//8)%4]
    note(t,0,root+24+[0,7,12,7,3,7,10,7][k%8],.16,74+(k%4==0)*20)
    if k%2==0:
        note(t,2,root,.34,100)
        for n in [root+12,root+19]: note(t,1,n,.24,90)
    note(t,9,42,.06,65+(k%2)*20)
    if k%4==0: note(t,9,36,.16,116)
    if k%4==2: note(t,9,38,.17,100)
for k,key in enumerate([76,79,83,81,79,76,74,78,76,79,86,83,81,78]):
    note(5.0+k*.4,3,key,.32,73)
for t in [.6,3.8,7.0,9.4]: note(t,9,49,1.1,84)
# Time suspended over the gap: harp, sustained strings and soft choir-like pad.
for key in [52,59,64,67,71]:
    note(11.4,0,key,4.8,53)
    note(11.6,5,key+12,4.6,43)
for k,key in enumerate([64,71,76,79,83,79,76,71,67,74,79,83]):
    note(11.5+k*.4,4,key,1.1,65)
# Preparation: low pulse, strings climb, tom/snare crescendo.
for k in range(32):
    t=16.8+k*.2
    root=roots[(k//8)%4]
    note(t,0,root+24+[0,3,7,12][k%4],.17,60+k)
    if k%2==0:
        note(t,2,root,.35,80)
        for key in [root+12,root+19]: note(t,1,key,.30,78)
    note(t,9,41 if k<16 else 38,.12,min(110,55+k*2))
    if k%4==0: note(t,9,36,.15,100)
for k,key in enumerate([64,67,71,74,76,79,83,86]):
    note(20+k*.4,3,key,.35,65+k*4)
# Sword strike and resolved title chord.
for t,vel in [(23.35,118),(24.05,125),(26.0,85)]:
    note(t,9,49,1.6,vel); note(t,9,36,.6,vel)
for key in [40,47,52,55,59,64]:
    note(24.05,0,key,4.8,78)
    note(24.05,3,key+12,1.5,80)
    note(26.0,4,key+24,2.8,55)
events.sort()
mix=np.zeros((N,2),np.float32); cursor=0
for sample,on,ch,key,vel in events+[(N,0,0,0,0)]:
    sample=min(N,max(0,sample))
    if sample>cursor:
        block=np.frombuffer(s.generate_simple(sample-cursor),np.float32).reshape(-1,2)
        mix[cursor:sample]=block
        cursor=sample
    if sample==N: break
    if on:s.noteon(ch,key,vel)
    else:s.noteoff(ch,key)
# A short stereo room adds space without obscuring percussion.
dry=mix.copy()
for delay,gain in [(.073,.14),(.131,.10),(.211,.07),(.337,.04)]:
    d=int(delay*SR); mix[d:]+=dry[:-d,::-1]*gain
rng=np.random.default_rng(139)
def effect(start,duration,kind,amp):
    n=int(duration*SR); t=np.arange(n)/SR
    noise=rng.standard_normal(n)
    if kind=='step':
        v=(sosfilt(butter(2,1400,fs=SR,output='sos'),noise)*.55+np.sin(2*np.pi*95*t))*np.exp(-t*45)
    elif kind=='whoosh':
        v=sosfilt(butter(2,[240,4000],btype='band',fs=SR,output='sos'),noise)*np.sin(np.pi*t/duration)**2
        v+=.15*np.sin(2*np.pi*(150*t+600*t*t/duration))*np.sin(np.pi*t/duration)**2
    elif kind=='impact':
        v=(.6*noise*np.exp(-t*12)+np.sin(2*np.pi*(54*t+8*(1-np.exp(-t*15))))*np.exp(-t*3))
        v+=.22*(np.sin(2*np.pi*1840*t)+np.sin(2*np.pi*2910*t))*np.exp(-t*7)
    elif kind=='energy':
        v=(np.sin(2*np.pi*(100*t+120*t*t))*.4+sosfilt(butter(2,2200,fs=SR,output='sos'),noise)*.18)*(t/duration)**1.6
    v=np.asarray(v,np.float32)*amp
    i=int(start*SR); count=min(n,N-i)
    mix[i:i+count]+=v[:count,None]
for t in np.arange(.85,6.2,.286): effect(float(t),.13,'step',.13)
for t in np.arange(6.2,11.35,.286): effect(float(t),.11,'step',.11)
effect(6.2,3.2,'energy',.17); effect(7.15,1.6,'whoosh',.32)
effect(11.35,1.3,'whoosh',.3)
effect(16.68,.75,'impact',.3)
effect(18.3,4.45,'energy',.15)
effect(22.75,.9,'whoosh',.6)
effect(24.0,2.0,'impact',.75)
# Quiet rain after the temporal transition.
rain=sosfilt(butter(2,[1800,6500],btype='band',fs=SR,output='sos'),rng.standard_normal(N))
env=np.clip((np.arange(N)/SR-8.5),0,1)*np.clip((25-np.arange(N)/SR),0,1)
mix+=np.asarray(rain*env*.009,np.float32)[:,None]
mix*=np.minimum(np.arange(N)/(.35*SR),1)[:,None]
mix*=np.clip((N-np.arange(N))/(1.5*SR),0,1)[:,None]
mix=np.tanh(mix*1.25)
mix*=.92/max(.92,float(np.abs(mix).max()))
Path(args.output).parent.mkdir(parents=True,exist_ok=True)
with wave.open(args.output,'wb') as out:
    out.setnchannels(2);out.setsampwidth(2);out.setframerate(SR)
    out.writeframes((mix*32767).astype('<i2').tobytes())
print('Audio: 30s stereo 44100Hz, peak',round(float(np.abs(mix).max()),3),'RMS',round(float(np.sqrt((mix*mix).mean())),3))
