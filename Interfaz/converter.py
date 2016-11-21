from PIL import Image
import _imaging
 
def rgb565(r,g,b):
    nR = int(round(r/255.0*7.0))
    nG = int(round(g/255.0*7.0))
    nB = int(round(b/255.0*3.0))
    return (nR<<5)+(nB<<3)+nG
 
name = 'Instr'
path_imagen = 'instr.jpg'
#path_imagen = r'C:\Users\Josue\Documents\Josue Cifuentes 2016\2ndo semestre\Assembler\Laboratorio 3\Dora.jpg'
 
img = Image.open(path_imagen)
pix = img.load()
output = '\n'
output += '.section .data'+'\n'
output += '.align 1'+'\n'+'\n'
output += '.globl '+name+'Height'+'\n'
output += ''+name+'Height: .word '+str(img.size[1])+'\n'
output += '.globl '+name+'Width'+'\n'
output += ''+name+'Width: .word '+str(img.size[0])+'\n'
output += '.globl '+name+'\n'+'\n'
output += ''+name+':\n'
 
for j in range(img.size[1]):
    list_ = []
    for i in range(img.size[0]):
        if len(pix[i,j])==3:
            r,g,b = pix[i,j]
        elif len(pix[i,j])==4:
            r,g,b,a = pix[i,j]
        else:
            print "Error"
            break
        newRGB = rgb565(r,g,b) # convert to 8 bits
        list_.append(newRGB)
    output += '    .byte '+', '.join([str(a) for a in list_])+'\n'
 
# save the file
open(name+'.s','w').write(output)
