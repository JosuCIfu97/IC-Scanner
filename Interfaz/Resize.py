# -*- coding: cp1252 -*-
#IMAGE RESIZE
import PIL
from PIL import Image

#PROGRAMA PARA CAMBIAR TAMAÑO DE FOTO
height = 600 #Valor que se cambia para ancho deseado
img = Image.open(r'C:\Users\Josue\Documents\Josue Cifuentes 2016\2ndo semestre\Assembler\Laboratorio 3\Victoria.jpg') #Cambiar nombre de imagen
hpercent = (height/float(img.size[1]))
width = int((float(img.size[0])*float(hpercent)))
width = 1150 #Valor que se cambia para altura deseada. Se comenta si se quiere una altura proporcional al ancho.
img = img.resize((width,height), PIL.Image.ANTIALIAS)
img.save(r'C:\Users\Josue\Documents\Josue Cifuentes 2016\2ndo semestre\Assembler\Laboratorio 3\Victoriar.jpg') #Cambiar nombre de imagen
