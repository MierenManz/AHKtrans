#include <ffmpeg>
test := New FFMPEG()
test.setffmpegpath("C:\ffmpeg\bin\ffmpeg.exe")
test.inputfile("C:\Users\User\Desktop\transcuder\output.mp4")
test.run()