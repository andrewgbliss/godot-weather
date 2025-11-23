### Convert png to ico

```
docker run --entrypoint=magick -v ./assets/img/icons:/imgs dpokidov/imagemagick -size 1024x1024 /imgs/icons/icon-1024.png -define icon:auto-resize=256,128,64,48,32,16 icon-1024.ico
```

### Generate Keystore For Google Play

https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

```
keytool -v -genkey -keystore mygame.keystore -alias mygame -keyalg RSA -validity 10000
```

### Copy Loading Brand To Assets

```
cp "/mnt/d/Bliss Code/Marketing/Marketing/0-shield.png" "./assets/img/brand/"
```
