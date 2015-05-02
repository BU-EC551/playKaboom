
 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"


      waveform add -signals /Sprites_Mem_tb/status
      waveform add -signals /Sprites_Mem_tb/Sprites_Mem_synth_inst/bmg_port/CLKA
      waveform add -signals /Sprites_Mem_tb/Sprites_Mem_synth_inst/bmg_port/ADDRA
      waveform add -signals /Sprites_Mem_tb/Sprites_Mem_synth_inst/bmg_port/DINA
      waveform add -signals /Sprites_Mem_tb/Sprites_Mem_synth_inst/bmg_port/WEA
      waveform add -signals /Sprites_Mem_tb/Sprites_Mem_synth_inst/bmg_port/DOUTA
console submit -using simulator -wait no "run"
