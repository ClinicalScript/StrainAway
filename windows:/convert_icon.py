from PIL import Image

img = Image.open("assets/app_icon.png")
img.save("assets/app_icon.ico",
         sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
