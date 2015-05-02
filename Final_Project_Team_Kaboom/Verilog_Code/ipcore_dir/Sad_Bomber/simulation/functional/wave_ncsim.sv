

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /Sad_Bomber_tb/status
      waveform add -signals /Sad_Bomber_tb/Sad_Bomber_synth_inst/bmg_port/CLKA
      waveform add -signals /Sad_Bomber_tb/Sad_Bomber_synth_inst/bmg_port/ADDRA
      waveform add -signals /Sad_Bomber_tb/Sad_Bomber_synth_inst/bmg_port/DINA
      waveform add -signals /Sad_Bomber_tb/Sad_Bomber_synth_inst/bmg_port/WEA
      waveform add -signals /Sad_Bomber_tb/Sad_Bomber_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
