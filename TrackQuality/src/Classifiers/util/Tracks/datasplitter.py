inputfile = open("input.txt", 'r') 
inLines = inputfile.readlines() 
headers = inLines[0:11]
inLines = inLines[11:]

new_file_i = 0
new_i = 8


for i,line in enumerate(inLines):
    
    if (i % 976 == 0) :
        new_file_i += 1
        f1=open("inputfile"+str(new_file_i)+'.txt', 'a')
        for hline in headers:
            f1.write(hline)
        new_i = 8

    f1=open("inputfile"+str(new_file_i)+'.txt', 'a')
    frame = line.partition(":")
    newline = "Frame " + str(new_i) + " :" + frame[2]
    
    
    f1.write(("Frame {:0>4d} :" + frame[2]).format(new_i))
    new_i += 1
       
